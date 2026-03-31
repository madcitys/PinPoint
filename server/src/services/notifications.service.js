import { supabase } from '../lib/supabase.js';
import { throwIfSupabaseError } from '../utils/database.js';
import { HttpError } from '../utils/httpError.js';
import { createReport } from './reports.service.js';
import { updateParcel } from './parcels.service.js';
import { getUserById } from './users.service.js';

const WARNING_THRESHOLD_DAYS = 2;
const CRITICAL_THRESHOLD_DAYS = 8;
const ADMIN_VISIBILITY_THRESHOLD_DAYS = 10;

const ACTIVE_ALERT_STATES = ['new', 'read', 'acknowledged', 'assigned'];

const ALERT_SELECT = `
  id,
  parcel_id,
  tracking_number,
  type,
  message,
  days_pending,
  state,
  is_read,
  read_at,
  assigned_to,
  assigned_at,
  acknowledged_at,
  resolved_at,
  archived_at,
  escalated_at,
  escalation_level,
  reopened_count,
  last_qualified_at,
  last_action,
  last_action_by,
  visible_to_role,
  version,
  created_at,
  updated_at,
  parcels!alerts_parcel_id_fkey(platform,status,date_added),
  assigned_user:app_users!alerts_assigned_to_fkey(id,user_id,first_name,last_name,role),
  action_user:app_users!alerts_last_action_by_fkey(id,user_id,first_name,last_name,role)
`;

function nowIso() {
  return new Date().toISOString();
}

function startOfDayIso(dateOnly) {
  return `${dateOnly}T00:00:00.000Z`;
}

function endOfDayIso(dateOnly) {
  return `${dateOnly}T23:59:59.999Z`;
}

function daysSince(dateValue) {
  if (!dateValue) {
    return 0;
  }

  const target = new Date(dateValue);
  const now = new Date();
  const diff = now.getTime() - target.getTime();
  return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
}

function getVisibilityRole(daysPending) {
  return daysPending >= ADMIN_VISIBILITY_THRESHOLD_DAYS ? 'admin' : 'staff';
}

function buildAlertPayload(parcel) {
  const daysPending = daysSince(parcel.date_added);

  if (daysPending < WARNING_THRESHOLD_DAYS) {
    return null;
  }

  const severity = daysPending >= CRITICAL_THRESHOLD_DAYS ? 'critical' : 'warning';

  return {
    parcel_id: parcel.id,
    tracking_number: parcel.tracking_number,
    type: severity,
    message: `Tracking Number: ${parcel.tracking_number} has been pending for ${daysPending} day${daysPending === 1 ? '' : 's'}.`,
    days_pending: daysPending,
    visible_to_role: getVisibilityRole(daysPending),
    escalation_level: severity === 'critical' ? 1 : 0,
  };
}

function mapMiniUser(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    userId: row.user_id,
    fullName: `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim(),
    role: row.role,
  };
}

function mapAlert(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    parcelId: row.parcel_id,
    trackingNumber: row.tracking_number,
    severity: row.type,
    message: row.message,
    state: row.state,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    version: row.version,
    isRead: row.is_read,
    readAt: row.read_at,
    acknowledgedAt: row.acknowledged_at,
    resolvedAt: row.resolved_at,
    archivedAt: row.archived_at,
    assignedAt: row.assigned_at,
    escalatedAt: row.escalated_at,
    escalationLevel: row.escalation_level,
    reopenedCount: row.reopened_count,
    visibleToRole: row.visible_to_role,
    lastAction: row.last_action,
    lastQualifiedAt: row.last_qualified_at,
    assignedTo: mapMiniUser(row.assigned_user),
    lastActionBy: mapMiniUser(row.action_user),
    meta: {
      daysPending: row.days_pending,
      platform: row.parcels?.platform ?? null,
      status: row.parcels?.status ?? null,
      dateAdded: row.parcels?.date_added ?? null,
    },
  };
}

async function insertNotificationEvent({
  alertId,
  parcelId,
  actorId = null,
  eventType,
  previousState = null,
  nextState = null,
  metadata = {},
}) {
  const { error } = await supabase.from('notification_events').insert({
    alert_id: alertId,
    parcel_id: parcelId,
    actor_id: actorId,
    event_type: eventType,
    previous_state: previousState,
    next_state: nextState,
    metadata,
  });

  throwIfSupabaseError(error);
}

async function getAlertRowById(id) {
  const { data, error } = await supabase.from('alerts').select(ALERT_SELECT).eq('id', id).maybeSingle();
  throwIfSupabaseError(error);
  return data;
}

function assertExpectedVersion(alert, expectedVersion) {
  if (expectedVersion === undefined || expectedVersion === null) {
    return;
  }

  if (Number(alert.version) !== Number(expectedVersion)) {
    throw new HttpError(409, 'This notification changed in another session. Refresh and try again.');
  }
}

function assertActiveAlert(alert, actionLabel) {
  if (!alert) {
    throw new HttpError(404, 'Notification not found.');
  }

  if (!ACTIVE_ALERT_STATES.includes(alert.state)) {
    throw new HttpError(409, `This notification cannot be ${actionLabel} because it is already ${alert.state}.`);
  }
}

async function updateAlertRecord(alert, changes, options = {}) {
  const { actorId = null, eventType = 'updated', eventMetadata = {}, expectedVersion } = options;

  assertExpectedVersion(alert, expectedVersion);

  const payload = {
    ...changes,
    version: Number(alert.version ?? 1) + 1,
  };

  if (actorId) {
    payload.last_action_by = actorId;
  }

  let query = supabase.from('alerts').update(payload).eq('id', alert.id);

  if (expectedVersion !== undefined && expectedVersion !== null) {
    query = query.eq('version', Number(expectedVersion));
  }

  const { data, error } = await query.select(ALERT_SELECT).maybeSingle();
  throwIfSupabaseError(error);

  if (!data) {
    throw new HttpError(409, 'This notification changed in another session. Refresh and try again.');
  }

  if (eventType) {
    await insertNotificationEvent({
      alertId: data.id,
      parcelId: data.parcel_id,
      actorId,
      eventType,
      previousState: alert.state,
      nextState: data.state,
      metadata: eventMetadata,
    });
  }

  return data;
}

async function resolveAlertInternally(alert, { actorId = null, reason, eventType = 'resolved', expectedVersion } = {}) {
  const timestamp = nowIso();

  return updateAlertRecord(
    alert,
    {
      state: 'resolved',
      is_read: true,
      read_at: alert.read_at ?? timestamp,
      acknowledged_at: alert.acknowledged_at ?? timestamp,
      resolved_at: timestamp,
      archived_at: null,
      last_action: reason ?? 'resolved',
    },
    {
      actorId,
      eventType,
      eventMetadata: { reason: reason ?? 'resolved' },
      expectedVersion,
    },
  );
}

async function archiveAlertInternally(alert, { actorId = null, reason, expectedVersion } = {}) {
  const timestamp = nowIso();

  return updateAlertRecord(
    alert,
    {
      state: 'archived',
      is_read: true,
      read_at: alert.read_at ?? timestamp,
      archived_at: timestamp,
      last_action: reason ?? 'archived',
    },
    {
      actorId,
      eventType: 'archived',
      eventMetadata: { reason: reason ?? 'archived' },
      expectedVersion,
    },
  );
}

function applyVisibilityFilter(query, currentUser) {
  if (!currentUser || currentUser.role === 'admin') {
    return query;
  }

  return query.eq('visible_to_role', 'staff');
}

function applyListFilters(query, filters) {
  let next = query;

  if (filters.severity) {
    next = next.eq('type', filters.severity);
  }

  if (filters.search) {
    next = next.ilike('tracking_number', `%${filters.search}%`);
  }

  if (filters.dateFrom) {
    next = next.gte('created_at', startOfDayIso(filters.dateFrom));
  }

  if (filters.dateTo) {
    next = next.lte('created_at', endOfDayIso(filters.dateTo));
  }

  if (filters.assignedTo) {
    next = next.eq('assigned_to', filters.assignedTo);
  }

  if (filters.state === 'active' || !filters.state) {
    next = next.in('state', ACTIVE_ALERT_STATES);
  } else if (filters.state === 'mine') {
    next = next.eq('assigned_to', filters.currentUser?.id ?? '__none__').in('state', ACTIVE_ALERT_STATES);
  } else if (filters.state === 'all') {
    return next;
  } else {
    next = next.eq('state', filters.state);
  }

  return next;
}

async function buildNotificationSummary(filters) {
  let summaryQuery = supabase.from('alerts').select('id,state,type,assigned_to,created_at');
  summaryQuery = applyVisibilityFilter(summaryQuery, filters.currentUser);
  summaryQuery = applyListFilters(summaryQuery, { ...filters, state: 'all' });

  const { data, error } = await summaryQuery.limit(10000);
  throwIfSupabaseError(error);

  const rows = data ?? [];
  const now = new Date();
  const startOfWeek = new Date(now);
  startOfWeek.setHours(0, 0, 0, 0);
  startOfWeek.setDate(now.getDate() - now.getDay());

  return {
    total: rows.length,
    active: rows.filter((row) => ACTIVE_ALERT_STATES.includes(row.state)).length,
    archived: rows.filter((row) => row.state === 'archived').length,
    resolved: rows.filter((row) => row.state === 'resolved').length,
    warning: rows.filter((row) => row.type === 'warning' && ACTIVE_ALERT_STATES.includes(row.state)).length,
    critical: rows.filter((row) => row.type === 'critical' && ACTIVE_ALERT_STATES.includes(row.state)).length,
    assignedToMe: filters.currentUser ? rows.filter((row) => row.assigned_to === filters.currentUser.id).length : 0,
    thisWeek: rows.filter((row) => {
      const createdAt = new Date(row.created_at);
      return !Number.isNaN(createdAt.getTime()) && createdAt >= startOfWeek;
    }).length,
  };
}

export async function syncAlerts() {
  const timestamp = nowIso();

  const [{ data: pendingParcels, error: parcelsError }, { data: existingAlerts, error: alertsError }] = await Promise.all([
    supabase.from('parcels').select('id,tracking_number,platform,status,date_added').eq('status', 'Pending').limit(10000),
    supabase
      .from('alerts')
      .select(
        'id,parcel_id,tracking_number,type,message,days_pending,state,is_read,assigned_to,assigned_at,acknowledged_at,resolved_at,archived_at,escalated_at,escalation_level,reopened_count,last_qualified_at,last_action,visible_to_role,version',
      )
      .limit(10000),
  ]);

  throwIfSupabaseError(parcelsError);
  throwIfSupabaseError(alertsError);

  const nextAlerts = new Map();
  for (const parcel of pendingParcels ?? []) {
    const payload = buildAlertPayload(parcel);
    if (payload) {
      nextAlerts.set(payload.parcel_id, payload);
    }
  }

  const existingByParcelId = new Map((existingAlerts ?? []).map((alert) => [alert.parcel_id, alert]));

  for (const [parcelId, payload] of nextAlerts.entries()) {
    const existing = existingByParcelId.get(parcelId);

    if (!existing) {
      const insertPayload = {
        ...payload,
        state: 'new',
        is_read: false,
        escalated_at: payload.escalation_level > 0 ? timestamp : null,
        last_qualified_at: timestamp,
        last_action: 'created',
      };

      const { data, error } = await supabase.from('alerts').insert(insertPayload).select('id,parcel_id,state').single();
      throwIfSupabaseError(error);

      await insertNotificationEvent({
        alertId: data.id,
        parcelId: data.parcel_id,
        eventType: 'created',
        nextState: data.state,
        metadata: { severity: payload.type, daysPending: payload.days_pending },
      });
      continue;
    }

    const updatePayload = {
      tracking_number: payload.tracking_number,
      type: payload.type,
      message: payload.message,
      days_pending: payload.days_pending,
      visible_to_role: payload.visible_to_role,
      escalation_level: payload.escalation_level,
      last_qualified_at: timestamp,
    };

    let eventType = 'updated';
    const eventMetadata = {
      severity: payload.type,
      daysPending: payload.days_pending,
    };

    if (payload.escalation_level > Number(existing.escalation_level ?? 0)) {
      updatePayload.escalated_at = timestamp;
      eventType = 'escalated';
    }

    if (payload.visible_to_role !== existing.visible_to_role) {
      eventMetadata.visibleToRole = payload.visible_to_role;
      if (eventType === 'updated') {
        eventType = 'visibility_changed';
      }
    }

    if (['resolved', 'archived'].includes(existing.state)) {
      updatePayload.state = 'new';
      updatePayload.is_read = false;
      updatePayload.read_at = null;
      updatePayload.acknowledged_at = null;
      updatePayload.resolved_at = null;
      updatePayload.archived_at = null;
      updatePayload.assigned_to = null;
      updatePayload.assigned_at = null;
      updatePayload.reopened_count = Number(existing.reopened_count ?? 0) + 1;
      updatePayload.last_action = 'reopened';
      eventType = 'reopened';
    }

    const shouldUpdate =
      existing.tracking_number !== updatePayload.tracking_number ||
      existing.type !== updatePayload.type ||
      existing.message !== updatePayload.message ||
      Number(existing.days_pending) !== Number(updatePayload.days_pending) ||
      existing.visible_to_role !== updatePayload.visible_to_role ||
      Number(existing.escalation_level ?? 0) !== Number(updatePayload.escalation_level ?? 0) ||
      ['resolved', 'archived'].includes(existing.state);

    if (!shouldUpdate) {
      continue;
    }

    await updateAlertRecord(existing, updatePayload, {
      eventType,
      eventMetadata,
    });
  }

  const staleAlerts = (existingAlerts ?? []).filter((alert) => !nextAlerts.has(alert.parcel_id));

  for (const staleAlert of staleAlerts) {
    if (['resolved', 'archived'].includes(staleAlert.state)) {
      continue;
    }

    await resolveAlertInternally(staleAlert, { reason: 'parcel_no_longer_pending' });
  }
}

export async function listNotifications({
  severity,
  search,
  state,
  page = 1,
  pageSize = 20,
  dateFrom,
  dateTo,
  assignedTo,
  currentUser,
}) {
  await syncAlerts();

  const safePage = Math.max(1, Number(page) || 1);
  const safePageSize = Math.min(100, Math.max(1, Number(pageSize) || 20));
  const filters = {
    severity,
    search,
    state: state ?? 'active',
    page: safePage,
    pageSize: safePageSize,
    dateFrom,
    dateTo,
    assignedTo,
    currentUser,
  };

  let query = supabase.from('alerts').select(ALERT_SELECT, { count: 'exact' });
  query = applyVisibilityFilter(query, currentUser);
  query = applyListFilters(query, filters);
  query = query.order('days_pending', { ascending: false }).order('created_at', { ascending: false });

  const from = (safePage - 1) * safePageSize;
  const to = from + safePageSize - 1;

  const [{ data, error, count }, summary] = await Promise.all([
    query.range(from, to),
    buildNotificationSummary(filters),
  ]);

  throwIfSupabaseError(error);

  return {
    data: (data ?? []).map(mapAlert),
    meta: {
      page: safePage,
      pageSize: safePageSize,
      total: count ?? 0,
      totalPages: Math.max(1, Math.ceil((count ?? 0) / safePageSize)),
    },
    summary,
  };
}

export async function getNotificationEvents({ id, currentUser }) {
  const alert = await getAlertRowById(id);

  if (!alert) {
    throw new HttpError(404, 'Notification not found.');
  }

  if (currentUser?.role !== 'admin' && alert.visible_to_role === 'admin') {
    throw new HttpError(403, 'You do not have access to this notification.');
  }

  const { data, error } = await supabase
    .from('notification_events')
    .select('id,event_type,previous_state,next_state,metadata,created_at,actor:app_users!notification_events_actor_id_fkey(id,user_id,first_name,last_name,role)')
    .eq('alert_id', id)
    .order('created_at', { ascending: false })
    .limit(100);

  throwIfSupabaseError(error);

  return (data ?? []).map((row) => ({
    id: row.id,
    eventType: row.event_type,
    previousState: row.previous_state,
    nextState: row.next_state,
    metadata: row.metadata ?? {},
    createdAt: row.created_at,
    actor: mapMiniUser(row.actor),
  }));
}

export async function dismissNotification({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'archived');

  const archived = await archiveAlertInternally(alert, {
    actorId: actor?.id ?? null,
    reason: 'dismissed',
    expectedVersion,
  });

  return mapAlert(archived);
}

export async function markNotificationRead({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'marked as read');

  if (alert.state === 'read' && alert.is_read) {
    return mapAlert(alert);
  }

  const timestamp = nowIso();
  const updated = await updateAlertRecord(
    alert,
    {
      state: 'read',
      is_read: true,
      read_at: alert.read_at ?? timestamp,
      last_action: 'read',
    },
    {
      actorId: actor?.id ?? null,
      eventType: 'read',
      expectedVersion,
    },
  );

  return mapAlert(updated);
}

export async function acknowledgeNotification({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'acknowledged');

  const timestamp = nowIso();
  const updated = await updateAlertRecord(
    alert,
    {
      state: 'acknowledged',
      is_read: true,
      read_at: alert.read_at ?? timestamp,
      acknowledged_at: timestamp,
      last_action: 'acknowledged',
    },
    {
      actorId: actor?.id ?? null,
      eventType: 'acknowledged',
      expectedVersion,
    },
  );

  return mapAlert(updated);
}

export async function assignNotification({ id, actor, assigneeId, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'assigned');

  const targetUserId = assigneeId ?? actor?.id;

  if (!targetUserId) {
    throw new HttpError(400, 'An assignee is required.');
  }

  const assignee = await getUserById(targetUserId);

  if (!assignee || assignee.status !== 'active') {
    throw new HttpError(404, 'Assignee not found or inactive.');
  }

  const timestamp = nowIso();
  const eventType = alert.assigned_to === assignee.id ? 'updated' : 'assigned';
  const updated = await updateAlertRecord(
    alert,
    {
      state: 'assigned',
      is_read: true,
      read_at: alert.read_at ?? timestamp,
      assigned_to: assignee.id,
      assigned_at: timestamp,
      last_action: `assigned:${assignee.userId}`,
    },
    {
      actorId: actor?.id ?? null,
      eventType,
      eventMetadata: {
        assignedTo: assignee.userId,
      },
      expectedVersion,
    },
  );

  return mapAlert(updated);
}

export async function archiveNotification({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);

  if (!alert) {
    throw new HttpError(404, 'Notification not found.');
  }

  if (alert.state === 'archived') {
    return mapAlert(alert);
  }

  const archived = await archiveAlertInternally(alert, {
    actorId: actor?.id ?? null,
    reason: 'archived',
    expectedVersion,
  });

  return mapAlert(archived);
}

export async function flagNotificationForReview({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'flagged for review');

  const { data: existingReport, error: existingReportError } = await supabase
    .from('parcel_reports')
    .select('id')
    .eq('parcel_id', alert.parcel_id)
    .eq('status', 'Unresolved')
    .maybeSingle();

  throwIfSupabaseError(existingReportError);

  if (!existingReport) {
    await createReport({
      trackingNumber: alert.tracking_number,
      remarks: alert.message,
      status: 'Unresolved',
      actor,
    });
  }

  const resolved = await resolveAlertInternally(alert, {
    actorId: actor?.id ?? null,
    reason: existingReport ? 'already_reported' : 'flagged_for_review',
    eventType: 'flagged_for_review',
    expectedVersion,
  });

  return {
    alert: mapAlert(resolved),
    alreadyReported: Boolean(existingReport),
  };
}

export async function rerouteNotification({ id, actor, expectedVersion }) {
  const alert = await getAlertRowById(id);
  assertActiveAlert(alert, 'rerouted');

  if (!alert.parcel_id) {
    throw new HttpError(400, 'Notification is not linked to a parcel.');
  }

  await updateParcel({
    id: alert.parcel_id,
    status: 'Outbound',
    actor,
  });

  const resolved = await resolveAlertInternally(alert, {
    actorId: actor?.id ?? null,
    reason: 'rerouted',
    eventType: 'rerouted',
    expectedVersion,
  });

  return mapAlert(resolved);
}

export async function bulkUpdateNotifications({ ids, action, actor, assigneeId }) {
  const uniqueIds = [...new Set((ids ?? []).map((id) => Number(id)).filter((id) => Number.isFinite(id) && id > 0))];

  if (!uniqueIds.length) {
    throw new HttpError(400, 'At least one notification must be selected.');
  }

  const results = [];

  for (const id of uniqueIds) {
    if (action === 'acknowledge') {
      results.push(await acknowledgeNotification({ id, actor }));
      continue;
    }

    if (action === 'archive') {
      results.push(await archiveNotification({ id, actor }));
      continue;
    }

    if (action === 'assign') {
      results.push(await assignNotification({ id, actor, assigneeId }));
      continue;
    }

    if (action === 'mark_read') {
      results.push(await markNotificationRead({ id, actor }));
      continue;
    }

    throw new HttpError(400, 'Unsupported bulk action.');
  }

  return results;
}
