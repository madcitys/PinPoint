<template>
  <header class="top-navbar">
    <div ref="navbarActionsRef" class="navbar-actions">
      <div class="admin-wrapper">
        <button class="admin-btn" @click="toggleMenu">
          <span class="avatar-badge">{{ initials }}</span>
          <span class="admin-name">{{ userLabel }}</span>
          <span class="chevron" aria-hidden="true">
            <svg viewBox="0 0 20 20">
              <path d="m5 7 5 5 5-5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </span>
        </button>

        <div v-if="showMenu" class="admin-menu">
          <p class="menu-name">{{ fullName }}</p>
          <p class="menu-role">{{ roleLabel }}</p>
          <button class="menu-item" @click="handleLogout">Logout</button>
        </div>
      </div>

      <div class="header-divider"></div>

      <div class="alerts-wrapper">
        <button :class="['alerts-btn', { active: showAlerts || isNotificationsPage }]" @click="toggleAlerts" aria-label="Notifications">
          <span class="bell-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path
                d="M12 4a4 4 0 0 0-4 4v1.2c0 1.1-.4 2.2-1.2 3L5 14v1h14v-1l-1.8-1.8A4.2 4.2 0 0 1 16 9.2V8a4 4 0 0 0-4-4Z"
                :fill="showAlerts || isNotificationsPage ? 'currentColor' : 'none'"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linejoin="round"
              />
              <path d="M10 18a2 2 0 0 0 4 0" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </span>
          <span v-if="activeCount" class="alerts-badge">{{ activeCount > 99 ? '99+' : activeCount }}</span>
        </button>

        <div v-if="showAlerts" class="alerts-menu">
          <div class="alerts-header">
            <h3>Alerts</h3>
          </div>

          <div class="alerts-toolbar">
            <div class="alerts-tabs">
              <button :class="['alerts-tab', { active: activeFilter === 'all' }]" @click="activeFilter = 'all'">
                All
              </button>
              <button :class="['alerts-tab', 'warning', { active: activeFilter === 'warning' }]" @click="activeFilter = 'warning'">
                Warning {{ warningCount }}
              </button>
              <button :class="['alerts-tab', 'critical', { active: activeFilter === 'critical' }]" @click="activeFilter = 'critical'">
                Critical {{ criticalCount }}
              </button>
            </div>

            <button class="alerts-link see-all" @click="openAlertsPage">
              See all
            </button>
          </div>

          <p v-if="loadingAlerts" class="alerts-state">Loading alerts...</p>
          <p v-else-if="filteredAlerts.length === 0" class="alerts-state">No active alerts.</p>

          <div v-else class="alerts-list">
            <article
              v-for="alert in visibleAlerts"
              :key="alert.id"
              :class="['alert-card', alert.severity]"
              @click="goToAlert(alert)"
            >
              <div class="alert-card-top">
                <span :class="['alert-severity-pill', alert.severity]">{{ formatSeverity(alert.severity) }}</span>
                <span class="alert-meta">{{ formatAlertMeta(alert) }}</span>
              </div>

              <button class="alert-tracking-link" @click.stop="goToAlert(alert)">
                {{ alert.trackingNumber }}
              </button>
              <p class="alert-message">{{ formatAlertSummary(alert) }}</p>
              <p class="alert-platform">{{ formatPlatform(alert.meta?.platform) }}</p>

              <div class="alert-actions">
                <button class="alert-action route" :disabled="Boolean(actionBusy[alert.id])" @click.stop="rerouteAlert(alert)">
                  {{ actionBusy[alert.id] ? 'Working...' : 'Re-route' }}
                </button>
                <button class="alert-action flag" :disabled="Boolean(actionBusy[alert.id])" @click.stop="goToReports(alert)">
                  {{ actionBusy[alert.id] ? 'Working...' : 'Go to Reports' }}
                </button>
              </div>
            </article>

            <div v-if="filteredAlerts.length" class="alerts-inline-footer">
              <button
                v-if="canSeeMore"
                class="alerts-link see-more"
                @click="showMoreAlerts"
              >
                See More
              </button>
              <p v-else class="alerts-end-state">You're all caught up.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import {
  assignAlert,
  fetchAlertResponse,
  rerouteAlert as submitAlertReroute,
} from '../lib/alerts';
import { clearAuthSession, getCurrentUser } from '../lib/auth';
import { DATA_EVENTS, emitDataEvent, subscribeToDataEvent, startGlobalSync, stopGlobalSync } from '../lib/dataEvents';

const router = useRouter();
const route = useRoute();
const navbarActionsRef = ref(null);
const showMenu = ref(false);
const showAlerts = ref(false);
const activeFilter = ref('all');
const alerts = ref([]);
const loadingAlerts = ref(false);
const alertSummary = ref({
  active: 0,
  unread: 0,
  warning: 0,
  critical: 0,
});
const currentUser = ref(getCurrentUser());
const visibleAlertCount = ref(2);
const actionBusy = ref({});

const userLabel = computed(() => currentUser.value?.fullName ?? currentUser.value?.userId ?? 'Account');
const fullName = computed(() => currentUser.value?.fullName ?? 'Signed in user');
const roleLabel = computed(() => currentUser.value?.role ?? 'staff');
const initials = computed(() => {
  const full = currentUser.value?.fullName?.trim() ?? '';
  if (!full) return 'AC';
  const parts = full.split(/\s+/);
  return `${parts[0]?.[0] ?? ''}${parts[1]?.[0] ?? ''}`.toUpperCase();
});
const activeCount = computed(() => alertSummary.value.active ?? alerts.value.length);
const warningCount = computed(() => alertSummary.value.warning ?? alerts.value.filter((alert) => alert.severity === 'warning').length);
const criticalCount = computed(() => alertSummary.value.critical ?? alerts.value.filter((alert) => alert.severity === 'critical').length);
const filteredAlerts = computed(() => {
  if (activeFilter.value === 'warning') {
    return alerts.value.filter((alert) => alert.severity === 'warning');
  }

  if (activeFilter.value === 'critical') {
    return alerts.value.filter((alert) => alert.severity === 'critical');
  }

  return alerts.value;
});
const visibleAlerts = computed(() => filteredAlerts.value.slice(0, visibleAlertCount.value));
const canSeeMore = computed(() => filteredAlerts.value.length > visibleAlertCount.value);
const isNotificationsPage = computed(() => route.name === 'Notifications');

function formatSeverity(value) {
  if (!value) return 'Alert';
  return value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
}

function formatPlatform(value) {
  const names = {
    SPX: 'Shopee Xpress',
    JNT: 'J&T Express',
    FLH: 'Flash Express',
    LZD: 'Lazada Logistics',
  };

  return names[value] ?? value ?? 'Platform';
}

function formatAlertSummary(alert) {
  if (alert.message) {
    return alert.message;
  }

  const days = alert.meta?.daysPending ?? 0;
  if (alert.severity === 'critical') {
    return `Requires review after ${days} days without movement.`;
  }

  return `Still pending after ${days} days in the queue.`;
}

function formatAlertMeta(alert) {
  const status = alert.meta?.notificationStatus;
  if (status && status !== 'pending') {
    return formatSeverity(status);
  }

  const days = alert.meta?.daysPending ?? 0;
  return `${days} day${days === 1 ? '' : 's'} pending`;
}

function syncUser() {
  currentUser.value = getCurrentUser();
}

async function pollForSynchronization(maxAttempts = 10) {
  // Poll the alerts to ensure sync is complete
  let attempts = 0;
  const pollInterval = setInterval(async () => {
    attempts++;
    
    try {
      // Fetch fresh data to verify sync
      await loadingAlertsInternal();
      
      // If we got here, data is in sync
      if (attempts > 2 || attempts >= maxAttempts) {
        clearInterval(pollInterval);
        stopGlobalSync();
      }
    } catch (error) {
      console.error('Sync poll error:', error);
      if (attempts >= maxAttempts) {
        clearInterval(pollInterval);
        stopGlobalSync();
      }
    }
  }, 500);

  // Cleanup after max time
  setTimeout(() => {
    clearInterval(pollInterval);
    stopGlobalSync();
  }, maxAttempts * 600);
}

async function loadingAlertsInternal() {
  const response = await fetchAlertResponse({ limit: 100 });
  serverSummary.value = response?.summary ?? serverSummary.value;
}

async function refreshAlerts() {
  loadingAlerts.value = true;

  try {
    const payload = await fetchAlertResponse({
      state: 'active',
      page: 1,
      pageSize: 50,
    });
    alerts.value = payload?.data ?? [];
    alertSummary.value = payload?.summary ?? alertSummary.value;
  } catch {
    alerts.value = [];
    alertSummary.value = {
      active: 0,
      unread: 0,
      warning: 0,
      critical: 0,
    };
  } finally {
    loadingAlerts.value = false;
  }
}

async function refreshAlertsWithPolling() {
  if (alertPollingActive) {
    return;
  }

  alertPollingActive = true;
  await new Promise(resolve => setTimeout(resolve, 300));
  
  let attempts = 0;
  const maxAttempts = 8;
  
  return new Promise((resolve) => {
    alertPollInterval = setInterval(async () => {
      attempts++;
      
      try {
        await refreshAlerts();
      } catch (error) {
        console.error('Alert refresh error:', error);
      }
      
      if (attempts >= maxAttempts) {
        clearInterval(alertPollInterval);
        alertPollInterval = null;
        alertPollingActive = false;
        resolve();
      }
    }, 250);
    
    setTimeout(() => {
      if (alertPollInterval) {
        clearInterval(alertPollInterval);
        alertPollInterval = null;
      }
      alertPollingActive = false;
      resolve();
    }, maxAttempts * 350);
  });
}

function toggleAlerts() {
  showMenu.value = false;
  showAlerts.value = !showAlerts.value;

  if (showAlerts.value) {
    visibleAlertCount.value = 2;
    refreshAlerts();
  }
}

function toggleMenu() {
  showAlerts.value = false;
  showMenu.value = !showMenu.value;
}

async function goToAlert(alert) {
  await router.push({
    name: 'OrderRecords',
    query: {
      highlight: alert.trackingNumber,
    },
  });
  showAlerts.value = false;
}

async function goToReports(alert) {
  setActionBusy(alert.id, true);

  try {
    await router.push({
      name: 'ReportsIssues',
      query: { search: alert.trackingNumber ?? '' },
    });
  } finally {
    setActionBusy(alert.id, false);
  }
}

async function openAlertsPage() {
  await router.push({
    name: 'Notifications',
    query: activeFilter.value === 'all' ? {} : { filter: activeFilter.value },
  });
  showAlerts.value = false;
}

function showMoreAlerts() {
  visibleAlertCount.value += 2;
}

function setActionBusy(id, busy) {
  actionBusy.value = { ...actionBusy.value, [id]: busy };
}

async function rerouteAlert(alert) {
  setActionBusy(alert.id, true);
  startGlobalSync();

  try {
    // Assign to current user FIRST (while alert is still active)
    if (currentUser.value?.id) {
      await assignAlert(alert.id, currentUser.value.id);
    }
    // THEN reroute the alert (which resolves it)
    await submitAlertReroute(alert.id, alert.version);
    alerts.value = alerts.value.filter((entry) => entry.id !== alert.id);
    // Wait for database to sync before refreshing
    await new Promise(resolve => setTimeout(resolve, 300));
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'TopNavbar' });
    emitDataEvent(DATA_EVENTS.parcelsRefresh);
    await refreshAlerts();
    // Start polling to ensure full sync across all pages
    await pollForSynchronization();
  } catch (error) {
    console.error('Failed to re-route parcel from alert:', error);
    stopGlobalSync();
  } finally {
    setActionBusy(alert.id, false);
  }
}

async function handleLogout() {
  clearAuthSession();
  showMenu.value = false;
  await router.push('/login');
}

let cleanupNotifications = null;
let cleanupOutsideClick = null;
let alertRefreshTimer = null;
let alertPollingActive = false;
let alertPollInterval = null;

onMounted(() => {
  window.addEventListener('auth-session-changed', syncUser);
  // Use polling version for data event subscription to handle async backend updates
  cleanupNotifications = subscribeToDataEvent(DATA_EVENTS.notificationsRefresh, (event) => {
    if (event.detail?.source === 'TopNavbar') {
      return;
    }

    if (alertRefreshTimer) {
      clearTimeout(alertRefreshTimer);
    }

    alertRefreshTimer = setTimeout(() => {
      refreshAlertsWithPolling().catch(error => console.error('Alert refresh failed:', error));
      alertRefreshTimer = null;
    }, 0);
  });

  const handleOutsideClick = (event) => {
    if (!navbarActionsRef.value?.contains(event.target)) {
      showMenu.value = false;
      showAlerts.value = false;
    }
  };

  document.addEventListener('mousedown', handleOutsideClick);
  cleanupOutsideClick = () => document.removeEventListener('mousedown', handleOutsideClick);
  refreshAlerts();
});

watch(activeFilter, () => {
  visibleAlertCount.value = 2;
  if (showAlerts.value) {
    refreshAlerts();
  }
});

onUnmounted(() => {
  window.removeEventListener('auth-session-changed', syncUser);
  cleanupNotifications?.();
  cleanupOutsideClick?.();
  if (alertRefreshTimer) clearTimeout(alertRefreshTimer);
});
</script>

<style scoped>
.top-navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 78px;
  margin: 0;
  padding: 0 18px;
  border-bottom: 1px solid #d8dde6;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  z-index: 1100;
}

.navbar-actions {
  display: flex;
  align-items: center;
  gap: 14px;
  position: relative;
}

.alerts-wrapper,
.admin-wrapper {
  position: relative;
  z-index: 1;
}

.alerts-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  min-width: 23px;
  height: 23px;
  padding: 0 6px;
  border-radius: 999px;
  background: #ff4d4f;
  color: #fff;
  font-size: 11px;
  font-weight: 800;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 16px rgba(255, 77, 79, 0.24);
}

.alerts-menu {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  width: min(348px, calc(100vw - 28px));
  padding: 14px;
  border-radius: var(--radius-lg);
  background: var(--bg-surface);
  border: 1px solid var(--border-soft);
  box-shadow: var(--shadow-soft);
  backdrop-filter: blur(12px);
}

.alerts-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 2px 10px;
}

.alerts-header h3 {
  margin: 0;
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--text-main);
}

.alerts-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 0 2px 12px;
  border-bottom: 1px solid rgba(112, 128, 154, 0.14);
}

.alerts-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
  margin: 0;
}

.alerts-tab {
  min-height: 32px;
  padding: 0 11px;
  border-radius: 999px;
  border: 1px solid var(--border-soft);
  background: #ffffff;
  color: var(--text-muted);
  font-size: 11.5px;
  font-weight: 700;
}

.alerts-tab.active {
  background: var(--bg-panel);
  color: var(--text-main);
  border-color: rgba(255, 122, 26, 0.18);
}

.alerts-tab.warning {
  color: #ac6a00;
}

.alerts-tab.critical {
  color: #b64712;
}

.alerts-link {
  border: none;
  background: transparent;
  padding: 0;
  font-size: 13px;
  font-weight: 700;
  color: #c75a10;
}

.alerts-link.see-all {
  white-space: nowrap;
}

.alerts-state {
  margin: 0;
  padding: 24px 12px 18px;
  color: var(--text-faint);
  font-size: 13px;
  text-align: center;
}

.alerts-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 370px;
  overflow-y: auto;
  padding: 12px 2px 4px;
}

.alert-card {
  padding: 13px 14px 11px;
  border-radius: var(--radius-md);
  border: 1px solid var(--border-soft);
  background: var(--bg-panel);
}

.alert-card.warning {
  border-color: rgba(211, 145, 28, 0.18);
  background: #fff9eb;
}

.alert-card.critical {
  border-color: rgba(198, 77, 22, 0.18);
  background: #fff2ec;
}

.alert-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 8px;
}

.alert-severity-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 24px;
  padding: 0 10px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.alert-severity-pill.warning {
  background: rgba(211, 145, 28, 0.12);
  color: #ac6a00;
}

.alert-severity-pill.critical {
  background: rgba(198, 77, 22, 0.12);
  color: #b64712;
}

.alert-meta {
  font-size: 11px;
  font-weight: 700;
  color: var(--text-faint);
}

.alert-tracking-link {
  border: none;
  background: transparent;
  padding: 0;
  margin: 0 0 4px;
  font-size: 17px;
  font-weight: 800;
  color: #c75a10;
  text-decoration: none;
  text-align: left;
}

.alert-message {
  margin: 0 0 2px;
  font-size: 12.5px;
  line-height: 1.4;
  color: var(--text-main);
}

.alert-platform {
  margin: 0 0 8px;
  font-size: 11.5px;
  font-weight: 700;
  color: var(--text-muted);
}

.alert-pill {
  display: none;
}

.alert-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-start;
}

.alert-action {
  min-height: 34px;
  border-radius: 10px;
  border: 1px solid transparent;
  background: transparent;
  color: var(--text-main);
  font-size: 12px;
  font-weight: 700;
  transition: transform 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease;
}

.alert-action:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 16px rgba(15, 23, 42, 0.08);
}

.alert-action.route {
  min-width: 98px;
  padding: 0 14px;
  color: #ffffff;
  background: var(--bg-accent);
  box-shadow: 0 8px 16px rgba(255, 90, 0, 0.16);
}

.alert-action.flag {
  min-height: 32px;
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid rgba(255, 133, 51, 0.24);
  color: #c75a10;
  background: #fff7f1;
  box-shadow: none;
}

.alerts-inline-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 4px 2px 0;
}

.alerts-link.see-more {
  font-size: 14px;
  color: #c75a10;
}

.alerts-end-state {
  margin: 0;
  font-size: 13px;
  font-weight: 700;
  color: var(--text-faint);
  text-align: center;
}

.admin-btn {
  min-width: 0;
  border: none;
  background: transparent;
  padding: 0;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  color: #0f172a;
}

.avatar-badge {
  width: 44px;
  height: 44px;
  border-radius: 999px;
  background: #1f2d46;
  color: #ffffff;
  font-size: 15px;
  font-weight: 800;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.admin-name {
  font-size: 15px;
  font-weight: 700;
  color: #10213e;
}

.chevron {
  display: inline-flex;
  width: 16px;
  height: 16px;
  color: #5f6777;
}

.chevron svg {
  width: 100%;
  height: 100%;
}

.header-divider {
  width: 1px;
  height: 34px;
  background: #d9dee6;
}

.alerts-btn {
  position: relative;
  width: 40px;
  height: 40px;
  border-radius: 7px;
  border: 1px solid #cfd6df;
  background: #ffffff;
  color: #38455a;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.18s ease, border-color 0.18s ease, color 0.18s ease, box-shadow 0.18s ease;
}

.alerts-btn:hover {
  border-color: #ff8b47;
  color: #c75a10;
}

.alerts-btn.active {
  background: #1f2d46;
  border-color: #1f2d46;
  color: #ffffff;
  box-shadow: 0 12px 22px rgba(31, 45, 70, 0.2);
}

.bell-icon {
  display: inline-flex;
  width: 21px;
  height: 21px;
}

.bell-icon svg {
  width: 100%;
  height: 100%;
}

.admin-menu {
  position: absolute;
  top: calc(100% + 12px);
  right: 0;
  width: 236px;
  background: #fff;
  border-radius: 18px;
  box-shadow: var(--shadow-card);
  padding: 18px;
  border: 1px solid var(--border-soft);
  z-index: 20;
}

.menu-name {
  margin: 0;
  color: var(--text-main);
  font-weight: 700;
}

.menu-role {
  margin: 4px 0 12px;
  color: var(--text-muted);
  font-size: 13px;
  text-transform: capitalize;
}

.menu-item {
  width: 100%;
  border: 1px solid var(--border-strong);
  background: #fff7f1;
  color: #b64000;
  padding: 10px 12px;
  border-radius: 12px;
  font-weight: 700;
  position: relative;
  z-index: 1;
  margin-top: 6px;
}

@media (max-width: 960px) {
  .top-navbar {
    padding: 0 16px;
  }

  .admin-name {
    display: none;
  }

  .header-divider {
    display: none;
  }
}
</style>
