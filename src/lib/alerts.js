import { apiJsonRequest, apiRequest } from './api';

function normalizeQuery(options = {}) {
  const params = {};

  if (Array.isArray(options.filter) && options.filter.length > 0) {
    params.filter = options.filter.filter(Boolean).join(',');
  } else if (options.filter && typeof options.filter === 'string') {
    params.filter = options.filter;
  }

  if (options.search) {
    params.search = options.search;
  }

  if (options.state && options.state !== 'active') {
    params.state = options.state;
  }

  if (options.dateFrom) {
    params.dateFrom = options.dateFrom;
  }

  if (options.dateTo) {
    params.dateTo = options.dateTo;
  }

  if (options.assignedTo) {
    params.assignedTo = options.assignedTo;
  }

  if (options.page) {
    params.page = options.page;
  }

  if (options.pageSize) {
    params.pageSize = options.pageSize;
  }

  return params;
}

export async function fetchAlertResponse(options = {}) {
  return apiJsonRequest('/notifications', { params: normalizeQuery(options) });
}

export async function fetchAlerts(options = {}) {
  const payload = await fetchAlertResponse(options);
  return payload?.data ?? [];
}

export async function dismissAlert(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/dismiss`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}

export async function markAlertRead(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/read`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}

export async function markAlertUnread(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/unread`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}

export async function assignAlert(id, assigneeId, expectedVersion) {
  return apiRequest(`/notifications/${id}/assign`, {
    method: 'POST',
    body: {
      assigneeId,
      ...(expectedVersion ? { expectedVersion } : {}),
    },
  });
}

export async function archiveAlert(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/archive`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}

export async function bulkUpdateAlerts(ids, action, assigneeId) {
  return apiRequest('/notifications/bulk-action', {
    method: 'POST',
    body: {
      ids,
      action,
      ...(assigneeId ? { assigneeId } : {}),
    },
  });
}

export async function fetchAlertEvents(id) {
  const payload = await apiJsonRequest(`/notifications/${id}/events`);
  return payload?.data ?? [];
}

export async function flagAlertForReview(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/flag-review`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}

export async function rerouteAlert(id, expectedVersion) {
  return apiRequest(`/notifications/${id}/reroute`, {
    method: 'POST',
    body: expectedVersion ? { expectedVersion } : {},
  });
}
