<template>
  <div class="page">
    <div class="card">
      <p class="eyebrow">Notification Center</p>
      <div class="page-header">
        <div class="page-header-copy">
          <h2>All Notifications</h2>
          <p class="page-subtitle">Review pending delivery risks</p>
        </div>
        <div class="header-meta">Showing {{ alerts.length }} / {{ meta.total }}</div>
      </div>

      <div class="state-tabs">
        <button
          v-for="tab in stateTabs"
          :key="tab.value"
          class="state-tab"
          :class="{ active: stateView === tab.value }"
          @click="stateView = tab.value"
        >
          {{ tab.label }}
        </button>
      </div>

      <div class="stats-grid">
        <article class="stat-card">
          <div class="stat-icon blue">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 3 19 7v10l-7 4-7-4V7l7-4Z" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round" />
              <path d="M12 3v18M5 7l14 8M19 7 5 15" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">Active Alerts</span>
          <strong class="stat-value">{{ notificationsSummary.active }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon amber">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 4 20 19H4L12 4Z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
              <path d="M12 9v4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <circle cx="12" cy="16.2" r="0.9" fill="currentColor" />
            </svg>
          </div>
          <span class="stat-label">Warning</span>
          <strong class="stat-value">{{ notificationsSummary.warning }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon red">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="m9.5 9.5 5 5m0-5-5 5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">Critical</span>
          <strong class="stat-value">{{ notificationsSummary.critical }}</strong>
        </article>

      </div>

      <div class="controls">
        <div class="controls-left">
          <label class="control-label" for="notification-search">Search</label>
          <div class="search-wrap">
            <span class="search-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24">
                <circle cx="11" cy="11" r="6.5" fill="none" stroke="currentColor" stroke-width="1.8" />
                <path d="m16 16 4 4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              </svg>
            </span>
            <input id="notification-search" v-model="searchQuery" type="text" placeholder="Search Tracking Number" />
          </div>
        </div>

        <div class="controls-right">
          <div class="date-filter">
            <span class="control-label">Date Added</span>
            <div class="date-filter-row">
              <button ref="dateTrigger" class="btn date-trigger" @click="openDateFilter">
                <span class="date-trigger-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24">
                    <rect x="3.5" y="5" width="17" height="15" rx="3.5" fill="none" stroke="currentColor" stroke-width="1.8" />
                    <path d="M7 3.5v4M17 3.5v4M3.5 9.5h17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
                    <path d="M8 13h3M13 13h3M8 17h3" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
                  </svg>
                </span>
                <span class="date-trigger-text">{{ selectedDateRangeText || 'All dates' }}</span>
              </button>
              <button v-if="selectedDateRangeText" class="clear-filter-btn" @click="clearDateFilter">Clear</button>
              <div ref="filterAnchor" class="filter-anchor">
                <button class="btn filter-btn" :class="{ active: activeFilter.length > 0 }" @click.stop="showFilterPopup = !showFilterPopup">
                  <span class="filter-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                      <path d="M4 6h16M7 12h10M10 18h4" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
                    </svg>
                  </span>
                  <span>Filter</span>
                </button>

                <div v-if="showFilterPopup" class="filter-popup" @click.stop>
                  <h4>Filter</h4>
                  <div class="filter-group multiple">
                    <label>
                      <input
                        type="checkbox"
                        :checked="activeFilter.length === 0"
                        @change="activeFilter = []"
                      />
                      All
                    </label>
                    <label>
                      <input type="checkbox" value="warning" v-model="activeFilter" />
                      Warning
                    </label>
                    <label>
                      <input type="checkbox" value="critical" v-model="activeFilter" />
                      Critical
                    </label>
                    <label>
                      <input type="checkbox" value="assigned" v-model="activeFilter" />
                      Assigned
                    </label>
                    <label>
                      <input type="checkbox" value="unassigned" v-model="activeFilter" />
                      Unassigned
                    </label>
                  </div>

                  <div class="filter-actions">
                    <button class="btn popup-clear" @click="activeFilter = []">Clear</button>
                    <button class="btn popup-apply" @click="showFilterPopup = false">Apply</button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <button class="btn" @click="refreshAlertsAndNotify()" :disabled="loading">
            {{ loading ? 'Refreshing...' : 'Refresh' }}
          </button>
        </div>

        <input ref="calendarInput" type="text" class="calendar-hidden-input" />
      </div>

      <div v-if="selectedAlertIds.length" class="bulk-actions">
        <span class="bulk-copy">{{ selectedAlertIds.length }} selected</span>
        <button
          v-if="stateView === 'active'"
          class="btn"
          :disabled="bulkBusy"
          @click="runBulkAction('assign')"
        >
          Assign to me
        </button>
        <button
          v-else-if="stateView === 'mine'"
          class="btn"
          :disabled="bulkBusy"
          @click="runBulkAction('unassign')"
        >
          Unassign to me
        </button>
      </div>

      <p v-if="loading" class="state">Loading notifications...</p>
      <p v-else-if="alerts.length === 0" class="state">No notifications match your filters.</p>

      <div v-else class="table-wrap">
        <table>
          <thead>
            <tr>
              <th></th>
              <th class="level-column">Level</th>
              <th>Notification Status</th>
              <th>Tracking</th>
              <th>Platform</th>
              <th>Status</th>
              <th>Assigned To</th>
              <th>Date Added</th>
              <th>Days Pending</th>
              <th>Message</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="alert in paginatedAlerts"
              :key="alert.id"
              :class="['clickable-row', alert.severity, { selected: selectedAlertIds.includes(alert.id) }]"
              @click="openAlert(alert)"
            >
              <td class="select-cell">
                <button
                  v-if="canSelectAlert(alert)"
                  type="button"
                  class="row-check"
                  :class="{ checked: selectedAlertIds.includes(alert.id) }"
                  :aria-pressed="selectedAlertIds.includes(alert.id)"
                  :aria-label="selectedAlertIds.includes(alert.id) ? `Deselect ${alert.trackingNumber}` : `Select ${alert.trackingNumber}`"
                  @click.stop="toggleSelection(alert)"
                >
                  <svg viewBox="0 0 20 20" aria-hidden="true">
                    <path d="M5 10.5 8.2 13.5 15 6.8" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                </button>
              </td>
              <td class="level-column">
                <span class="pill" :class="alert.severity">{{ formatSeverity(alert.severity) }}</span>
              </td>
              <td>
                <span class="status-pill notification-status" :class="alert.meta?.notificationStatus">
                  {{ formatNotificationStatus(alert.meta?.notificationStatus) }}
                </span>
              </td>
              <td>{{ alert.trackingNumber }}</td>
              <td>{{ formatPlatform(alert.meta?.platform) }}</td>
              <td><span class="status-pill" :class="alert.state">{{ formatState(alert.state) }}</span></td>
              <td>{{ alert.assignedTo?.fullName ?? '-' }}</td>
              <td>{{ formatDate(alert.meta?.dateAdded) }}</td>
              <td>{{ alert.meta?.daysPending ?? '-' }}</td>
              <td>{{ alert.message }}</td>
              <td class="actions-cell">
                <div class="actions-grid">
                <button v-if="stateView !== 'resolved'" class="table-action" type="button" @click.stop="openReportPage(alert)">Reports</button>
                <button
                  v-if="stateView !== 'resolved'"
                  class="table-action route"
                  type="button"
                  :disabled="actionBusyId === alert.id"
                  @click.stop="rerouteAlert(alert)"
                >
                  {{ actionBusyId === alert.id ? 'Working...' : 'Re-route' }}
                </button>
                <button
                  v-if="stateView !== 'resolved'"
                  class="table-action flag"
                  type="button"
                  :disabled="actionBusyId === alert.id"
                  @click.stop="flagAlertForReview(alert)"
                >
                  {{ actionBusyId === alert.id ? 'Working...' : 'Flag for Review' }}
                </button>

              </div>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="stateView !== 'resolved'" class="pagination">
          <button class="btn" :disabled="page === 1" @click="page -= 1">Previous</button>
          <span>Page {{ page }} of {{ meta.totalPages }}</span>
          <button class="btn" :disabled="page === meta.totalPages" @click="page += 1">Next</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import flatpickr from 'flatpickr';
import 'flatpickr/dist/flatpickr.css';
import { useRoute, useRouter } from 'vue-router';
import { DATA_EVENTS, emitDataEvent, subscribeToDataEvent, isGlobalSyncActive, getLastSyncTimestamp, startGlobalSync, stopGlobalSync } from '../lib/dataEvents';
import {
  assignAlert,
  bulkUpdateAlerts,
  fetchAlertResponse,
  flagAlertForReview as submitFlagAlertForReview,
  rerouteAlert as submitRerouteAlert,
} from '../lib/alerts';
import { getCurrentUser } from '../lib/auth';

const route = useRoute();
const router = useRouter();
const alerts = ref([]);
const loading = ref(false);
const page = ref(1);
const perPage = 10;
const searchQuery = ref('');
const activeFilter = ref(
  Array.isArray(route.query.filter)
    ? route.query.filter.map(String)
    : typeof route.query.filter === 'string'
    ? String(route.query.filter).split(',').filter(Boolean)
    : [],
);
const stateView = ref(typeof route.query.state === 'string' ? route.query.state : 'active');
const selectedAlertIds = ref([]);
const dateRange = ref([]);
const showFilterPopup = ref(false);
const calendarInput = ref(null);
const dateTrigger = ref(null);
const filterAnchor = ref(null);
const meta = ref({
  page: 1,
  pageSize: perPage,
  total: 0,
  totalPages: 1,
});
const serverSummary = ref({
  total: 0,
  warning: 0,
  critical: 0,
  thisWeek: 0,
  active: 0,
  resolved: 0,
  assignedToMe: 0,
});
const bulkBusy = ref(false);
const actionBusyId = ref(null);
const currentUser = getCurrentUser();
let calendarInstance = null;
let cleanupNotifications = null;
let syncPollTimer = null;

const paginatedAlerts = computed(() => alerts.value);
const selectedDateRangeText = computed(() => {
  if (dateRange.value.length !== 2) return '';
  const [start, end] = dateRange.value;
  return `${start.toISOString().slice(0, 10)} - ${end.toISOString().slice(0, 10)}`;
});
const notificationsSummary = computed(() => serverSummary.value);
const stateTabs = computed(() => [
  { value: 'active', label: `Active ${serverSummary.value.active ?? 0}` },
  { value: 'mine', label: `Assigned to Me ${serverSummary.value.assignedToMe ?? 0}` },
  { value: 'resolved', label: 'Recently Resolved' },
]);

function formatDate(value) {
  if (!value) return '-';
  return new Date(value).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
}

function formatPlatform(value) {
  const names = {
    SPX: 'Shopee Xpress',
    JNT: 'J&T Express',
    FLH: 'Flash Express',
    LZD: 'Lazada Logistics',
  };

  return names[value] ?? value ?? '-';
}

function formatSeverity(value) {
  if (!value) return '-';
  return value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
}

function formatState(value) {
  if (!value) return '-';
  if (value === 'acknowledged') {
    return 'Read';
  }
  return value
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join(' ');
}

function canSelectAlert(alert) {
  if (stateView.value === 'active') {
    return !alert.assignedTo;
  }

  if (stateView.value === 'mine') {
    return alert.assignedTo?.id === currentUser?.id;
  }

  return false;
}

function formatNotificationStatus(value) {
  if (!value) return 'Pending';
  return value
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join(' ');
}

function openDateFilter() {
  calendarInstance?.open();
}

function clearDateFilter() {
  dateRange.value = [];
  calendarInstance?.clear();
}

function handleDocumentClick(event) {
  if (showFilterPopup.value && filterAnchor.value && !filterAnchor.value.contains(event.target)) {
    showFilterPopup.value = false;
  }
}

async function loadAlerts() {
  loading.value = true;
  try {
    const payload = await fetchAlertResponse({
      filter: activeFilter.value,
      search: searchQuery.value.trim(),
      state: stateView.value,
      page: page.value,
      pageSize: perPage,
      dateFrom: dateRange.value[0] ? dateRange.value[0].toISOString().slice(0, 10) : undefined,
      dateTo: dateRange.value[1] ? dateRange.value[1].toISOString().slice(0, 10) : undefined,
    });

    alerts.value = payload?.data ?? [];
    meta.value = payload?.meta ?? { page: 1, pageSize: perPage, total: 0, totalPages: 1 };
    serverSummary.value = payload?.summary ?? serverSummary.value;
    selectedAlertIds.value = selectedAlertIds.value.filter((id) => alerts.value.some((alert) => alert.id === id));
  } catch {
    alerts.value = [];
    meta.value = { page: 1, pageSize: perPage, total: 0, totalPages: 1 };
    selectedAlertIds.value = [];
  } finally {
    loading.value = false;
  }
}

async function refreshAlertsAndNotify() {
  await loadAlerts();
  emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'NotificationsPage' });
}

async function openAlert(alert) {
  await router.push({
    name: 'OrderRecords',
    query: {
      highlight: alert.trackingNumber,
    },
  });
}

async function openReportPage(alert) {
  await router.push({
    name: 'ReportsIssues',
    query: {
      search: alert.trackingNumber,
    },
  });
}

async function flagAlertForReview(alert) {
  actionBusyId.value = alert.id;

  try {
    await submitFlagAlertForReview(alert.id, alert.version);
    // No need to reload alerts - the alert remains visible in All Notifications
  } finally {
    actionBusyId.value = null;
  }
}

async function rerouteAlert(alert) {
  actionBusyId.value = alert.id;
  startGlobalSync();

  try {
    // Assign to current user FIRST (while alert is still active)
    if (currentUser?.id) {
      await assignAlert(alert.id, currentUser.id);
    }
    // THEN reroute the alert (which resolves it)
    await submitRerouteAlert(alert.id, alert.version);
    // Wait for database to sync before refreshing
    await new Promise(resolve => setTimeout(resolve, 300));
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'NotificationsPage' });
    emitDataEvent(DATA_EVENTS.parcelsRefresh);
    await loadAlerts();
    // Start polling to ensure full sync
    await pollForPageSynchronization();
  } catch (error) {
    console.error('Failed to reroute parcel:', error);
    stopGlobalSync();
  } finally {
    actionBusyId.value = null;
  }
}

async function pollForPageSynchronization() {
  let attempts = 0;
  const maxAttempts = 10;

  await new Promise(resolve => {
    syncPollTimer = setInterval(async () => {
      attempts++;
      
      try {
        // Reload alerts to verify sync
        await loadAlerts();
        
        // Continue polling to ensure consistency
        if (attempts >= maxAttempts) {
          clearInterval(syncPollTimer);
          stopGlobalSync();
          resolve();
        }
      } catch (error) {
        console.error('Sync poll error:', error);
        if (attempts >= maxAttempts) {
          clearInterval(syncPollTimer);
          stopGlobalSync();
          resolve();
        }
      }
    }, 500);

    // Cleanup after max time
    setTimeout(() => {
      if (syncPollTimer) {
        clearInterval(syncPollTimer);
      }
      stopGlobalSync();
      resolve();
    }, maxAttempts * 600);
  });
}

function toggleSelection(alert) {
  if (!canSelectAlert(alert)) {
    return;
  }

  selectedAlertIds.value = selectedAlertIds.value.includes(alert.id)
    ? selectedAlertIds.value.filter((id) => id !== alert.id)
    : [...selectedAlertIds.value, alert.id];
}

watch(
  () => stateView.value,
  () => {
    selectedAlertIds.value = [];
  },
);

async function runBulkAction(action) {
  if (!selectedAlertIds.value.length) {
    return;
  }

  bulkBusy.value = true;

  try {
    if (action === 'assign') {
      await bulkUpdateAlerts(selectedAlertIds.value, 'assign', currentUser?.id);
    }

    if (action === 'unassign') {
      await bulkUpdateAlerts(selectedAlertIds.value, 'unassign');
    }

    selectedAlertIds.value = [];
    await loadAlerts();
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'NotificationsPage' });
  } finally {
    bulkBusy.value = false;
  }
}

watch([searchQuery, activeFilter, dateRange, stateView], () => {
  page.value = 1;
  loadAlerts();
}, { deep: true });

watch(page, () => {
  loadAlerts();
});

watch(
  () => meta.value.totalPages,
  (next) => {
    if (page.value > next) {
      page.value = next;
    }
  },
);

watch(
  () => route.query.filter,
  (nextFilter) => {
    if (Array.isArray(nextFilter)) {
      activeFilter.value = nextFilter.map(String);
    } else if (typeof nextFilter === 'string') {
      activeFilter.value = String(nextFilter).split(',').filter(Boolean);
    } else {
      activeFilter.value = [];
    }
  },
);
watch(
  () => route.query.state,
  (nextState) => {
    stateView.value = typeof nextState === 'string' ? nextState : 'active';
  },
);

onMounted(() => {
  calendarInstance = flatpickr(calendarInput.value, {
    mode: 'range',
    dateFormat: 'Y-m-d',
    clickOpens: false,
    disableMobile: true,
    monthSelectorType: 'static',
    position: 'below left',
    positionElement: dateTrigger.value,
    prevArrow:
      '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14.5 6 8.5 12l6 6" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    nextArrow:
      '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9.5 6 6 6-6 6" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    onChange(selectedDates) {
      dateRange.value = [...selectedDates];
    },
  });
  document.addEventListener('click', handleDocumentClick);
  
  // Subscribe to notifications refresh
  cleanupNotifications = subscribeToDataEvent(DATA_EVENTS.notificationsRefresh, (event) => {
    if (event.detail?.source === 'NotificationsPage') {
      return;
    }
    loadAlerts();
  });
  
  // Load initial data
  loadAlerts();
});

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick);
  cleanupNotifications?.();
  if (syncPollTimer) {
    clearInterval(syncPollTimer);
  }
});
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-width: 0;
}

.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  padding: 26px;
  box-shadow: var(--shadow-card);
  width: 100%;
  min-width: 0;
  overflow: hidden;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 22px;
}

.state-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 18px;
}

.state-tab {
  min-height: 38px;
  padding: 0 14px;
  border-radius: 999px;
  border: 1px solid var(--border-soft);
  background: #fff;
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 700;
}

.state-tab.active {
  background: rgba(255, 111, 0, 0.08);
  border-color: rgba(255, 111, 0, 0.18);
  color: #c75a10;
}

.page-header-copy {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.eyebrow {
  margin: 0 0 6px;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: #c75a10;
}

.page-header h2 {
  margin: 0;
  font-size: 2.35rem;
  color: var(--text-main);
}

.page-subtitle {
  margin: 0;
  font-size: 0.98rem;
  color: var(--text-muted);
}

.header-meta {
  color: var(--text-muted);
  font-size: 14px;
  font-weight: 700;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 18px;
  margin-bottom: 26px;
}

.stat-card {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 18px;
  min-height: 138px;
  padding: 24px;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  background: #fff;
}

.stat-icon {
  position: absolute;
  top: 24px;
  right: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 50px;
  border-radius: 16px;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
}

.stat-icon.blue {
  background: #edf4ff;
  color: #2563ff;
}

.stat-icon.amber {
  background: #fff1da;
  color: #dd7a00;
}

.stat-icon.red {
  background: #ffe7e5;
  color: #d93a2f;
}

.stat-icon.orange {
  background: #fff4eb;
  color: #ff5a0a;
}

.stat-label {
  font-size: 1.02rem;
  color: var(--text-main);
}

.stat-value {
  font-size: 2.2rem;
  line-height: 1;
  color: var(--text-main);
}

.controls {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 20px;
  margin-bottom: 22px;
  flex-wrap: wrap;
}

.controls-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 320px;
}

.control-label {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--text-muted);
  line-height: 1;
}

.search-wrap {
  position: relative;
  width: min(352px, 100%);
}

.search-wrap input {
  width: 100%;
  min-height: 44px;
  padding: 0 14px 0 40px;
  border-radius: 16px;
  border: 1px solid var(--border-soft);
  background: #fbfcfe;
  color: var(--text-main);
  font-size: 16px;
}

.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  width: 16px;
  height: 16px;
  transform: translateY(-50%);
  color: var(--text-faint);
}

.search-icon svg {
  width: 100%;
  height: 100%;
}

.controls-right {
  display: flex;
  justify-content: flex-end;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 10px;
  min-width: 0;
}

.calendar-hidden-input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.date-filter {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  min-width: 0;
}

.date-filter-row {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 16px;
  border-radius: 14px;
  border: 1px solid var(--border-soft);
  background: #ffffff;
  color: var(--text-main);
  font-size: 14px;
  font-weight: 700;
}

.btn.active {
  background: var(--bg-accent-soft);
  border-color: rgba(255, 122, 26, 0.18);
  color: #c75a10;
}

.btn.subtle {
  color: var(--text-muted);
}

.date-trigger {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 12px;
  min-height: 44px;
  min-width: 314px;
  padding: 0 16px;
  border: 1px solid var(--border-soft);
  border-radius: 16px;
  background: linear-gradient(180deg, #ffffff 0%, #f9fbff 100%);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.7);
  font-size: 14px;
  color: var(--text-muted);
}

.date-trigger:hover {
  background: linear-gradient(180deg, #ffffff 0%, #f6f8fc 100%);
}

.date-trigger-icon,
.filter-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  flex: 0 0 auto;
}

.date-trigger-icon {
  color: #d85d14;
}

.date-trigger-icon svg,
.filter-icon svg {
  width: 100%;
  height: 100%;
}

.date-trigger-text {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-weight: 700;
}

.filter-btn {
  gap: 10px;
  min-width: 122px;
}

.clear-filter-btn {
  min-height: 44px;
  padding: 0 14px;
  border-radius: 14px;
  border: 1px solid rgba(216, 93, 20, 0.18);
  background: rgba(255, 111, 0, 0.08);
  color: #c55a14;
  font-size: 13px;
  font-weight: 800;
}

.state {
  margin: 6px 0 0;
  color: var(--text-faint);
  text-align: center;
}

.bulk-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 18px;
  padding: 14px 16px;
  border: 1px solid rgba(255, 133, 51, 0.14);
  border-radius: 18px;
  background: linear-gradient(180deg, #fffdfb 0%, #fff7f1 100%);
}

.bulk-copy {
  margin-right: 4px;
  font-size: 13px;
  font-weight: 800;
  color: var(--text-muted);
}

.table-wrap {
  margin-top: 6px;
  width: 100%;
  min-width: 0;
  overflow-x: auto;
  overflow-y: hidden;
}

table {
  width: 100%;
  min-width: 1380px;
  border-collapse: collapse;
  font-size: 14px;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  overflow: hidden;
  background: #fff;
}

th,
td {
  padding: 14px 18px;
  border-bottom: 1px solid rgba(112, 128, 154, 0.16);
  text-align: left;
  color: var(--text-main);
  vertical-align: top;
}

th {
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--text-muted);
}

th.level-column,
td.level-column {
  text-align: center;
}

th:first-child,
td:first-child {
  width: 58px;
  text-align: center;
}

.actions-cell {
  min-width: 188px;
}

tr.selected td {
  background: rgba(255, 111, 0, 0.08);
}

tr.warning td {
  background: rgba(255, 246, 223, 0.52);
}

tr.critical td {
  background: rgba(255, 241, 237, 0.62);
}

.clickable-row {
  cursor: pointer;
  transition: transform 0.16s ease, box-shadow 0.16s ease;
}

.clickable-row:hover td {
  background: rgba(255, 122, 26, 0.06);
}

.select-cell {
  vertical-align: middle;
}

.row-check {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  margin: 0;
  border-radius: 8px;
  border: 1.5px solid rgba(112, 128, 154, 0.55);
  background: #fff;
  color: transparent;
  transition: border-color 0.18s ease, background-color 0.18s ease, color 0.18s ease, box-shadow 0.18s ease;
}

.row-check svg {
  width: 15px;
  height: 15px;
}

.row-check.checked {
  border-color: #ff6f00;
  background: rgba(255, 111, 0, 0.14);
  color: #d85d14;
  box-shadow: 0 8px 18px rgba(255, 111, 0, 0.14);
}

.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 94px;
  padding: 7px 14px;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 700;
}

.pill.warning {
  background: var(--bg-warning-soft);
  color: #9d6500;
}

.pill.critical {
  background: var(--bg-danger-soft);
  color: #b64712;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 108px;
  padding: 7px 14px;
  border-radius: 999px;
  font-size: 0.82rem;
  font-weight: 700;
  background: #eef2f8;
  color: var(--text-muted);
}

.status-pill.new {
  background: #eef4ff;
  color: #2f62d9;
}

.status-pill.read {
  background: #f1f5f9;
  color: #526077;
}

.status-pill.assigned {
  background: #f4edff;
  color: #7d42d8;
}

.status-pill.resolved {
  background: #eafaf1;
  color: #0f8a51;
}

.status-pill.notification-status.pending {
  background: #fff4e8;
  color: #c75a10;
}

.status-pill.notification-status.missing {
  background: #fff0ed;
  color: #bf4b17;
}

.status-pill.notification-status.lost {
  background: #ffe7e5;
  color: #b42318;
}

.table-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 34px;
  margin: 0 6px 6px 0;
  padding: 0 12px;
  border-radius: 10px;
  border: 1px solid rgba(255, 133, 51, 0.18);
  background: rgba(255, 111, 0, 0.08);
  color: #c75a10;
  font-size: 12px;
  font-weight: 800;
}

.table-action.warn {
  border-color: rgba(180, 35, 24, 0.14);
  background: #ffe7e5;
  color: #b42318;
}

.table-action:disabled {
  opacity: 0.58;
  cursor: not-allowed;
}

.actions-cell {
  min-width: 340px;
  padding-top: 12px;
  vertical-align: top;
}

.actions-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  align-items: flex-start;
  gap: 10px;
  margin-top: -4px;
}

.actions-grid .table-action {
  flex: 0 1 auto;
  width: auto;
  min-width: 132px;
  white-space: nowrap;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 10px;
  margin-top: 16px;
  flex-wrap: wrap;
}

.filter-anchor {
  position: relative;
}

.filter-popup {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  z-index: 40;
  width: min(320px, calc(100vw - 32px));
  padding: 22px;
  background:
    radial-gradient(circle at top left, rgba(255, 161, 78, 0.08), transparent 34%),
    linear-gradient(180deg, #fffdfb 0%, #ffffff 100%);
  border: 1px solid rgba(255, 133, 51, 0.16);
  border-radius: 24px;
  color: var(--text-main);
  box-shadow: 0 26px 56px rgba(15, 23, 42, 0.16);
}

.filter-popup h4 {
  margin: 0 0 14px;
  font-size: 13px;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.filter-group.single {
  gap: 12px;
}

.filter-group {
  display: grid;
  gap: 12px;
  font-size: 15px;
}

.filter-group.single label {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 40px;
  padding: 0 2px;
  color: var(--text-main);
}

.filter-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 18px;
}

.popup-clear,
.popup-apply {
  min-width: 98px;
}

.popup-clear {
  background: #ffffff;
  border-color: rgba(112, 128, 154, 0.22);
}

.popup-apply {
  border-color: rgba(255, 133, 51, 0.2);
  background: rgba(255, 111, 0, 0.08);
  color: #d85d14;
}

:deep(.flatpickr-calendar) {
  width: 332px;
  padding: 12px;
  border: 1px solid rgba(255, 133, 51, 0.16);
  border-radius: 24px;
  background: linear-gradient(180deg, #fffdfb 0%, #ffffff 100%);
  box-shadow: 0 26px 56px rgba(15, 23, 42, 0.16);
  overflow: hidden;
}

:deep(.flatpickr-months) {
  margin-bottom: 8px;
  padding: 8px;
  border-radius: 18px;
  background: linear-gradient(135deg, rgba(255, 111, 0, 0.1) 0%, rgba(255, 244, 235, 0.92) 100%);
}

:deep(.flatpickr-current-month) {
  inset: 8px 44px auto 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding-top: 6px;
  color: var(--text-main);
  font-weight: 800;
}

:deep(.flatpickr-current-month .flatpickr-monthDropdown-months) {
  appearance: none;
  padding: 6px 28px 6px 10px;
  border: 1px solid rgba(255, 133, 51, 0.18);
  border-radius: 12px;
  background: #ffffff;
  color: var(--text-main);
  font-weight: 800;
}

:deep(.flatpickr-current-month input.cur-year) {
  min-width: 64px;
  height: 34px;
  margin-left: 0;
  border: 1px solid rgba(255, 133, 51, 0.18);
  border-radius: 12px;
  background: #ffffff;
  color: var(--text-main);
  font-weight: 800;
}

:deep(.flatpickr-prev-month),
:deep(.flatpickr-next-month) {
  top: 14px;
  width: 32px;
  height: 32px;
  padding: 0;
  border-radius: 10px;
  color: #c75a10;
}

:deep(.flatpickr-prev-month:hover),
:deep(.flatpickr-next-month:hover) {
  background: rgba(255, 111, 0, 0.1);
  color: #a94a0f;
}

:deep(.flatpickr-prev-month svg),
:deep(.flatpickr-next-month svg) {
  width: 16px;
  height: 16px;
}

:deep(.flatpickr-weekdays) {
  margin-bottom: 6px;
  padding: 0 4px;
  background: transparent;
}

:deep(.flatpickr-weekday) {
  color: var(--text-muted);
  font-weight: 800;
  font-size: 12px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

:deep(.flatpickr-days) {
  width: 100%;
}

:deep(.dayContainer) {
  width: 100%;
  min-width: 100%;
  max-width: 100%;
}

:deep(.flatpickr-day) {
  max-width: 40px;
  height: 40px;
  line-height: 40px;
  margin: 2px 0;
  border-radius: 14px;
  border: 1px solid transparent;
  color: var(--text-main);
  font-weight: 600;
}

:deep(.flatpickr-day:hover) {
  background: rgba(255, 111, 0, 0.1);
  border-color: rgba(255, 111, 0, 0.16);
}

:deep(.flatpickr-day.selected),
:deep(.flatpickr-day.startRange),
:deep(.flatpickr-day.endRange) {
  background: linear-gradient(135deg, #ff8b38 0%, #ff5a0a 100%);
  border-color: #ff7a1a;
  color: #ffffff;
  box-shadow: 0 10px 20px rgba(255, 90, 10, 0.24);
}

:deep(.flatpickr-day.inRange) {
  background: rgba(255, 111, 0, 0.12);
  border-color: rgba(255, 111, 0, 0.08);
  box-shadow: none;
}

:deep(.flatpickr-day.today) {
  border-color: rgba(216, 93, 20, 0.45);
  background: rgba(255, 111, 0, 0.04);
}

:deep(.flatpickr-day.flatpickr-disabled),
:deep(.flatpickr-day.prevMonthDay),
:deep(.flatpickr-day.nextMonthDay) {
  color: rgba(112, 128, 154, 0.42);
}

@media (max-width: 960px) {
  .page-header,
  .controls {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .controls-left,
  .search-wrap {
    width: 100%;
  }

  .controls-right {
    width: 100%;
  }

  .btn,
  .date-trigger {
    flex: 1;
  }

  .table-wrap {
    overflow-x: auto;
  }
}
</style>
