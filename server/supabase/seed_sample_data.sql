-- Rich operational sample seed data for the current app schema.
-- Run this after:
-- 1. server/supabase/consolidated_schema.sql
-- 2. server/supabase/seed_users.sql

delete from public.parcel_history;
delete from public.alerts;
delete from public.activity_logs;
delete from public.parcel_reports;
delete from public.parcels;
delete from public.products;
delete from public.retail_orders;
delete from public.daily_metrics;

insert into public.products (sku, product_name, created_at)
values
  ('SKU-001', 'Bubble Wrap Large', '2026-03-10T08:00:00Z'),
  ('SKU-002', 'Packing Tape Heavy Duty', '2026-03-10T08:05:00Z'),
  ('SKU-003', 'Thermal Label Roll', '2026-03-10T08:10:00Z'),
  ('SKU-004', 'Poly Mailer Medium', '2026-03-10T08:15:00Z'),
  ('SKU-005', 'Fragile Sticker Pack', '2026-03-10T08:20:00Z'),
  ('SKU-006', 'Cardboard Box XL', '2026-03-10T08:25:00Z'),
  ('SKU-007', 'Stretch Film Roll', '2026-03-10T08:30:00Z'),
  ('SKU-008', 'Packing Foam Sheets', '2026-03-10T08:35:00Z')
on conflict (sku) do update
set
  product_name = excluded.product_name,
  created_at = excluded.created_at;

insert into public.parcels (
  id,
  tracking_number,
  platform,
  status,
  date_added,
  outbound_date,
  created_by,
  updated_by,
  created_at,
  updated_at
)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'SPX-000001-2026',
    'SPX',
    'Pending',
    '2026-03-29',
    null,
    '11111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    '2026-03-29T08:00:00Z',
    '2026-04-01T08:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'SPX-000002-2026',
    'SPX',
    'Outbound',
    '2026-03-30',
    '2026-03-31',
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-30T08:15:00Z',
    '2026-03-31T10:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'JNT-000001-2026',
    'JNT',
    'Pending',
    '2026-03-27',
    null,
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    '2026-03-27T09:00:00Z',
    '2026-04-01T08:35:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    'FLH-000001-2026',
    'FLH',
    'Cancelled',
    '2026-03-28',
    null,
    '44444444-4444-4444-4444-444444444444',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-28T10:00:00Z',
    '2026-03-31T11:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'LZD-000001-2026',
    'LZD',
    'Returned',
    '2026-03-26',
    null,
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-26T11:00:00Z',
    '2026-03-31T12:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
    'LZD-000002-2026',
    'LZD',
    'Outbound',
    '2026-03-31',
    '2026-03-31',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-31T07:45:00Z',
    '2026-03-31T13:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7',
    'SPX-000003-2026',
    'SPX',
    'Pending',
    '2026-03-30',
    null,
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-30T09:15:00Z',
    '2026-04-01T08:40:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8',
    'JNT-000002-2026',
    'JNT',
    'Outbound',
    '2026-03-31',
    '2026-04-01',
    '33333333-3333-3333-3333-333333333333',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-31T09:30:00Z',
    '2026-04-01T07:20:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9',
    'FLH-000002-2026',
    'FLH',
    'Pending',
    '2026-03-25',
    null,
    '44444444-4444-4444-4444-444444444444',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-25T08:20:00Z',
    '2026-04-01T08:45:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10',
    'LZD-000003-2026',
    'LZD',
    'Double Waybill',
    '2026-03-29',
    null,
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    '2026-03-29T14:00:00Z',
    '2026-04-01T08:50:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11',
    'SPX-000004-2026',
    'SPX',
    'Outbound',
    '2026-04-01',
    '2026-04-01',
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-04-01T06:45:00Z',
    '2026-04-01T09:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12',
    'JNT-000003-2026',
    'JNT',
    'Pending',
    '2026-03-24',
    null,
    '77777777-7777-7777-7777-777777777777',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-24T10:10:00Z',
    '2026-04-01T09:05:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13',
    'FLH-000003-2026',
    'FLH',
    'Returned',
    '2026-03-23',
    null,
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-23T12:30:00Z',
    '2026-04-01T09:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa14',
    'LZD-000004-2026',
    'LZD',
    'Pending',
    '2026-03-31',
    null,
    '88888888-8888-8888-8888-888888888880',
    '88888888-8888-8888-8888-888888888880',
    '2026-03-31T15:00:00Z',
    '2026-04-01T09:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15',
    'SPX-000005-2026',
    'SPX',
    'Pending',
    '2026-03-28',
    null,
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-28T13:10:00Z',
    '2026-04-01T09:22:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16',
    'JNT-000004-2026',
    'JNT',
    'Outbound',
    '2026-04-01',
    '2026-04-01',
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    '2026-04-01T07:10:00Z',
    '2026-04-01T09:25:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17',
    'FLH-000004-2026',
    'FLH',
    'Pending',
    '2026-03-27',
    null,
    '44444444-4444-4444-4444-444444444444',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-27T16:40:00Z',
    '2026-04-01T09:28:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18',
    'LZD-000005-2026',
    'LZD',
    'Cancelled',
    '2026-03-30',
    null,
    '88888888-8888-8888-8888-888888888880',
    '88888888-8888-8888-8888-888888888880',
    '2026-03-30T11:50:00Z',
    '2026-04-01T09:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19',
    'SPX-000006-2026',
    'SPX',
    'Returned',
    '2026-03-22',
    null,
    '66666666-6666-6666-6666-666666666666',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-22T09:05:00Z',
    '2026-04-01T09:34:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20',
    'JNT-000005-2026',
    'JNT',
    'Pending',
    '2026-03-31',
    null,
    '77777777-7777-7777-7777-777777777777',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-31T17:20:00Z',
    '2026-04-01T09:38:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21',
    'FLH-000005-2026',
    'FLH',
    'Double Waybill',
    '2026-04-01',
    null,
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T08:05:00Z',
    '2026-04-01T09:40:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22',
    'LZD-000006-2026',
    'LZD',
    'Outbound',
    '2026-04-01',
    '2026-04-01',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444',
    '2026-04-01T08:25:00Z',
    '2026-04-01T09:45:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23',
    'SPX-000007-2026',
    'SPX',
    'Pending',
    '2026-03-26',
    null,
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-26T08:10:00Z',
    '2026-04-01T09:50:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24',
    'SPX-000008-2026',
    'SPX',
    'Outbound',
    '2026-03-27',
    '2026-03-29',
    '22222222-2222-2222-2222-222222222222',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-27T09:25:00Z',
    '2026-03-29T14:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa25',
    'SPX-000009-2026',
    'SPX',
    'Pending',
    '2026-03-28',
    null,
    '22222222-2222-2222-2222-222222222222',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-28T10:35:00Z',
    '2026-04-01T09:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa26',
    'SPX-000010-2026',
    'SPX',
    'Returned',
    '2026-03-21',
    null,
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-21T11:10:00Z',
    '2026-03-30T15:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa27',
    'SPX-000011-2026',
    'SPX',
    'Cancelled',
    '2026-03-30',
    null,
    '88888888-8888-8888-8888-888888888880',
    '88888888-8888-8888-8888-888888888880',
    '2026-03-30T12:05:00Z',
    '2026-04-01T10:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa28',
    'JNT-000006-2026',
    'JNT',
    'Pending',
    '2026-03-25',
    null,
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    '2026-03-25T08:45:00Z',
    '2026-04-01T10:05:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa29',
    'JNT-000007-2026',
    'JNT',
    'Outbound',
    '2026-03-29',
    '2026-03-31',
    '33333333-3333-3333-3333-333333333333',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-29T07:50:00Z',
    '2026-03-31T16:05:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa30',
    'JNT-000008-2026',
    'JNT',
    'Pending',
    '2026-03-23',
    null,
    '77777777-7777-7777-7777-777777777777',
    '77777777-7777-7777-7777-777777777777',
    '2026-03-23T13:20:00Z',
    '2026-04-01T10:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa31',
    'JNT-000009-2026',
    'JNT',
    'Double Waybill',
    '2026-03-31',
    null,
    '33333333-3333-3333-3333-333333333333',
    '11111111-1111-1111-1111-111111111111',
    '2026-03-31T18:05:00Z',
    '2026-04-01T10:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa32',
    'JNT-000010-2026',
    'JNT',
    'Returned',
    '2026-03-20',
    null,
    '77777777-7777-7777-7777-777777777777',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-20T10:25:00Z',
    '2026-03-29T17:40:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa33',
    'FLH-000006-2026',
    'FLH',
    'Pending',
    '2026-03-24',
    null,
    '44444444-4444-4444-4444-444444444444',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-24T09:30:00Z',
    '2026-04-01T10:20:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa34',
    'FLH-000007-2026',
    'FLH',
    'Outbound',
    '2026-03-30',
    '2026-04-01',
    '44444444-4444-4444-4444-444444444444',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-30T10:05:00Z',
    '2026-04-01T10:25:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa35',
    'FLH-000008-2026',
    'FLH',
    'Pending',
    '2026-03-22',
    null,
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-03-22T15:20:00Z',
    '2026-04-01T10:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa36',
    'FLH-000009-2026',
    'FLH',
    'Cancelled',
    '2026-03-29',
    null,
    '44444444-4444-4444-4444-444444444444',
    '88888888-8888-8888-8888-888888888880',
    '2026-03-29T16:45:00Z',
    '2026-04-01T10:35:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa37',
    'FLH-000010-2026',
    'FLH',
    'Returned',
    '2026-03-19',
    null,
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-19T14:10:00Z',
    '2026-03-28T11:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa38',
    'LZD-000007-2026',
    'LZD',
    'Pending',
    '2026-03-27',
    null,
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-27T08:35:00Z',
    '2026-04-01T10:40:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa39',
    'LZD-000008-2026',
    'LZD',
    'Outbound',
    '2026-03-31',
    '2026-04-01',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444',
    '2026-03-31T09:40:00Z',
    '2026-04-01T10:45:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa40',
    'LZD-000009-2026',
    'LZD',
    'Pending',
    '2026-03-24',
    null,
    '88888888-8888-8888-8888-888888888880',
    '88888888-8888-8888-8888-888888888880',
    '2026-03-24T12:25:00Z',
    '2026-04-01T10:50:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa41',
    'LZD-000010-2026',
    'LZD',
    'Double Waybill',
    '2026-04-01',
    null,
    '88888888-8888-8888-8888-888888888880',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T08:45:00Z',
    '2026-04-01T10:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa42',
    'LZD-000011-2026',
    'LZD',
    'Returned',
    '2026-03-18',
    null,
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-18T10:50:00Z',
    '2026-03-27T13:20:00Z'
  );

insert into public.parcel_reports (
  id,
  parcel_id,
  tracking_number,
  remarks,
  status,
  reported_by,
  updated_by,
  reported_at,
  resolved_at,
  updated_at
)
values
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'JNT-000001-2026',
    'Pending parcel needs courier follow-up.',
    'Unresolved',
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    '2026-03-31T09:50:00Z',
    null,
    '2026-03-31T09:50:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    'FLH-000001-2026',
    'Cancellation reason confirmed with customer.',
    'Resolved',
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    '2026-03-31T11:05:00Z',
    '2026-03-31T11:30:00Z',
    '2026-03-31T11:30:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'LZD-000001-2026',
    'Returned parcel requires condition check.',
    'Unresolved',
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-31T12:05:00Z',
    null,
    '2026-03-31T12:05:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9',
    'FLH-000002-2026',
    'Parcel has exceeded dispatch SLA and needs escalation.',
    'Unresolved',
    '44444444-4444-4444-4444-444444444444',
    '66666666-6666-6666-6666-666666666666',
    '2026-04-01T08:50:00Z',
    null,
    '2026-04-01T08:50:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10',
    'LZD-000003-2026',
    'Double waybill detected during verification.',
    'Resolved',
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T08:55:00Z',
    '2026-04-01T09:20:00Z',
    '2026-04-01T09:20:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12',
    'JNT-000003-2026',
    'Pending parcel needs customer address reconfirmation.',
    'Unresolved',
    '77777777-7777-7777-7777-777777777777',
    '77777777-7777-7777-7777-777777777777',
    '2026-04-01T09:10:00Z',
    null,
    '2026-04-01T09:10:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15',
    'SPX-000005-2026',
    'Parcel has remained pending beyond expected weekend processing.',
    'Unresolved',
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-04-01T09:24:00Z',
    null,
    '2026-04-01T09:24:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb8',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21',
    'FLH-000005-2026',
    'Duplicate waybill needs relabeling before dispatch.',
    'Unresolved',
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T09:41:00Z',
    null,
    '2026-04-01T09:41:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb9',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23',
    'SPX-000007-2026',
    'Pending parcel requires manual follow-up after aging in queue.',
    'Unresolved',
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-04-01T09:50:00Z',
    null,
    '2026-04-01T09:50:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa28',
    'JNT-000006-2026',
    'Courier handoff delayed due to missing dispatch manifest.',
    'Unresolved',
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    '2026-04-01T10:05:00Z',
    null,
    '2026-04-01T10:05:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa30',
    'JNT-000008-2026',
    'Long-pending parcel needs customer contact verification.',
    'Unresolved',
    '77777777-7777-7777-7777-777777777777',
    '77777777-7777-7777-7777-777777777777',
    '2026-04-01T10:10:00Z',
    null,
    '2026-04-01T10:10:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa31',
    'JNT-000009-2026',
    'Duplicate waybill flagged during outbound verification.',
    'Resolved',
    '33333333-3333-3333-3333-333333333333',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T10:15:00Z',
    '2026-04-01T10:42:00Z',
    '2026-04-01T10:42:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb13',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa33',
    'FLH-000006-2026',
    'Parcel is waiting beyond SLA in flash holding area.',
    'Unresolved',
    '44444444-4444-4444-4444-444444444444',
    '66666666-6666-6666-6666-666666666666',
    '2026-04-01T10:20:00Z',
    null,
    '2026-04-01T10:20:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb14',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa35',
    'FLH-000008-2026',
    'Pending parcel needs warehouse rack audit before release.',
    'Unresolved',
    '66666666-6666-6666-6666-666666666666',
    '66666666-6666-6666-6666-666666666666',
    '2026-04-01T10:30:00Z',
    null,
    '2026-04-01T10:30:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb15',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa38',
    'LZD-000007-2026',
    'Parcel has not moved since intake and needs route review.',
    'Unresolved',
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    '2026-04-01T10:40:00Z',
    null,
    '2026-04-01T10:40:00Z'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb16',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa41',
    'LZD-000010-2026',
    'Second label detected and removed before dispatch cutoff.',
    'Resolved',
    '88888888-8888-8888-8888-888888888880',
    '11111111-1111-1111-1111-111111111111',
    '2026-04-01T10:55:00Z',
    '2026-04-01T11:12:00Z',
    '2026-04-01T11:12:00Z'
  );

insert into public.activity_logs (
  id,
  parcel_id,
  tracking_number,
  actor_id,
  actor_name,
  category,
  action,
  created_at
)
values
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc1',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'SPX-000001-2026',
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'parcel',
    'Parcel created with status Pending on SPX.',
    '2026-03-29T08:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc2',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'SPX-000002-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-03-31T10:15:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc3',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'JNT-000001-2026',
    '33333333-3333-3333-3333-333333333333',
    'Mike Chen',
    'report',
    'Issue reported: Pending parcel needs courier follow-up.',
    '2026-03-31T09:50:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc4',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    'FLH-000001-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'parcel',
    'Parcel scanned: status changed to Cancelled.',
    '2026-03-31T11:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc5',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'LZD-000001-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-03-31T12:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc6',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
    'LZD-000002-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-03-31T13:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc7',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7',
    'SPX-000003-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'parcel',
    'Parcel created and queued for afternoon sort.',
    '2026-03-30T09:15:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc8',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8',
    'JNT-000002-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'parcel',
    'Parcel loaded for courier departure.',
    '2026-04-01T07:20:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc9',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9',
    'FLH-000002-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'report',
    'Issue reported: Parcel exceeded dispatch SLA.',
    '2026-04-01T08:50:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc10',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10',
    'LZD-000003-2026',
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'report',
    'Issue resolved: Duplicate waybill cleared after validation.',
    '2026-04-01T09:20:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc11',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11',
    'SPX-000004-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-04-01T09:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc12',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12',
    'JNT-000003-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'report',
    'Issue reported: Address reconfirmation requested from customer.',
    '2026-04-01T09:10:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc13',
    null,
    null,
    '88888888-8888-8888-8888-888888888880',
    'Lea Santos',
    'user',
    'Reviewed daily parcel exception summary.',
    '2026-04-01T08:25:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc14',
    null,
    null,
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'auth',
    'Admin session authenticated successfully.',
    '2026-04-01T08:10:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc15',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15',
    'SPX-000005-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'report',
    'Issue reported: Parcel pending beyond expected weekend processing.',
    '2026-04-01T09:24:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc16',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16',
    'JNT-000004-2026',
    '33333333-3333-3333-3333-333333333333',
    'Mike Chen',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-04-01T09:25:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc17',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17',
    'FLH-000004-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'parcel',
    'Parcel escalated for delayed dispatch review.',
    '2026-04-01T09:28:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc18',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18',
    'LZD-000005-2026',
    '88888888-8888-8888-8888-888888888880',
    'Lea Santos',
    'parcel',
    'Parcel scanned: status changed to Cancelled.',
    '2026-04-01T09:30:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc19',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19',
    'SPX-000006-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-04-01T09:34:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc20',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20',
    'JNT-000005-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'parcel',
    'Parcel created and queued for route assignment.',
    '2026-04-01T09:38:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc21',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21',
    'FLH-000005-2026',
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'report',
    'Issue reported: Duplicate waybill needs relabeling.',
    '2026-04-01T09:41:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc22',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22',
    'LZD-000006-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'parcel',
    'Parcel loaded and marked outbound before noon pickup.',
    '2026-04-01T09:45:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc23',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23',
    'SPX-000007-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'report',
    'Issue reported: Parcel aged in queue and needs manual follow-up.',
    '2026-04-01T09:50:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc24',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24',
    'SPX-000008-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-03-29T14:10:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc25',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa25',
    'SPX-000009-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'parcel',
    'Parcel awaiting space on next courier batch.',
    '2026-04-01T09:55:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc26',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa26',
    'SPX-000010-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-03-30T15:30:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc27',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa27',
    'SPX-000011-2026',
    '88888888-8888-8888-8888-888888888880',
    'Lea Santos',
    'parcel',
    'Parcel scanned: status changed to Cancelled.',
    '2026-04-01T10:00:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc28',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa28',
    'JNT-000006-2026',
    '33333333-3333-3333-3333-333333333333',
    'Mike Chen',
    'report',
    'Issue reported: Missing dispatch manifest delayed handoff.',
    '2026-04-01T10:05:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc29',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa29',
    'JNT-000007-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-03-31T16:05:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc30',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa30',
    'JNT-000008-2026',
    '77777777-7777-7777-7777-777777777777',
    'Carlos Garcia',
    'report',
    'Issue reported: Customer contact verification required.',
    '2026-04-01T10:10:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc31',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa31',
    'JNT-000009-2026',
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'report',
    'Issue resolved: Duplicate waybill removed and relabeled.',
    '2026-04-01T10:42:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc32',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa32',
    'JNT-000010-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-03-29T17:40:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc33',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa33',
    'FLH-000006-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'report',
    'Issue reported: Holding area SLA breached.',
    '2026-04-01T10:20:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc34',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa34',
    'FLH-000007-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-04-01T10:25:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc35',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa35',
    'FLH-000008-2026',
    '66666666-6666-6666-6666-666666666666',
    'Nina Reyes',
    'report',
    'Issue reported: Rack audit required before release.',
    '2026-04-01T10:30:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc36',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa36',
    'FLH-000009-2026',
    '88888888-8888-8888-8888-888888888880',
    'Lea Santos',
    'parcel',
    'Parcel scanned: status changed to Cancelled.',
    '2026-04-01T10:35:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc37',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa37',
    'FLH-000010-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-03-28T11:55:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc38',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa38',
    'LZD-000007-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'report',
    'Issue reported: Route review required for stalled parcel.',
    '2026-04-01T10:40:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc39',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa39',
    'LZD-000008-2026',
    '44444444-4444-4444-4444-444444444444',
    'David Martinez',
    'parcel',
    'Parcel scanned: status changed to Outbound.',
    '2026-04-01T10:45:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc40',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa40',
    'LZD-000009-2026',
    '88888888-8888-8888-8888-888888888880',
    'Lea Santos',
    'parcel',
    'Parcel remains pending while retailer confirms address details.',
    '2026-04-01T10:50:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc41',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa41',
    'LZD-000010-2026',
    '11111111-1111-1111-1111-111111111111',
    'Dev User',
    'report',
    'Issue resolved: Duplicate label removed before dispatch window.',
    '2026-04-01T11:12:00Z'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccc42',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa42',
    'LZD-000011-2026',
    '22222222-2222-2222-2222-222222222222',
    'Sarah Johnson',
    'parcel',
    'Parcel scanned: status changed to Returned.',
    '2026-03-27T13:20:00Z'
  );

insert into public.alerts (
  parcel_id,
  tracking_number,
  type,
  message,
  days_pending,
  is_read,
  created_at
)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'SPX-000001-2026',
    'warning',
    'SPX-000001-2026 has been pending for 3 days.',
    3,
    false,
    '2026-04-01T08:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'JNT-000001-2026',
    'critical',
    'JNT-000001-2026 has been pending for 5 days.',
    5,
    false,
    '2026-04-01T08:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7',
    'SPX-000003-2026',
    'warning',
    'SPX-000003-2026 has been pending for 2 days.',
    2,
    false,
    '2026-04-01T08:20:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9',
    'FLH-000002-2026',
    'critical',
    'FLH-000002-2026 has been pending for 7 days.',
    7,
    false,
    '2026-04-01T08:25:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa12',
    'JNT-000003-2026',
    'critical',
    'JNT-000003-2026 has been pending for 8 days.',
    8,
    false,
    '2026-04-01T09:12:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa14',
    'LZD-000004-2026',
    'warning',
    'LZD-000004-2026 has been pending for 1 day.',
    1,
    true,
    '2026-04-01T09:18:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa15',
    'SPX-000005-2026',
    'warning',
    'SPX-000005-2026 has been pending for 4 days.',
    4,
    false,
    '2026-04-01T09:24:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa17',
    'FLH-000004-2026',
    'critical',
    'FLH-000004-2026 has been pending for 5 days.',
    5,
    false,
    '2026-04-01T09:28:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa20',
    'JNT-000005-2026',
    'warning',
    'JNT-000005-2026 has been pending for 1 day.',
    1,
    false,
    '2026-04-01T09:38:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21',
    'FLH-000005-2026',
    'critical',
    'FLH-000005-2026 requires relabeling due to a double waybill.',
    null,
    false,
    '2026-04-01T09:41:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa23',
    'SPX-000007-2026',
    'warning',
    'SPX-000007-2026 has been pending for 6 days.',
    6,
    false,
    '2026-04-01T09:50:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa25',
    'SPX-000009-2026',
    'warning',
    'SPX-000009-2026 has been pending for 4 days.',
    4,
    false,
    '2026-04-01T09:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa28',
    'JNT-000006-2026',
    'critical',
    'JNT-000006-2026 is blocked by a missing dispatch manifest.',
    null,
    false,
    '2026-04-01T10:05:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa30',
    'JNT-000008-2026',
    'critical',
    'JNT-000008-2026 has been pending for 9 days.',
    9,
    false,
    '2026-04-01T10:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa33',
    'FLH-000006-2026',
    'critical',
    'FLH-000006-2026 has been pending for 8 days.',
    8,
    false,
    '2026-04-01T10:20:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa35',
    'FLH-000008-2026',
    'warning',
    'FLH-000008-2026 has been pending for 10 days.',
    10,
    false,
    '2026-04-01T10:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa38',
    'LZD-000007-2026',
    'warning',
    'LZD-000007-2026 has been pending for 5 days.',
    5,
    false,
    '2026-04-01T10:40:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa40',
    'LZD-000009-2026',
    'critical',
    'LZD-000009-2026 has been pending for 8 days.',
    8,
    false,
    '2026-04-01T10:50:00Z'
  );

update public.alerts
set
  state = 'assigned',
  is_read = true,
  read_at = '2026-04-01T08:22:00Z',
  assigned_to = '22222222-2222-2222-2222-222222222222',
  assigned_at = '2026-04-01T08:22:00Z',
  last_action = 'assigned:PP-000002',
  last_action_by = '11111111-1111-1111-1111-111111111111',
  updated_at = '2026-04-01T08:22:00Z'
where parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3';

update public.alerts
set
  state = 'acknowledged',
  is_read = true,
  read_at = '2026-04-01T08:57:00Z',
  acknowledged_at = '2026-04-01T08:57:00Z',
  last_action = 'acknowledged',
  last_action_by = '66666666-6666-6666-6666-666666666666',
  updated_at = '2026-04-01T08:57:00Z'
where parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9';

update public.alerts
set
  visible_to_role = 'admin',
  escalation_level = 2,
  escalated_at = '2026-04-01T10:35:00Z',
  last_action = 'escalated',
  last_action_by = '88888888-8888-8888-8888-888888888880',
  updated_at = '2026-04-01T10:35:00Z'
where parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa35';

insert into public.alerts (
  parcel_id,
  tracking_number,
  type,
  message,
  days_pending,
  state,
  is_read,
  read_at,
  resolved_at,
  last_action,
  last_action_by,
  created_at,
  updated_at
)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'LZD-000001-2026',
    'warning',
    'LZD-000001-2026 was previously escalated for delayed delivery and has since been resolved.',
    4,
    'resolved',
    true,
    '2026-03-31T12:08:00Z',
    '2026-03-31T12:12:00Z',
    'flagged_for_review',
    '22222222-2222-2222-2222-222222222222',
    '2026-03-31T12:05:00Z',
    '2026-03-31T12:12:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8',
    'JNT-000002-2026',
    'warning',
    'JNT-000002-2026 alert was dismissed after manual courier confirmation.',
    2,
    'archived',
    true,
    '2026-04-01T07:18:00Z',
    null,
    'dismissed',
    '77777777-7777-7777-7777-777777777777',
    '2026-04-01T07:10:00Z',
    '2026-04-01T07:18:00Z'
  )
on conflict (parcel_id) do update
set
  tracking_number = excluded.tracking_number,
  type = excluded.type,
  message = excluded.message,
  days_pending = excluded.days_pending,
  state = excluded.state,
  is_read = excluded.is_read,
  read_at = excluded.read_at,
  resolved_at = excluded.resolved_at,
  last_action = excluded.last_action,
  last_action_by = excluded.last_action_by,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at;

insert into public.notification_events (
  alert_id,
  parcel_id,
  actor_id,
  event_type,
  previous_state,
  next_state,
  metadata,
  created_at
)
select
  a.id,
  a.parcel_id,
  '11111111-1111-1111-1111-111111111111',
  'assigned',
  'new',
  'assigned',
  jsonb_build_object('assignedTo', 'PP-000002'),
  '2026-04-01T08:22:00Z'
from public.alerts a
where a.parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3';

insert into public.notification_events (
  alert_id,
  parcel_id,
  actor_id,
  event_type,
  previous_state,
  next_state,
  metadata,
  created_at
)
select
  a.id,
  a.parcel_id,
  '66666666-6666-6666-6666-666666666666',
  'acknowledged',
  'new',
  'acknowledged',
  jsonb_build_object('note', 'Ops team started manual follow-up'),
  '2026-04-01T08:57:00Z'
from public.alerts a
where a.parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9';

insert into public.notification_events (
  alert_id,
  parcel_id,
  actor_id,
  event_type,
  previous_state,
  next_state,
  metadata,
  created_at
)
select
  a.id,
  a.parcel_id,
  '22222222-2222-2222-2222-222222222222',
  'flagged_for_review',
  'acknowledged',
  'resolved',
  jsonb_build_object('reportStatus', 'Unresolved'),
  '2026-03-31T12:12:00Z'
from public.alerts a
where a.parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5';

insert into public.notification_events (
  alert_id,
  parcel_id,
  actor_id,
  event_type,
  previous_state,
  next_state,
  metadata,
  created_at
)
select
  a.id,
  a.parcel_id,
  '77777777-7777-7777-7777-777777777777',
  'archived',
  'read',
  'archived',
  jsonb_build_object('reason', 'dismissed'),
  '2026-04-01T07:18:00Z'
from public.alerts a
where a.parcel_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8';

insert into public.daily_metrics (
  metric_date,
  total_parcels,
  received_today,
  dispatched_today,
  pending_count,
  issues_open,
  created_at
)
values
  ('2026-03-26', 8, 2, 0, 4, 2, '2026-03-26T23:59:00Z'),
  ('2026-03-27', 14, 3, 1, 6, 3, '2026-03-27T23:59:00Z'),
  ('2026-03-28', 18, 4, 1, 7, 4, '2026-03-28T23:59:00Z'),
  ('2026-03-29', 24, 4, 3, 9, 5, '2026-03-29T23:59:00Z'),
  ('2026-03-30', 30, 4, 4, 10, 6, '2026-03-30T23:59:00Z'),
  ('2026-03-31', 36, 5, 6, 12, 7, '2026-03-31T23:59:00Z'),
  ('2026-04-01', 42, 6, 9, 18, 12, '2026-04-01T23:59:00Z')
on conflict (metric_date) do update
set
  total_parcels = excluded.total_parcels,
  received_today = excluded.received_today,
  dispatched_today = excluded.dispatched_today,
  pending_count = excluded.pending_count,
  issues_open = excluded.issues_open,
  created_at = excluded.created_at;

insert into public.parcel_history (
  parcel_id,
  changed_by,
  old_status,
  new_status,
  note,
  created_at
)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    '22222222-2222-2222-2222-222222222222',
    'Pending',
    'Outbound',
    'Prepared for same-day handoff.',
    '2026-03-31T10:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    '44444444-4444-4444-4444-444444444444',
    'Pending',
    'Cancelled',
    'Customer requested cancellation before dispatch.',
    '2026-03-31T11:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Recipient unavailable after multiple attempts.',
    '2026-03-31T12:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
    '44444444-4444-4444-4444-444444444444',
    'Pending',
    'Outbound',
    'Loaded for courier departure.',
    '2026-03-31T13:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8',
    '77777777-7777-7777-7777-777777777777',
    'Pending',
    'Outbound',
    'Manifest confirmed for first morning route.',
    '2026-04-01T07:20:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10',
    '11111111-1111-1111-1111-111111111111',
    'Pending',
    'Double Waybill',
    'Duplicate label attached during packing verification.',
    '2026-04-01T08:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11',
    '66666666-6666-6666-6666-666666666666',
    'Pending',
    'Outbound',
    'Sorted into outbound cage before 9 AM dispatch.',
    '2026-04-01T09:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa13',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Courier returned parcel after failed recipient confirmation.',
    '2026-04-01T09:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa16',
    '33333333-3333-3333-3333-333333333333',
    'Pending',
    'Outbound',
    'Transferred to outbound lane after morning verification.',
    '2026-04-01T09:25:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa18',
    '88888888-8888-8888-8888-888888888880',
    'Pending',
    'Cancelled',
    'Retailer requested cancellation before courier handoff.',
    '2026-04-01T09:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa19',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Parcel returned after failed recipient contact attempt.',
    '2026-04-01T09:34:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa21',
    '11111111-1111-1111-1111-111111111111',
    'Pending',
    'Double Waybill',
    'Second duplicate label detected during loading review.',
    '2026-04-01T09:41:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa22',
    '44444444-4444-4444-4444-444444444444',
    'Pending',
    'Outbound',
    'Assigned to noon route and released for dispatch.',
    '2026-04-01T09:45:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa24',
    '66666666-6666-6666-6666-666666666666',
    'Pending',
    'Outbound',
    'Moved to outbound lane after scan verification.',
    '2026-03-29T14:10:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa26',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Parcel returned after recipient could not be reached.',
    '2026-03-30T15:30:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa27',
    '88888888-8888-8888-8888-888888888880',
    'Pending',
    'Cancelled',
    'Retailer cancelled before staging for dispatch.',
    '2026-04-01T10:00:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa29',
    '77777777-7777-7777-7777-777777777777',
    'Pending',
    'Outbound',
    'Released to JNT after manifest confirmation.',
    '2026-03-31T16:05:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa31',
    '11111111-1111-1111-1111-111111111111',
    'Pending',
    'Double Waybill',
    'Duplicate airway bill removed and incident logged.',
    '2026-04-01T10:15:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa34',
    '44444444-4444-4444-4444-444444444444',
    'Pending',
    'Outbound',
    'Moved to outbound rack during 10 AM release.',
    '2026-04-01T10:25:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa36',
    '88888888-8888-8888-8888-888888888880',
    'Pending',
    'Cancelled',
    'Merchant canceled the parcel before van loading.',
    '2026-04-01T10:35:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa37',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Parcel came back after failed destination handoff.',
    '2026-03-28T11:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa39',
    '44444444-4444-4444-4444-444444444444',
    'Pending',
    'Outbound',
    'Released to Lazada courier before lunch window.',
    '2026-04-01T10:45:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa41',
    '11111111-1111-1111-1111-111111111111',
    'Pending',
    'Double Waybill',
    'Second waybill detected and removed during final QA.',
    '2026-04-01T10:55:00Z'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa42',
    '22222222-2222-2222-2222-222222222222',
    'Outbound',
    'Returned',
    'Parcel returned after unsuccessful multiple delivery attempts.',
    '2026-03-27T13:20:00Z'
  );

insert into public.retail_orders (
  order_uuid,
  status,
  retailer,
  payment_status,
  payment_terms,
  due_date,
  channel,
  cancel_reason,
  created_at,
  updated_at
)
values
  (
    '99999999-9999-9999-9999-999999999999',
    'pending',
    'SPX Partner Store',
    'pending',
    'N/A',
    '2026-04-05',
    'email',
    null,
    '2026-03-31T08:20:00Z',
    '2026-03-31T08:20:00Z'
  ),
  (
    '88888888-8888-8888-8888-888888888888',
    'dispatched',
    'LZD Merchant',
    'partial',
    'Net 15',
    '2026-04-07',
    'whatsapp',
    null,
    '2026-03-31T08:30:00Z',
    '2026-03-31T13:10:00Z'
  ),
  (
    '77777777-7777-7777-7777-777777777778',
    'fulfilled',
    'JNT Corporate',
    'paid',
    'Net 7',
    '2026-04-03',
    'email',
    null,
    '2026-03-29T07:30:00Z',
    '2026-04-01T09:00:00Z'
  ),
  (
    '66666666-6666-6666-6666-666666666667',
    'pending',
    'Flash Fulfillment Hub',
    'delayed',
    'Net 30',
    '2026-04-10',
    'phone',
    null,
    '2026-03-30T09:00:00Z',
    '2026-04-01T08:35:00Z'
  ),
  (
    '55555555-5555-5555-5555-555555555556',
    'cancelled',
    'Marketplace Bulk Buyer',
    'pending',
    'N/A',
    '2026-04-04',
    'viber',
    'Customer requested order hold cancellation.',
    '2026-03-30T10:45:00Z',
    '2026-03-31T11:15:00Z'
  ),
  (
    '44444444-4444-4444-4444-444444444445',
    'dispatched',
    'Warehouse Resupply',
    'paid',
    'COD',
    '2026-04-02',
    'email',
    null,
    '2026-04-01T06:30:00Z',
    '2026-04-01T09:05:00Z'
  )
on conflict (order_uuid) do update
set
  status = excluded.status,
  retailer = excluded.retailer,
  payment_status = excluded.payment_status,
  payment_terms = excluded.payment_terms,
  due_date = excluded.due_date,
  channel = excluded.channel,
  cancel_reason = excluded.cancel_reason,
  created_at = excluded.created_at,
  updated_at = excluded.updated_at;
