-- User and organization seed data for the current app schema.
-- Run this after server/supabase/consolidated_schema.sql

update public.organization_settings
set
  registration_code_hash = null,
  registration_code_updated_at = null,
  registration_code_updated_by = null;

delete from public.app_users;

insert into public.app_users (
  id,
  user_id,
  first_name,
  last_name,
  role,
  status,
  status_reason,
  password_hash,
  created_at,
  updated_at,
  last_login_at
)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'PP-000001',
    'Dev',
    'User',
    'admin',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-01T08:00:00Z',
    '2026-04-01T08:00:00Z',
    '2026-04-01T08:10:00Z'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'PP-000002',
    'Sarah',
    'Johnson',
    'staff',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-02T08:00:00Z',
    '2026-04-01T08:05:00Z',
    '2026-04-01T08:05:00Z'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'PP-000003',
    'Mike',
    'Chen',
    'staff',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-03T08:00:00Z',
    '2026-04-01T08:07:00Z',
    '2026-04-01T08:07:00Z'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'PP-000004',
    'David',
    'Martinez',
    'staff',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-04T08:00:00Z',
    '2026-04-01T08:09:00Z',
    '2026-04-01T08:09:00Z'
  ),
  (
    '55555555-5555-5555-5555-555555555555',
    'PP-000005',
    'Emma',
    'Wilson',
    'staff',
    'inactive',
    'On leave',
    '$2b$10$samplehashreplaceinapp',
    '2026-03-05T08:00:00Z',
    '2026-03-30T16:00:00Z',
    '2026-03-29T09:20:00Z'
  ),
  (
    '66666666-6666-6666-6666-666666666666',
    'PP-000006',
    'Nina',
    'Reyes',
    'staff',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-06T08:00:00Z',
    '2026-04-01T07:40:00Z',
    '2026-04-01T07:40:00Z'
  ),
  (
    '77777777-7777-7777-7777-777777777777',
    'PP-000007',
    'Carlos',
    'Garcia',
    'staff',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-07T08:00:00Z',
    '2026-04-01T07:55:00Z',
    '2026-04-01T07:55:00Z'
  ),
  (
    '88888888-8888-8888-8888-888888888880',
    'PP-000008',
    'Lea',
    'Santos',
    'admin',
    'active',
    null,
    '$2b$10$samplehashreplaceinapp',
    '2026-03-08T08:00:00Z',
    '2026-04-01T08:20:00Z',
    '2026-04-01T08:20:00Z'
  );

insert into public.organization_settings (
  id,
  registration_code_hash,
  registration_code_updated_at,
  registration_code_updated_by
)
values (
  true,
  'a5912d56f8b71f2df0b969764f17be61:78cf881d2d12f0dd896514694b0d786af32b220191ea51018cb57e11b3d1d1bcb2f8b4eeb8b0f50cd5468e76e282248b76fe2fcd13779526c9027b38e0e2060b',
  '2026-04-01T08:15:00Z',
  '11111111-1111-1111-1111-111111111111'
)
on conflict (id) do update
set
  registration_code_hash = excluded.registration_code_hash,
  registration_code_updated_at = excluded.registration_code_updated_at,
  registration_code_updated_by = excluded.registration_code_updated_by;
