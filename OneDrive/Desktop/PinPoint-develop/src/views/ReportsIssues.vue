<template>
  <div class="page">
    <div class="card">
      <p class="page-eyebrow">Issue Management</p>
      <div class="page-header">
        <div class="page-header-copy">
          <h2>Alerts &amp; Issues</h2>
          <p class="page-subtitle">Monitor and resolve system alerts</p>
        </div>
        <div class="header-actions">
          <button class="btn export-btn" @click="exportReports">Export</button>
          <button class="btn dark" @click="goToReportIssue">+ Report Issue</button>
          <button class="btn" :disabled="selectedCount === 0 || loading" @click="openBulkEdit">Edit</button>
        </div>
      </div>

      <div class="stats-grid">
        <article class="stat-card">
          <div class="stat-icon red">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 4 20 19H4L12 4Z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
              <path d="M12 9v4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <circle cx="12" cy="16.2" r="0.9" fill="currentColor" />
            </svg>
          </div>
          <span class="stat-label">Open Issues</span>
          <strong class="stat-value">{{ reportsSummary.openIssues }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon amber">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M12 8v4l2.5 1.8" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </div>
          <span class="stat-label">In Progress</span>
          <strong class="stat-value">{{ reportsSummary.inProgress }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon green">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="m8.5 12.2 2.4 2.4 4.8-5.2" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </div>
          <span class="stat-label">Resolved</span>
          <strong class="stat-value">{{ reportsSummary.resolved }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon purple">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="m9.5 9.5 5 5m0-5-5 5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">Critical</span>
          <strong class="stat-value">{{ reportsSummary.critical }}</strong>
        </article>
      </div>

      <div class="controls">
        <div class="controls-left">
          <label class="control-label" for="reports-search">Search</label>
          <input id="reports-search" v-model="search" type="text" placeholder="Search Tracking Number" />
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

              <div ref="filterAnchor" class="filter-anchor">
                <button class="btn filter-btn" @click.stop="openFilter">
                  <span class="filter-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                      <path d="M4 6h16M7 12h10M10 18h4" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
                    </svg>
                  </span>
                  <span>Filter</span>
                </button>

                <div v-if="showFilterPopup" class="filter-popup" @click.stop>
                  <h4>Status</h4>
                  <div class="filter-group">
                    <label><input type="checkbox" v-model="filterStatus.Resolved" /> Resolved</label>
                    <label><input type="checkbox" v-model="filterStatus.Unresolved" /> Unresolved</label>
                  </div>

                  <div class="filter-actions">
                    <button class="btn popup-clear" @click="clearFilter">Clear</button>
                    <button class="btn popup-apply" @click="closeFilter">Apply</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <input ref="calendarInput" type="text" class="calendar-hidden-input" />
      </div>

      <p v-if="pageError" class="page-message error">{{ pageError }}</p>

      <table>
        <thead>
          <tr>
            <th>Issue ID</th>
            <th>Title</th>
            <th>Type</th>
            <th>Severity</th>
            <th>Reported By</th>
            <th>Date</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          <tr v-if="loading">
            <td colspan="7" class="table-state">Loading reports...</td>
          </tr>
          <tr v-else-if="issueRows.length === 0">
            <td colspan="7" class="table-state">No reports found.</td>
          </tr>
          <tr
            v-for="row in issueRows"
            :key="row.id"
            @click="toggleSelection(row)"
            :class="{ selected: selectedIssueIds.includes(row.id) }"
          >
            <td class="issue-id-cell">{{ row.displayId }}</td>
            <td class="title-cell">
              <div class="issue-title-block">
                <strong class="issue-title">{{ row.title }}</strong>
                <span class="issue-subtitle">{{ row.subtitle }}</span>
              </div>
            </td>
            <td>{{ row.type }}</td>
            <td><span :class="['severity-pill', row.severity]">{{ row.severity }}</span></td>
            <td>{{ row.reportedBy }}</td>
            <td>{{ row.shortDate }}</td>
            <td>
              <div class="status-dropdown-wrap">
                <select
                  class="status-dropdown issue"
                  :class="row.statusClass"
                  :value="row.status"
                  :disabled="savingStatusId === row.id"
                  @click.stop
                  @change.stop="updateIssueStatus(row, $event.target.value)"
                >
                  <option value="Unresolved">Open</option>
                  <option value="Resolved">Resolved</option>
                </select>
                <button
                  v-if="row.status === 'Resolved'"
                  class="status-remove-btn"
                  :disabled="savingStatusId === row.id"
                  @click.stop="removeResolvedIssue(row)"
                  title="Remove resolved issue"
                >
                  ✕
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="table-footer">
        <div class="pagination" v-if="meta.totalPages > 1">
          <div class="pagination-buttons">
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

    <div v-if="showEditModal" class="modal-backdrop" @click.self="closeEdit">
      <div class="modal edit-modal">
        <button class="modal-close" @click="closeEdit">x</button>
        <h3>{{ editForm.ids.length > 1 ? 'Bulk Edit Reports / Issues' : 'Edit Reports / Issues' }}</h3>

        <div class="form-group">
          <label>{{ editForm.ids.length > 1 ? 'Selected Reports' : 'Tracking Number' }}</label>
          <div class="readonly-box">{{ editForm.trackingNumber }}</div>
        </div>

        <div v-if="editForm.ids.length > 1" class="form-group">
          <label>Tracking Numbers</label>
          <textarea class="remarks-textbox bulk-summary" :value="editForm.summary" disabled></textarea>
        </div>

        <div class="form-group">
          <label>Remarks</label>
          <textarea v-model="editForm.remarks" placeholder="Enter text" class="remarks-textbox"></textarea>
        </div>

        <div class="form-group">
          <label>Edit Status</label>
          <div class="status-options">
            <label><input type="radio" value="Unresolved" v-model="editForm.status" /> Unresolved</label>
            <label><input type="radio" value="Resolved" v-model="editForm.status" /> Resolved</label>
          </div>
        </div>

        <p v-if="editError" class="page-message error">{{ editError }}</p>

        <div class="form-actions">
          <button class="btn primary update-btn" @click="updateIssue" :disabled="savingEdit">{{ savingEdit ? 'Saving...' : 'Update' }}</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import flatpickr from 'flatpickr'
import 'flatpickr/dist/flatpickr.css'
import { useRoute, useRouter } from 'vue-router'
import { apiJsonRequest, apiRequest } from '../lib/api'
import { fetchAlerts } from '../lib/alerts'
import { DATA_EVENTS, emitDataEvent, subscribeToDataEvent } from '../lib/dataEvents'

const router = useRouter()
const search = ref('')
const selectedIssueIds = ref([])
const showEditModal = ref(false)
const showFilterPopup = ref(false)
const loading = ref(false)
const savingEdit = ref(false)
const savingStatusId = ref(null)
const pageError = ref('')
const editError = ref('')
const issues = ref([])
const alerts = ref([])
const pageSize = 15
const maxVisiblePages = 3
const meta = ref({ page: 1, pageSize, total: 0, totalPages: 1 })
let filterTimer = null
const route = useRoute()
const calendarInput = ref(null)
const dateTrigger = ref(null)
const filterAnchor = ref(null)
const dateRange = ref([])
let calendarInstance = null

const filterStatus = ref({ Resolved: false, Unresolved: false })
const selectedIssues = computed(() => issues.value.filter(issue => selectedIssueIds.value.includes(issue.id)))
const selectedCount = computed(() => selectedIssues.value.length)
const selectedIssue = computed(() => selectedIssues.value[0] ?? null)
const editForm = ref({ ids: [], trackingNumber: '', summary: '', remarks: '', status: 'Unresolved' })
const reportsSummary = computed(() => {
  const now = new Date()
  const startOfWeek = new Date(now)
  startOfWeek.setHours(0, 0, 0, 0)
  startOfWeek.setDate(now.getDate() - now.getDay())

  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)

  return {
    total: meta.value.total || issues.value.length,
    openIssues: issues.value.filter(issue => issue.status === 'Unresolved').length,
    inProgress: alerts.value.filter(alert => alert.severity === 'warning').length,
    resolved: issues.value.filter(issue => issue.status === 'Resolved').length,
    critical: alerts.value.filter(alert => alert.severity === 'critical').length,
    thisWeek: issues.value.filter((issue) => {
      const date = new Date(issue.reportedAt)
      return !Number.isNaN(date.getTime()) && date >= startOfWeek
    }).length,
    thisMonth: issues.value.filter((issue) => {
      const date = new Date(issue.reportedAt)
      return !Number.isNaN(date.getTime()) && date >= startOfMonth
    }).length,
  }
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

const issueRows = computed(() => {
  const startIndex = (meta.value.page - 1) * meta.value.pageSize

  return issues.value
    .map((issue, index) => {
      const linkedAlert = alerts.value.find((alert) => alert.trackingNumber === issue.trackingNumber)
      const severity = linkedAlert?.severity === 'critical' ? 'critical' : 'medium'
      const type = /damage|damaged/i.test(issue.remarks) ? 'damaged' : 'other'
      const statusClass = issue.status === 'Resolved' ? 'resolved' : 'open'

      return {
        ...issue,
        displayId: Math.max(1, meta.value.total - startIndex - index),
        title: `Flagged for review: ${issue.trackingNumber}`,
        subtitle: issue.remarks,
        type,
        severity,
        reportedBy: issue.reportedBy || '-',
        shortDate: formatShortDate(issue.reportedAt),
        statusLabel: statusClass,
        statusClass,
      }
    })
    .filter((issue) => {
      const matchesSearch = !search.value.trim() || issue.trackingNumber.toLowerCase().includes(search.value.trim().toLowerCase())
      if (!matchesSearch) {
        return false
      }

      const activeStatuses = Object.keys(filterStatus.value).filter((key) => filterStatus.value[key])
      if (activeStatuses.length && !activeStatuses.includes(issue.status)) {
        return false
      }

      if (dateRange.value.length === 2) {
        const reportedAt = new Date(issue.reportedAt)
        const start = new Date(dateRange.value[0])
        const end = new Date(dateRange.value[1])
        start.setHours(0, 0, 0, 0)
        end.setHours(23, 59, 59, 999)

        if (Number.isNaN(reportedAt.getTime()) || reportedAt < start || reportedAt > end) {
          return false
        }
      }

      return true
    })
})

const selectedRangeText = computed(() => {
  if (dateRange.value.length !== 2) return ''
  const [start, end] = dateRange.value
  return `${start.toISOString().slice(0, 10)} - ${end.toISOString().slice(0, 10)}`
})

function buildReportParams(page = meta.value.page) {
  const activeStatuses = Object.keys(filterStatus.value).filter(key => filterStatus.value[key])
  return {
    page,
    pageSize,
    search: search.value.trim() || undefined,
    status: activeStatuses.length ? activeStatuses.join(',') : undefined,
  }
}

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
}

function formatShortDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString(undefined)
}

async function loadReports(page = meta.value.page) {
  loading.value = true
  pageError.value = ''

  try {
    const [payload, nextAlerts] = await Promise.all([
      apiJsonRequest('/reports', { params: buildReportParams(page) }),
      fetchAlerts().catch(() => []),
    ])
    issues.value = payload.data ?? []
    meta.value = payload.meta ?? meta.value
    alerts.value = nextAlerts

    selectedIssueIds.value = selectedIssueIds.value.filter((id) => issues.value.some(issue => issue.id === id))
  } catch (error) {
    pageError.value = error.message
    issues.value = []
    alerts.value = []
    selectedIssueIds.value = []
  } finally {
    loading.value = false
  }
}

function changePage(page) {
  if (page < 1 || page > meta.value.totalPages) return
  loadReports(page)
}

function toggleSelection(issue) {
  selectedIssueIds.value = selectedIssueIds.value.includes(issue.id)
    ? selectedIssueIds.value.filter((id) => id !== issue.id)
    : [...selectedIssueIds.value, issue.id]
}

function getSelectedTargets() {
  return selectedIssueIds.value
    .map((id) => issues.value.find((issue) => issue.id === id))
    .filter(Boolean)
}

function openEdit(issue = null) {
  const targets = issue ? [issue] : getSelectedTargets()
  if (!targets.length) return
  editError.value = ''

  if (targets.length === 1) {
    const [target] = targets
    editForm.value = {
      ids: [target.id],
      trackingNumber: target.trackingNumber,
      summary: target.trackingNumber,
      remarks: target.remarks,
      status: target.status,
    }
    selectedIssueIds.value = [target.id]
  } else {
    editForm.value = {
      ids: targets.map((target) => target.id),
      trackingNumber: `${targets.length} reports selected`,
      summary: targets.map((target) => target.trackingNumber).join('\n'),
      remarks: '',
      status: 'Unresolved',
    }
  }

  showEditModal.value = true
}

function openBulkEdit() {
  openEdit()
}

function closeEdit() {
  showEditModal.value = false
}

function openCalendar() {
  calendarInstance?.open()
}

function clearDateFilter() {
  dateRange.value = []
  calendarInstance?.clear()
}

function exportReports() {
  const rows = [
    ['Tracking Number', 'Date Reported', 'Reported By', 'Remarks', 'Status'],
    ...issues.value.map((issue) => [
      issue.trackingNumber,
      formatDate(issue.reportedAt),
      issue.reportedBy || '-',
      issue.remarks,
      issue.status,
    ]),
  ]

  const csv = rows
    .map((row) => row.map((value) => `"${String(value ?? '').replace(/"/g, '""')}"`).join(','))
    .join('\n')

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'reports-issues.csv'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

async function goToReportIssue() {
  await router.push({ name: 'OrderRecords' })
}

async function updateIssue() {
  savingEdit.value = true
  editError.value = ''

  try {
    await Promise.all(
      editForm.value.ids.map((id) =>
        apiRequest(`/reports/${id}`, {
          method: 'PATCH',
          body: {
            remarks: editForm.value.remarks,
            status: editForm.value.status,
          },
        })
      )
    )
    closeEdit()
    await loadReports(meta.value.page)
    emitDataEvent(DATA_EVENTS.notificationsRefresh)
  } catch (error) {
    editError.value = error.message
  } finally {
    savingEdit.value = false
  }
}

async function updateIssueStatus(issue, status) {
  savingStatusId.value = issue.id
  editError.value = ''

  try {
    await apiRequest(`/reports/${issue.id}`, {
      method: 'PATCH',
      body: {
        remarks: issue.remarks,
        status,
      },
    })
    await loadReports(meta.value.page)
    emitDataEvent(DATA_EVENTS.notificationsRefresh)
  } catch (error) {
    editError.value = error.message
  } finally {
    savingStatusId.value = null
  }
}

async function removeResolvedIssue(issue) {
  savingStatusId.value = issue.id

  try {
    await apiRequest(`/reports/${issue.id}`, {
      method: 'DELETE',
    })
    await loadReports(meta.value.page)
    emitDataEvent(DATA_EVENTS.notificationsRefresh)
  } catch (error) {
    editError.value = error.message
  } finally {
    savingStatusId.value = null
  }
}

function openFilter() {
  showFilterPopup.value = !showFilterPopup.value
}

function closeFilter() {
  showFilterPopup.value = false
}

function clearFilter() {
  filterStatus.value.Resolved = false
  filterStatus.value.Unresolved = false
}

function handleDocumentClick(event) {
  if (showFilterPopup.value && filterAnchor.value && !filterAnchor.value.contains(event.target)) {
    closeFilter()
  }
}

watch([search, filterStatus], () => {
  clearTimeout(filterTimer)
  filterTimer = setTimeout(() => loadReports(1), 250)
}, { deep: true })

watch(
  () => route.query.search,
  (nextSearch) => {
    if (typeof nextSearch === 'string' && nextSearch !== search.value) {
      search.value = nextSearch
    }
  },
  { immediate: true },
)

let cleanupReportsRefresh = null

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
  document.addEventListener('click', handleDocumentClick)
  cleanupReportsRefresh = subscribeToDataEvent(DATA_EVENTS.notificationsRefresh, () => {
    loadReports(meta.value.page)
  })
  loadReports(1)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick)
  cleanupReportsRefresh?.()
})
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
}

.card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 26px;
  color: var(--text-main);
  border: 1px solid var(--border-soft);
  box-shadow: var(--shadow-card);
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

.page-eyebrow {
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
}

.page-subtitle {
  margin: 0;
  font-size: 0.98rem;
  color: var(--text-muted);
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
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

.stat-icon.red {
  background: #ffe7e5;
  color: #d93a2f;
}

.stat-icon.green {
  background: #ecfbf1;
  color: #12b356;
}

.stat-icon.purple {
  background: #f7efff;
  color: #9c27ff;
}

.stat-icon.amber {
  background: #fff1da;
  color: #dd7a00;
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
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 24px;
}

.controls-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 320px;
}

.controls input,
.remarks-textbox,
.readonly-box {
  background: #fbfcfe;
  color: var(--text-main);
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid var(--border-soft);
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
  display: flex;
  justify-content: flex-end;
  flex-wrap: wrap;
  align-items: flex-end;
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

.filter-btn {
  gap: 10px;
  min-width: 122px;
}

.calendar-hidden-input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
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
  table-layout: auto;
  border: 1px solid var(--border-soft);
  border-radius: 20px;
  overflow: hidden;
  background: #fff;
  box-shadow: var(--shadow-soft);
}

th,
td {
  padding: 18px 16px;
  border-bottom: 1px solid rgba(112, 128, 154, 0.16);
  text-align: center;
}

th {
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

tr.selected td {
  background: rgba(255, 111, 0, 0.08);
}

.issue-id-cell {
  width: 80px;
  font-weight: 700;
}

.title-cell {
  text-align: left;
  min-width: 360px;
}

.issue-title-block {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.issue-title {
  font-size: 1rem;
  font-weight: 500;
  color: var(--text-main);
}

.issue-subtitle {
  font-size: 0.95rem;
  color: var(--text-muted);
  white-space: normal;
  word-break: break-word;
}

.severity-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 94px;
  padding: 7px 14px;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 700;
  text-transform: lowercase;
}

.severity-pill.medium {
  background: #fff6d8;
  color: #9f6a00;
}

.severity-pill.critical {
  background: #ffe8e6;
  color: #c53b30;
}

.status-dropdown-wrap {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}

.status-dropdown {
  min-width: 132px;
  min-height: 40px;
  padding: 0 38px 0 14px;
  border-radius: 999px;
  border: 1px solid transparent;
  font-size: 0.92rem;
  font-weight: 700;
  text-transform: capitalize;
  appearance: none;
  background-position: right 14px center;
  background-repeat: no-repeat;
  background-size: 12px;
  cursor: pointer;
}

.status-dropdown.issue.open {
  background-color: #fff6d8;
  border-color: rgba(159, 106, 0, 0.12);
  color: #9f6a00;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12'%3E%3Cpath d='M2 4.5 6 8l4-3.5' fill='none' stroke='%239f6a00' stroke-width='1.6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
}

.status-dropdown.issue.resolved {
  background-color: #ecfbf1;
  border-color: rgba(15, 127, 87, 0.12);
  color: #0f7f57;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12'%3E%3Cpath d='M2 4.5 6 8l4-3.5' fill='none' stroke='%230f7f57' stroke-width='1.6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
}

.status-remove-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 1px solid rgba(15, 127, 87, 0.12);
  background: #ecfbf1;
  color: #0f7f57;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  transition: background-color 0.2s ease, border-color 0.2s ease;
}

.status-remove-btn:hover {
  background: #d4f4e4;
  border-color: rgba(15, 127, 87, 0.24);
}

.status-remove-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn,
.page-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 20px;
  border: 1px solid var(--border-soft);
  border-radius: 14px;
  background: #fff;
  cursor: pointer;
  color: var(--text-main);
  font-weight: 700;
  font-size: 14px;
  transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease, background-color 0.18s ease;
}

.btn:hover,
.page-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.08);
}

.btn.primary,
.page-btn.active {
  border-color: transparent;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.btn.dark {
  border-color: transparent;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.btn.dark:hover,
.btn.primary:hover,
.page-btn.active:hover {
  box-shadow: 0 16px 26px rgba(255, 90, 0, 0.28);
}

.export-btn {
  min-width: 118px;
  background: #fff;
  color: var(--text-main);
  border-color: var(--border-soft);
  box-shadow: none;
}

.btn:disabled,
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.modal-backdrop,
.modal {
  background: #fff;
  padding: 28px;
  width: min(380px, calc(100vw - 32px));
  border-radius: 22px;
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: var(--text-main);
  border: 1px solid var(--border-soft);
  box-shadow: var(--shadow-soft);
}

.modal-close {
  position: absolute;
  top: 10px;
  right: 12px;
  background: none;
  border: none;
  font-size: 22px;
  cursor: pointer;
  color: var(--text-muted) !important;
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
  box-shadow: 0 26px 56px rgba(15, 23, 42, 0.16);
}

.filter-group {
  display: grid;
  gap: 12px;
  font-size: 15px;
}

.filter-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 18px;
}

.filter-actions .btn {
  min-width: 98px;
  padding: 0 16px;
  font-size: 14px;
}

.filter-popup h4 {
  margin: 0 0 14px;
  font-size: 13px;
  color: var(--text-muted);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.filter-group label {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 40px;
  color: var(--text-main);
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

.edit-modal {
  width: min(420px, calc(100vw - 32px));
}

.edit-modal h3 {
  text-align: center;
  margin: 0 0 18px;
  font-size: 1.4rem;
}

.edit-modal .form-group {
  margin-bottom: 14px;
}

.status-options {
  display: flex;
  justify-content: center;
  gap: 20px;
  border: 1px solid var(--border-soft);
  padding: 12px;
  border-radius: 16px;
  background: var(--bg-panel);
}

.status-options label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.update-btn {
  width: 160px;
}

.remarks-textbox {
  min-height: 120px;
  resize: vertical;
  width: 100%;
}

.bulk-summary {
  min-height: 96px;
  white-space: pre-wrap;
}

.form-actions {
  display: flex;
  justify-content: center;
  margin-top: 22px;
}

.table-footer {
  display: flex;
  justify-content: center;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: max-content;
  margin-top: 16px;
  flex-wrap: wrap;
}

.pagination-buttons {
  display: flex;
  gap: 6px;
}

.page-info {
  font-size: 13px;
  color: var(--text-muted);
  margin-left: 10px;
}

@media (max-width: 720px) {
  .page-header,
  .controls {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .header-actions,
  .controls-right,
  .controls-left,
  .controls-left > input,
  .date-filter,
  .date-filter-row,
  .date-trigger,
  .btn {
    width: 100%;
  }

  .date-filter-row {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
