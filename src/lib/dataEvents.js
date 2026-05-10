const APP_EVENT_PREFIX = 'pinpoint:';

export const DATA_EVENTS = {
  notificationsRefresh: `${APP_EVENT_PREFIX}notifications-refresh`,
  parcelsRefresh: `${APP_EVENT_PREFIX}parcels-refresh`,
  syncStatusChanged: `${APP_EVENT_PREFIX}sync-status-changed`,
};

// Global sync state - tracks the last time a sync was triggered
let lastSyncTimestamp = 0;
let isSyncing = false;

export function emitDataEvent(name, detail = {}) {
  window.dispatchEvent(new CustomEvent(name, { detail }));
}

export function subscribeToDataEvent(name, listener) {
  window.addEventListener(name, listener);
  return () => window.removeEventListener(name, listener);
}

export function startGlobalSync() {
  lastSyncTimestamp = Date.now();
  isSyncing = true;
  emitDataEvent(DATA_EVENTS.syncStatusChanged, { isSyncing: true, timestamp: lastSyncTimestamp });
}

export function stopGlobalSync() {
  isSyncing = false;
  emitDataEvent(DATA_EVENTS.syncStatusChanged, { isSyncing: false, timestamp: lastSyncTimestamp });
}

export function isGlobalSyncActive() {
  return isSyncing;
}

export function getLastSyncTimestamp() {
  return lastSyncTimestamp;
}
