-- Consolidated Supabase schema for this project.
-- This file keeps the current app schema used by the codebase and folds in
-- the additional alert/metrics/supporting tables from the provided SQL.
-- Duplicate legacy definitions (for example public.users, public.reports,
-- duplicate public.parcels, duplicate public.activity_logs) were intentionally
-- not repeated here because they conflict with the app's active schema.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  user_id text not null unique,
  first_name text not null,
  last_name text not null,
  role text not null default 'staff' check (role in ('admin', 'staff')),
  status text not null default 'active' check (status in ('active', 'inactive')),
  status_reason text,
  password_hash text not null,
  created_by uuid references public.app_users(id) on delete set null,
  last_login_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.organization_settings (
  id boolean primary key default true check (id),
  registration_code_hash text,
  registration_code_updated_at timestamptz,
  registration_code_updated_by uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.parcels (
  id uuid primary key default gen_random_uuid(),
  tracking_number text not null unique,
  platform text not null check (platform in ('JNT', 'SPX', 'FLH', 'LZD')),
  status text not null check (status in ('Pending', 'Outbound', 'Cancelled', 'Returned', 'Double Waybill', 'Missing', 'Lost')),
  date_added date not null default current_date,
  outbound_date date,
  created_by uuid references public.app_users(id) on delete set null,
  updated_by uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.parcel_reports (
  id uuid primary key default gen_random_uuid(),
  parcel_id uuid not null references public.parcels(id) on delete cascade,
  tracking_number text not null,
  remarks text not null,
  status text not null default 'Unresolved' check (status in ('Unresolved', 'Resolved')),
  reported_by uuid references public.app_users(id) on delete set null,
  updated_by uuid references public.app_users(id) on delete set null,
  reported_at timestamptz not null default timezone('utc', now()),
  resolved_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  parcel_id uuid references public.parcels(id) on delete set null,
  tracking_number text,
  actor_id uuid references public.app_users(id) on delete set null,
  actor_name text,
  category text not null check (category in ('parcel', 'report', 'user', 'auth')),
  action text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.alerts (
  id bigserial primary key,
  parcel_id uuid unique references public.parcels(id) on delete cascade,
  tracking_number varchar(50),
  type varchar(20) not null default 'warning',
  message text not null,
  days_pending integer,
  state text not null default 'new',
  is_read boolean not null default false,
  read_at timestamptz,
  assigned_to uuid references public.app_users(id) on delete set null,
  assigned_at timestamptz,
  acknowledged_at timestamptz,
  resolved_at timestamptz,
  archived_at timestamptz,
  escalated_at timestamptz,
  escalation_level integer not null default 0,
  reopened_count integer not null default 0,
  last_qualified_at timestamptz not null default now(),
  last_action text,
  last_action_by uuid references public.app_users(id) on delete set null,
  visible_to_role text not null default 'staff',
  version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint alerts_type_check check (type in ('warning', 'critical')),
  constraint alerts_state_check check (state in ('new', 'read', 'acknowledged', 'assigned', 'resolved', 'archived')),
  constraint alerts_visible_to_role_check check (visible_to_role in ('staff', 'admin'))
);

create table if not exists public.notification_events (
  id bigserial primary key,
  alert_id bigint not null references public.alerts(id) on delete cascade,
  parcel_id uuid references public.parcels(id) on delete set null,
  actor_id uuid references public.app_users(id) on delete set null,
  event_type text not null,
  previous_state text,
  next_state text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint notification_events_type_check check (
    event_type in (
      'created',
      'updated',
      'reopened',
      'read',
      'acknowledged',
      'assigned',
      'unassigned',
      'flagged_for_review',
      'rerouted',
      'resolved',
      'archived',
      'bulk_updated',
      'visibility_changed',
      'escalated'
    )
  )
);

alter table public.alerts add column if not exists state text not null default 'new';
alter table public.alerts add column if not exists read_at timestamptz;
alter table public.alerts add column if not exists assigned_to uuid references public.app_users(id) on delete set null;
alter table public.alerts add column if not exists assigned_at timestamptz;
alter table public.alerts add column if not exists acknowledged_at timestamptz;
alter table public.alerts add column if not exists resolved_at timestamptz;
alter table public.alerts add column if not exists archived_at timestamptz;
alter table public.alerts add column if not exists escalated_at timestamptz;
alter table public.alerts add column if not exists escalation_level integer not null default 0;
alter table public.alerts add column if not exists reopened_count integer not null default 0;
alter table public.alerts add column if not exists last_qualified_at timestamptz not null default now();
alter table public.alerts add column if not exists last_action text;
alter table public.alerts add column if not exists last_action_by uuid references public.app_users(id) on delete set null;
alter table public.alerts add column if not exists visible_to_role text not null default 'staff';
alter table public.alerts add column if not exists version integer not null default 1;
alter table public.alerts add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'parcels_status_check'
      and conrelid = 'public.parcels'::regclass
  ) then
    alter table public.parcels drop constraint parcels_status_check;
  end if;

  alter table public.parcels
    add constraint parcels_status_check check (status in ('Pending', 'Outbound', 'Cancelled', 'Returned', 'Double Waybill', 'Missing', 'Lost'));

  if not exists (
    select 1
    from pg_constraint
    where conname = 'alerts_state_check'
      and conrelid = 'public.alerts'::regclass
  ) then
    alter table public.alerts
      add constraint alerts_state_check check (state in ('new', 'read', 'acknowledged', 'assigned', 'resolved', 'archived'));
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'alerts_visible_to_role_check'
      and conrelid = 'public.alerts'::regclass
  ) then
    alter table public.alerts
      add constraint alerts_visible_to_role_check check (visible_to_role in ('staff', 'admin'));
  end if;
end;
$$;

create index if not exists idx_app_users_role_status on public.app_users(role, status);
create index if not exists idx_app_users_created_at on public.app_users(created_at desc);
create index if not exists idx_parcels_tracking_number on public.parcels(tracking_number);
create index if not exists idx_parcels_status on public.parcels(status);
create index if not exists idx_parcels_platform on public.parcels(platform);
create index if not exists idx_parcels_date_added on public.parcels(date_added desc);
create index if not exists idx_parcels_status_date_added on public.parcels(status, date_added desc);
create index if not exists idx_parcels_platform_date_added on public.parcels(platform, date_added desc);
create index if not exists idx_parcel_reports_status on public.parcel_reports(status);
create index if not exists idx_parcel_reports_parcel_id on public.parcel_reports(parcel_id);
create index if not exists idx_parcel_reports_tracking_number on public.parcel_reports(tracking_number);
create index if not exists idx_parcel_reports_reported_at on public.parcel_reports(reported_at desc);
create index if not exists idx_parcel_reports_status_reported_at on public.parcel_reports(status, reported_at desc);
create index if not exists idx_activity_logs_tracking_number on public.activity_logs(tracking_number);
create index if not exists idx_activity_logs_created_at on public.activity_logs(created_at desc);
create index if not exists idx_alerts_is_read on public.alerts(is_read);
create index if not exists idx_alerts_type on public.alerts(type);
create index if not exists idx_alerts_tracking_number on public.alerts(tracking_number);
create index if not exists idx_alerts_created_at on public.alerts(created_at desc);
create index if not exists idx_alerts_state on public.alerts(state);
create index if not exists idx_alerts_assigned_to on public.alerts(assigned_to);
create index if not exists idx_alerts_visible_to_role on public.alerts(visible_to_role);
create index if not exists idx_alerts_state_created_at on public.alerts(state, created_at desc);
create index if not exists idx_alerts_state_days_pending on public.alerts(state, days_pending desc);
create index if not exists idx_alerts_visible_state_type on public.alerts(visible_to_role, state, type);
create index if not exists idx_alerts_visible_state_created_at on public.alerts(visible_to_role, state, created_at desc);
create index if not exists idx_alerts_visible_assigned_to on public.alerts(visible_to_role, assigned_to);
create index if not exists idx_alerts_state_assigned_to on public.alerts(state, assigned_to);
create index if not exists idx_alerts_assigned_to_state_created_at on public.alerts(assigned_to, state, created_at desc);
create index if not exists idx_alerts_visible_to_role_assigned_to_state on public.alerts(visible_to_role, assigned_to, state, created_at desc);
create index if not exists idx_notification_events_alert_id on public.notification_events(alert_id, created_at desc);
create index if not exists idx_notification_events_parcel_id on public.notification_events(parcel_id);
create index if not exists idx_notification_events_actor_id on public.notification_events(actor_id, created_at desc);

create or replace trigger set_app_users_updated_at
before update on public.app_users
for each row
execute function public.set_updated_at();

create or replace trigger set_organization_settings_updated_at
before update on public.organization_settings
for each row
execute function public.set_updated_at();

create or replace trigger set_parcels_updated_at
before update on public.parcels
for each row
execute function public.set_updated_at();

create or replace trigger set_parcel_reports_updated_at
before update on public.parcel_reports
for each row
execute function public.set_updated_at();

create or replace trigger set_alerts_updated_at
before update on public.alerts
for each row
execute function public.set_updated_at();

insert into public.organization_settings (id)
values (true)
on conflict (id) do nothing;

alter table public.app_users enable row level security;
alter table public.organization_settings enable row level security;
alter table public.parcels enable row level security;
alter table public.parcel_reports enable row level security;
alter table public.activity_logs enable row level security;
alter table public.alerts enable row level security;
alter table public.notification_events enable row level security;

-- Explicit row level security policies for authenticated clients.
-- Service role access still bypasses RLS, so backend server operations remain unaffected.
create policy "Allow authenticated select on app_users" on public.app_users
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated select on parcels" on public.parcels
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated select on parcel_reports" on public.parcel_reports
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated select on activity_logs" on public.activity_logs
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated select on alerts" on public.alerts
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated select on notification_events" on public.notification_events
  for select using (auth.role() = 'authenticated');

create policy "Allow authenticated insert on activity_logs" on public.activity_logs
  for insert with check (auth.role() = 'authenticated');

create policy "Allow authenticated insert on parcel_reports" on public.parcel_reports
  for insert with check (auth.role() = 'authenticated');

