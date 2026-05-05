const APP_EVENT_PREFIX = 'pinpoint:';

export const DATA_EVENTS = {
  notificationsRefresh: `${APP_EVENT_PREFIX}notifications-refresh`,
};

export function emitDataEvent(name, detail = {}) {
  window.dispatchEvent(new CustomEvent(name, { detail }));
}

export function subscribeToDataEvent(name, listener) {
  window.addEventListener(name, listener);
  return () => window.removeEventListener(name, listener);
}
