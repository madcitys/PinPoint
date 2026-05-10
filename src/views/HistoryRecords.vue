<template>
  <div class="page">
    <div class="card">
      <p class="page-eyebrow">Activity Timeline</p>
      <div class="page-header">
        <div class="page-header-copy">
          <h2>History Records</h2>
          <p class="page-subtitle">View all past transactions and activities</p>
        </div>
        <div class="header-actions">
          <button class="btn export-btn" @click="downloadCSV" :disabled="isDownloading">
            {{ isDownloading ? 'Exporting...' : 'Export' }}
          </button>
        </div>
      </div>

      <div class="stats-grid">
        <article class="stat-card">
          <div class="stat-icon blue">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 3 19 7v10l-7 4-7-4V7l7-4Z" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round" />
              <path d="M12 3v18M5 7l14 8M19 7 5 15" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">Total Records</span>
          <strong class="stat-value">{{ historySummary.total }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon green">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="m8.5 12.2 2.4 2.4 4.8-5.2" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </div>
          <span class="stat-label">Completed</span>
          <strong class="stat-value">{{ historySummary.completed }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon purple">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="4" y="5" width="16" height="15" rx="3" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="M8 3.5v4M16 3.5v4M4 9.5h16" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">This Week</span>
          <strong class="stat-value">{{ historySummary.thisWeek }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon orange">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="4" y="5" width="16" height="15" rx="3" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="M8 3.5v4M16 3.5v4M4 9.5h16" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">This Month</span>
          <strong class="stat-value">{{ historySummary.thisMonth }}</strong>
        </article>
      </div>

      <div class="controls">
        <div class="controls-left">
          <label class="control-label" for="history-search">Search</label>
          <input id="history-search" type="text" placeholder="Search Tracking Number" v-model="search" />
        </div>

        <div class="controls-right">
          <div class="date-filter">
            <span class="control-label">Date Added</span>

            <div class="date-filter-row">
              <button ref="dateTrigger" class="btn date-trigger" @click="openCalendar">
                <span class="date-trigger-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24">
                    <rect x="3.5" y="5" width="17" height="15" rx="3.5" fill="none" stroke="currentColor" stroke-width="1.8" />
                    <path d="M7 3.5v4M17 3.5v4M3.5 9.5h17" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
                    <path d="M8 13h3M13 13h3M8 17h3" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
                  </svg>
                </span>
                <span class="date-trigger-text">
                  {{ selectedRangeText || 'Pick date range' }}
                </span>
              </button>

              <button v-if="selectedRangeText" class="clear-filter-btn" @click="clearDateFilter">
                Clear
              </button>

              <button class="btn filter" @click="cycleActivityFilter">
                <span class="filter-icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24">
                    <path d="M4 6h16M7 12h10M10 18h4" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
                  </svg>
                </span>
                <span>{{ filterButtonLabel }}</span>
              </button>
            </div>
          </div>
        </div>

        <input ref="calendarInput" type="text" class="calendar-hidden-input" />
      </div>

      <p v-if="pageError" class="page-message error">{{ pageError }}</p>
      <p
        v-if="actionMessage"
        class="page-message"
        :class="actionMessageType === 'error' ? 'error' : 'success'"
      >
        {{ actionMessage }}
      </p>

      <table>
        <thead>
          <tr>
            <th>Tracking Number</th>
            <th>Date</th>
            <th>Action</th>
          </tr>
        </thead>

        <tbody>
          <tr v-if="loading">
            <td colspan="3" class="table-state">Loading history...</td>
          </tr>
          <tr v-else-if="records.length === 0">
            <td colspan="3" class="table-state">No history records found.</td>
          </tr>
          <tr v-for="record in records" :key="record.id">
            <td>{{ record.trackingNumber || '-' }}</td>
            <td>{{ formatDate(record.date) }}</td>
            <td>{{ record.action }}</td>
          </tr>
        </tbody>
      </table>

      <div class="table-footer" v-if="meta.totalPages > 1">
        <div class="pagination">
          <button class="page-btn" :disabled="meta.page === 1 || loading" @click="changePage(1)"><<</button>
          <button class="page-btn" :disabled="meta.page === 1 || loading" @click="changePage(meta.page - 1)"><</button>
          <button v-for="page in visiblePages" :key="page" class="page-btn" :class="{ active: meta.page === page }" @click="changePage(page)">{{ page }}</button>
          <button class="page-btn" :disabled="meta.page === meta.totalPages || loading" @click="changePage(meta.page + 1)">></button>
          <button class="page-btn" :disabled="meta.page === meta.totalPages || loading" @click="changePage(meta.totalPages)">>></button>
        </div>

        <span class="page-info">Page {{ meta.page }} of {{ meta.totalPages }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import flatpickr from 'flatpickr'
import 'flatpickr/dist/flatpickr.css'
import { apiJsonRequest, downloadFile } from '../lib/api'

const search = ref('')
const calendarInput = ref(null)
const dateTrigger = ref(null)
const dateRange = ref([])
const timeFilter = ref('all')
const activityFilter = ref('all')
const records = ref([])
const loading = ref(false)
const pageError = ref('')
const actionMessage = ref('')
const actionMessageType = ref('success')
const isDownloading = ref(false)
const meta = ref({ page: 1, pageSize: 10, total: 0, totalPages: 1 })
const maxVisiblePages = 3
let calendarInstance = null
let filterTimer = null

const selectedRangeText = computed(() => {
  if (dateRange.value.length !== 2) return ''
  const [start, end] = dateRange.value
  return `${start.toISOString().slice(0, 10)} - ${end.toISOString().slice(0, 10)}`
})

const visiblePages = computed(() => {
  const pages = []
  let start = meta.value.page - 1
  let end = meta.value.page + 1

  if (start < 1) {
    start = 1
    end = Math.min(maxVisiblePages, meta.value.totalPages)
  }

  if (end > meta.value.totalPages) {
    end = meta.value.totalPages
    start = Math.max(1, end - maxVisiblePages + 1)
  }

  for (let i = start; i <= end; i += 1) pages.push(i)
  return pages
})

const historySummary = computed(() => {
  const now = new Date()
  const startOfWeek = new Date(now)
  startOfWeek.setHours(0, 0, 0, 0)
  startOfWeek.setDate(now.getDate() - now.getDay())

  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)

  return {
    total: meta.value.total || records.value.length,
    completed: records.value.filter((record) => /outbound|delivered|completed|resolved/i.test(record.action)).length,
    thisWeek: records.value.filter((record) => {
      const date = new Date(record.date)
      return !Number.isNaN(date.getTime()) && date >= startOfWeek
    }).length,
    thisMonth: records.value.filter((record) => {
      const date = new Date(record.date)
      return !Number.isNaN(date.getTime()) && date >= startOfMonth
    }).length,
  }
})

const filterButtonLabel = computed(() => {
  if (activityFilter.value === 'parcel') return 'Parcel Updates'
  if (activityFilter.value === 'account') return 'Account Activity'
  return 'Filter'
})

function buildHistoryParams(page = meta.value.page) {
  const params = {
    page,
    pageSize: meta.value.pageSize,
    search: search.value.trim() || undefined,
    dateFrom: dateRange.value[0] ? dateRange.value[0].toISOString().slice(0, 10) : undefined,
    dateTo: dateRange.value[1] ? dateRange.value[1].toISOString().slice(0, 10) : undefined,
  }

  if (timeFilter.value === 'week' && !params.dateFrom && !params.dateTo) {
    const now = new Date()
    const start = new Date(now)
    start.setHours(0, 0, 0, 0)
    start.setDate(now.getDate() - now.getDay())
    params.dateFrom = start.toISOString().slice(0, 10)
  } else if (timeFilter.value === 'month' && !params.dateFrom && !params.dateTo) {
    const start = new Date()
    start.setHours(0, 0, 0, 0)
    start.setDate(1)
    params.dateFrom = start.toISOString().slice(0, 10)
  }

  if (activityFilter.value === 'parcel') {
    params.category = 'parcel'
  } else if (activityFilter.value === 'account') {
    params.category = 'account'
  }

  return params
}

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
}

function openCalendar() {
  calendarInstance?.open()
}

function clearDateFilter() {
  dateRange.value = []
  calendarInstance?.clear()
}

function cycleActivityFilter() {
  if (activityFilter.value === 'all') {
    activityFilter.value = 'parcel'
  } else if (activityFilter.value === 'parcel') {
    activityFilter.value = 'account'
  } else {
    activityFilter.value = 'all'
  }
}

async function loadHistory(page = meta.value.page) {
  loading.value = true
  pageError.value = ''

  try {
    const payload = await apiJsonRequest('/history', { params: buildHistoryParams(page) })
    records.value = payload.data ?? []
    meta.value = payload.meta ?? meta.value
  } catch (error) {
    pageError.value = error.message
    records.value = []
  } finally {
    loading.value = false
  }
}

function changePage(page) {
  if (page < 1 || page > meta.value.totalPages) return
  loadHistory(page)
}

async function downloadCSV() {
  isDownloading.value = true

  try {
    await downloadFile('/history/export.csv', {
      params: buildHistoryParams(),
      filename: 'history-records.csv',
    })
    actionMessage.value = 'CSV downloaded successfully.'
    actionMessageType.value = 'success'
  } catch (error) {
    actionMessage.value = error.message
    actionMessageType.value = 'error'
  } finally {
    isDownloading.value = false
  }
}

watch([search, dateRange, timeFilter, activityFilter], () => {
  clearTimeout(filterTimer)
  filterTimer = setTimeout(() => loadHistory(1), 250)
}, { deep: true })

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
      dateRange.value = [...selectedDates]
    },
  })

  loadHistory(1)
})
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
}

.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  padding: 26px;
  box-shadow: var(--shadow-card);
  backdrop-filter: blur(10px);
}

.page-eyebrow {
  margin: 0 0 6px;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: #c75a10;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 22px;
}

.page-header-copy {
  display: flex;
  flex-direction: column;
  gap: 8px;
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

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
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

.stat-icon.green {
  background: #ecfbf1;
  color: #12b356;
}

.stat-icon.purple {
  background: #f7efff;
  color: #9c27ff;
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

.header-actions,
.controls-right {
  display: flex;
  gap: 12px;
  align-items: center;
}

.controls {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 20px;
}

.controls-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 320px;
}

.controls input {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--border-soft);
  border-radius: 16px;
  color: var(--text-main);
  background: #fbfcfe;
  font-size: 16px;
}

.controls-left > input {
  width: 352px;
}

.control-label {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--text-muted);
  line-height: 1;
}

.controls-right {
  justify-content: flex-end;
  flex-wrap: wrap;
  align-items: flex-end;
}

.btn,
.page-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 16px;
  border-radius: 14px;
  border: 1px solid var(--border-strong);
  background: var(--bg-surface-strong);
  color: var(--text-main);
  font-size: 14px;
  font-weight: 700;
  transition: transform 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease;
}

.btn:hover,
.page-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.08);
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

.page-message {
  margin-bottom: 12px;
  padding: 12px 16px;
  border-radius: 14px;
  font-size: 13px;
  background: var(--bg-danger-soft);
}

.page-message.error {
  color: #b64712;
}

.table-state {
  text-align: center;
  color: var(--text-faint);
}

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  overflow: hidden;
  background: #fff;
}

th,
td {
  padding: 18px 30px;
  border-bottom: 1px solid rgba(112, 128, 154, 0.16);
  text-align: center;
  color: var(--text-main);
}

th {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-muted);
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.table-footer {
  margin-top: 18px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.pagination {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.page-btn.active {
  border-color: transparent;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.btn.primary {
  border-color: transparent;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.export-btn {
  min-width: 152px;
  background: #fff;
  color: var(--text-main);
  border: 1px solid var(--border-soft);
  box-shadow: none;
}

.page-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.page-info {
  font-size: 13px;
  color: var(--text-muted);
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
  transform: none;
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

@media (max-width: 720px) {
  .page-header,
  .controls {
    flex-direction: column;
    align-items: stretch;
  }

  .header-actions,
  .controls-right,
  .controls-left,
  .controls-left > input,
  .date-filter,
  .date-filter-row,
  .date-trigger,
  .btn,
  .page-btn {
    width: 100%;
  }

  .date-filter-row {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .controls-right {
    justify-content: stretch;
  }

  .controls input,
  .controls select,
  .btn.primary {
    width: 100%;
  }
}
</style>
