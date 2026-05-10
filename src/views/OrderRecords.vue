<template>
  <div class="page">
    <div class="card">
      <p class="page-eyebrow">Parcel Operations</p>
      <div class="page-header">
        <div class="page-header-copy">
          <h2>Order Records</h2>
          <p class="page-subtitle">Manage parcels, scans, and outbound activity</p>
        </div>
        <div class="header-actions">
          <button class="btn export-btn" @click="downloadCSV" :disabled="isDownloading">
            {{ isDownloading ? 'Exporting...' : 'Export' }}
          </button>
          <button class="btn" @click="loadParcels(1)" :disabled="parcelsLoading">
            {{ parcelsLoading ? 'Refreshing...' : 'Refresh' }}
          </button>
          <button class="btn primary" @click="openAddParcelModal">+ Add Parcel</button>
          <button class="btn" :disabled="selectedCount === 0 || parcelsLoading" @click="openBulkEdit">Edit</button>
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
          <strong class="stat-value">{{ orderSummary.total }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon green">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="m8.5 12.2 2.4 2.4 4.8-5.2" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </div>
          <span class="stat-label">Completed</span>
          <strong class="stat-value">{{ orderSummary.completed }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon purple">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="4" y="5" width="16" height="15" rx="3" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="M8 3.5v4M16 3.5v4M4 9.5h16" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">This Week</span>
          <strong class="stat-value">{{ orderSummary.thisWeek }}</strong>
        </article>

        <article class="stat-card">
          <div class="stat-icon orange">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="4" y="5" width="16" height="15" rx="3" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="M8 3.5v4M16 3.5v4M4 9.5h16" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
            </svg>
          </div>
          <span class="stat-label">This Month</span>
          <strong class="stat-value">{{ orderSummary.thisMonth }}</strong>
        </article>
      </div>

      <div class="controls">
        <div class="controls-left">
          <label class="control-label" for="order-search">Search</label>
          <input id="order-search" type="text" placeholder="Search Tracking Number" v-model="search" />
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
            </div>
          </div>

          <div ref="filterAnchor" class="filter-anchor">
            <button class="btn filter" @click.stop="openFilter">
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
                <label v-for="(value, key) in filterStatus" :key="key" class="filter-option">
                  <input type="checkbox" v-model="filterStatus[key]" />
                  <span>{{ key }}</span>
                </label>
              </div>

              <h4>Platform</h4>
              <div class="filter-group">
                <label v-for="(value, key) in filterPlatform" :key="key" class="filter-option">
                  <input type="checkbox" v-model="filterPlatform[key]" />
                  <span>{{ key }}</span>
                </label>
              </div>

              <div class="filter-actions">
                <button class="btn popup-clear" @click="clearFilter">Clear</button>
                <button class="btn popup-apply" @click="closeFilter">Filter</button>
              </div>
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

      <div class="scan-panel">
        <div class="scan-panel-left">
          <label class="scan-label" for="scan-waybill">Scan Waybill</label>
          <input
            id="scan-waybill"
            ref="scanInput"
            v-model="scanTracking"
            type="text"
            class="scan-input"
            placeholder="Scan or enter tracking number"
            @keydown.enter.prevent="submitScan"
          />
        </div>
        <div class="scan-panel-actions">
          <button class="btn primary" @click="submitScan" :disabled="scanningParcel">{{ scanningParcel ? 'Scanning...' : 'Scan' }}</button>
        </div>
      </div>

      <p v-if="scanFeedback" class="page-message" :class="scanFeedbackType === 'error' ? 'error' : 'success'">{{ scanFeedback }}</p>

      <table>
        <thead>
          <tr>
            <th></th>
            <th>Tracking Number</th>
            <th>Platform</th>
            <th>Date Added</th>
            <th>Outbound Date</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          <tr v-if="parcelsLoading">
            <td colspan="6" class="table-state">Loading parcels...</td>
          </tr>
          <tr v-else-if="parcels.length === 0">
            <td colspan="6" class="table-state">No parcels found.</td>
          </tr>
          <tr
            v-for="parcel in parcels"
            :key="parcel.id"
            :id="`parcel-row-${parcel.trackingNumber}`"
            @click="toggleSelection(parcel)"
            :class="{
              selected: selectedParcelIds.includes(parcel.id),
              highlight: highlightedTracking === parcel.trackingNumber,
            }"
          >
            <td class="select-cell">
              <button
                type="button"
                class="row-check"
                :class="{ checked: selectedParcelIds.includes(parcel.id) }"
                :aria-pressed="selectedParcelIds.includes(parcel.id)"
                :aria-label="selectedParcelIds.includes(parcel.id) ? `Deselect ${parcel.trackingNumber}` : `Select ${parcel.trackingNumber}`"
                @click.stop="toggleSelection(parcel)"
              >
                <svg viewBox="0 0 20 20" aria-hidden="true">
                  <path d="M5 10.5 8.2 13.5 15 6.8" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
              </button>
            </td>
            <td>{{ parcel.trackingNumber }}</td>
            <td>{{ parcel.platform }}</td>
            <td>{{ formatDate(parcel.dateAdded) }}</td>
            <td>{{ formatDate(parcel.outboundDate) }}</td>
            <td>
              <div class="status-dropdown-wrap">
                <button
                  type="button"
                  class="status-dropdown order"
                  :class="[formatStatus(parcel.status), { open: openStatusMenuId === parcel.id }]"
                  :disabled="savingInlineParcelId === parcel.id"
                  @click.stop="toggleStatusMenu(parcel.id)"
                >
                  <span>{{ parcel.status }}</span>
                  <span class="status-dropdown-chevron" aria-hidden="true">
                    <svg viewBox="0 0 12 12">
                      <path d="M2 4.5 6 8l4-3.5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </span>
                </button>

                <div v-if="openStatusMenuId === parcel.id" class="status-menu" @click.stop>
                  <button
                    v-for="status in statuses"
                    :key="status"
                    type="button"
                    class="status-menu-option"
                    :class="{ selected: status === parcel.status }"
                    @click.stop="chooseParcelStatus(parcel, status)"
                  >
                    {{ status }}
                  </button>
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="table-footer">
        <div class="pagination" v-if="meta.totalPages > 1">
          <div class="pagination-buttons">
            <button class="page-btn" :disabled="meta.page === 1 || parcelsLoading" @click="changePage(1)"><<</button>
            <button class="page-btn" :disabled="meta.page === 1 || parcelsLoading" @click="changePage(meta.page - 1)"><</button>
            <button v-for="page in visiblePages" :key="page" class="page-btn" :class="{ active: meta.page === page }" @click="changePage(page)">{{ page }}</button>
            <button class="page-btn" :disabled="meta.page === meta.totalPages || parcelsLoading" @click="changePage(meta.page + 1)">></button>
            <button class="page-btn" :disabled="meta.page === meta.totalPages || parcelsLoading" @click="changePage(meta.totalPages)">>></button>
          </div>
          <span class="page-info">Page {{ meta.page }} of {{ meta.totalPages }}</span>
        </div>
      </div>
    </div>

    <div v-if="showAddParcelModal" class="modal-backdrop" @click.self="closeAddParcelModal">
      <div class="modal">
        <button class="modal-close" @click="closeAddParcelModal">x</button>
        <h3>Add Parcel</h3>

        <div class="form-group">
          <div class="tracking-input-row">
            <div class="tracking-input-wrap">
              <label>Tracking Number</label>
              <input v-model="addForm.tracking" placeholder="Enter tracking number" type="text" :disabled="!addForm.manualInput" />
            </div>
            <button 
              class="lock-btn"
              :class="{ locked: !addForm.manualInput, unlocked: addForm.manualInput }"
              @click="addForm.manualInput = !addForm.manualInput"
              :title="addForm.manualInput ? 'Lock input (use scanner)' : 'Unlock input (manual entry)'"
              aria-label="Toggle manual input"
            >
              <svg v-if="addForm.manualInput" viewBox="0 0 24 24" class="lock-icon">
                <rect x="7" y="11" width="10" height="8" rx="1" fill="none" stroke="currentColor" stroke-width="1.8" />
                <path d="M9 11V8a3 3 0 0 1 6 0v3" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              </svg>
              <svg v-else viewBox="0 0 24 24" class="lock-icon">
                <rect x="7" y="11" width="10" height="8" rx="1" fill="none" stroke="currentColor" stroke-width="1.8" />
                <path d="M9 11V8a3 3 0 0 1 6 0v3M12 14v3" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              </svg>
            </button>
          </div>
        </div>

        <div class="form-group">
          <label>Platform</label>
          <FancySelect
            v-model="addForm.platform"
            :options="platformOptions"
            placeholder="Select platform"
            variant="field"
          />
        </div>

        <div class="form-group">
          <label>Status</label>
          <FancySelect
            v-model="addForm.status"
            :options="statusOptions"
            placeholder="Select status"
            variant="field"
          />
        </div>

        <p v-if="addError" class="panel-message error">{{ addError }}</p>

        <div class="form-actions">
          <button 
            class="btn secondary" 
            @click="openScannerWindow"
            type="button"
          >
            <svg viewBox="0 0 24 24" class="action-icon" aria-hidden="true">
              <rect x="4" y="4" width="16" height="16" rx="2" fill="none" stroke="currentColor" stroke-width="1.9" />
              <path d="M7 7h3v3H7zM14 7h3v3h-3zM14 14h3v3h-3zM7 14h3v3H7z" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round" />
            </svg>
            Go to Scanner
          </button>
          <button class="btn primary" @click="submitAddParcel" :disabled="savingAddParcel">{{ savingAddParcel ? 'Saving...' : 'Add Parcel' }}</button>
        </div>
      </div>
    </div>

    <div v-if="showEditModal" class="modal-backdrop" @click.self="closeEdit">
      <div class="modal">
        <button class="modal-close" @click="closeEdit">x</button>
        <h3>{{ editForm.ids.length > 1 ? 'Bulk Edit Orders' : 'Edit Order' }}</h3>

        <div class="form-group">
          <label>{{ editForm.ids.length > 1 ? 'Selected Parcels' : 'Tracking Number' }}</label>
          <input :value="editForm.trackingNumber" disabled />
        </div>

        <div v-if="editForm.ids.length > 1" class="form-group">
          <label>Tracking Numbers</label>
          <textarea class="remarks-box bulk-summary" :value="editForm.summary" disabled></textarea>
        </div>

        <div class="form-group">
          <label>Edit Status</label>
          <FancySelect
            v-model="editForm.status"
            :options="statusOptions"
            :placeholder="editForm.ids.length > 1 ? 'Keep current status' : 'Select status'"
            variant="field"
          />
        </div>

        <p v-if="editError" class="panel-message error">{{ editError }}</p>

        <div class="form-actions">
          <button class="btn primary" @click="updateParcel" :disabled="savingEditParcel">{{ savingEditParcel ? 'Saving...' : 'Update' }}</button>
        </div>
      </div>
    </div>

    <div v-if="showReportModal" class="modal-backdrop" @click.self="closeReportModal">
      <div class="modal">
        <button class="modal-close" @click="closeReportModal">x</button>
        <h3>Report Issue</h3>

        <div class="form-group">
          <label>Tracking Number</label>
          <input :value="selectedParcel?.trackingNumber ?? ''" disabled />
        </div>

        <div class="form-group">
          <label>Remarks</label>
          <textarea v-model="reportForm.remarks" class="remarks-box" placeholder="Describe the issue"></textarea>
        </div>

        <p v-if="reportError" class="panel-message error">{{ reportError }}</p>

        <div class="form-actions">
          <button class="btn primary" @click="submitReport" :disabled="savingReport">{{ savingReport ? 'Submitting...' : 'Submit Report' }}</button>
        </div>
      </div>
    </div>

    <div class="card-buttons">
      <button class="btn primary" @click="downloadCSV" :disabled="isDownloading">{{ isDownloading ? 'Downloading...' : 'Download CSV' }}</button>
      <button class="btn" :disabled="selectedParcels.length !== 1 || savingReport" @click="openReportModal">Report Issues</button>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import flatpickr from 'flatpickr'
import 'flatpickr/dist/flatpickr.css'
import { useRoute } from 'vue-router'
import FancySelect from '../components/FancySelect.vue'
import { apiJsonRequest, apiRequest, downloadFile } from '../lib/api'
import { DATA_EVENTS, emitDataEvent, subscribeToDataEvent } from '../lib/dataEvents'

const platforms = ['JNT', 'SPX', 'FLH', 'LZD']
const statuses = ['Pending', 'Outbound', 'Cancelled', 'Returned', 'Double Waybill', 'Missing', 'Lost']
const platformOptions = platforms.map((platform) => ({ label: platform, value: platform }))
const statusOptions = statuses.map((status) => ({ label: status, value: status }))
const pageSize = 15
const maxVisiblePages = 3
const route = useRoute()

const search = ref('')
const parcels = ref([])
const selectedParcelIds = ref([])
const showEditModal = ref(false)
const showAddParcelModal = ref(false)
const showReportModal = ref(false)
const showFilterPopup = ref(false)
const openStatusMenuId = ref(null)
const isDownloading = ref(false)
const parcelsLoading = ref(false)
const savingAddParcel = ref(false)
const savingEditParcel = ref(false)
const savingReport = ref(false)
const savingInlineParcelId = ref(null)
const pageError = ref('')
const actionMessage = ref('')
const actionMessageType = ref('success')
const addError = ref('')
const editError = ref('')
const reportError = ref('')
const scanTracking = ref('')
const scanningParcel = ref(false)
const scanFeedback = ref('')
const scanFeedbackType = ref('success')
const scanInput = ref(null)
const highlightedTracking = ref('')
const resolvingHighlight = ref(false)
let highlightTimer = null

const meta = ref({ page: 1, pageSize, total: 0, totalPages: 1 })
const calendarInput = ref(null)
const dateTrigger = ref(null)
const filterAnchor = ref(null)
const dateRange = ref([])
let calendarInstance = null
let filterTimer = null
let cleanupNotifications = null
let cleanupParcels = null

const addForm = ref({ tracking: '', manualInput: true, platform: '', status: '' })
const editForm = ref({ ids: [], trackingNumber: '', status: '', summary: '' })
const reportForm = ref({ remarks: '' })

const filterStatus = ref({ Pending: false, Outbound: false, Cancelled: false, Returned: false, 'Double Waybill': false, Missing: false, Lost: false })
const filterPlatform = ref({ JNT: false, SPX: false, FLH: false, LZD: false })

const selectedParcels = computed(() => parcels.value.filter(parcel => selectedParcelIds.value.includes(parcel.id)))
const selectedCount = computed(() => selectedParcels.value.length)
const selectedParcel = computed(() => selectedParcels.value[0] ?? null)
const orderSummary = computed(() => {
  const now = new Date()
  const startOfWeek = new Date(now)
  startOfWeek.setHours(0, 0, 0, 0)
  startOfWeek.setDate(now.getDate() - now.getDay())

  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)

  return {
    total: meta.value.total || parcels.value.length,
    completed: parcels.value.filter(parcel => parcel.status === 'Outbound').length,
    thisWeek: parcels.value.filter((parcel) => {
      const date = new Date(parcel.dateAdded)
      return !Number.isNaN(date.getTime()) && date >= startOfWeek
    }).length,
    thisMonth: parcels.value.filter((parcel) => {
      const date = new Date(parcel.dateAdded)
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

const selectedRangeText = computed(() => {
  if (dateRange.value.length !== 2) return ''
  const [start, end] = dateRange.value
  const toISO = date => date.toISOString().slice(0, 10)
  return `${toISO(start)} - ${toISO(end)}`
})

function formatStatus(status) {
  return status.toLowerCase().replace(/\s+/g, '-')
}

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
}

function buildParcelParams(page = meta.value.page) {
  const activeStatuses = Object.keys(filterStatus.value).filter(key => filterStatus.value[key])
  const activePlatforms = Object.keys(filterPlatform.value).filter(key => filterPlatform.value[key])

  return {
    page,
    pageSize,
    search: search.value.trim() || undefined,
    status: activeStatuses.length ? activeStatuses.join(',') : undefined,
    platform: activePlatforms.length ? activePlatforms.join(',') : undefined,
    dateFrom: dateRange.value[0] ? dateRange.value[0].toISOString().slice(0, 10) : undefined,
    dateTo: dateRange.value[1] ? dateRange.value[1].toISOString().slice(0, 10) : undefined,
  }
}

function applyParcelsPayload(payload, fallbackPage = meta.value.page) {
  parcels.value = payload.data ?? []
  meta.value = payload.meta ?? { ...meta.value, page: fallbackPage }
  selectedParcelIds.value = selectedParcelIds.value.filter((id) => parcels.value.some(parcel => parcel.id === id))
}

async function loadParcels(page = meta.value.page) {
  parcelsLoading.value = true
  pageError.value = ''

  try {
    const payload = await apiJsonRequest('/parcels', { params: buildParcelParams(page) })
    applyParcelsPayload(payload, page)
  } catch (error) {
    pageError.value = error.message
    parcels.value = []
    selectedParcelIds.value = []
  } finally {
    parcelsLoading.value = false
  }
}

async function highlightParcel(trackingNumber) {
  highlightedTracking.value = trackingNumber
  await nextTick()

  const row = document.getElementById(`parcel-row-${trackingNumber}`)
  row?.scrollIntoView({ behavior: 'smooth', block: 'center' })

  clearTimeout(highlightTimer)
  highlightTimer = setTimeout(() => {
    if (highlightedTracking.value === trackingNumber) {
      highlightedTracking.value = ''
    }
  }, 3200)
}

async function revealParcelByTracking(trackingNumber) {
  const existing = parcels.value.find((entry) => entry.trackingNumber === trackingNumber)

  if (existing) {
    selectedParcelIds.value = [existing.id]
    await highlightParcel(trackingNumber)
    return
  }

  if (resolvingHighlight.value) {
    return
  }

  resolvingHighlight.value = true

  try {
    const totalPages = Math.max(meta.value.totalPages || 1, 1)

    for (let candidatePage = 1; candidatePage <= totalPages; candidatePage += 1) {
      const payload = await apiJsonRequest('/parcels', { params: buildParcelParams(candidatePage) })
      const parcel = (payload.data ?? []).find((entry) => entry.trackingNumber === trackingNumber)

      if (!parcel) {
        continue
      }

      applyParcelsPayload(payload, candidatePage)
      selectedParcelIds.value = [parcel.id]
      await highlightParcel(trackingNumber)
      return
    }
  } finally {
    resolvingHighlight.value = false
  }
}

function toggleSelection(parcel) {
  selectedParcelIds.value = selectedParcelIds.value.includes(parcel.id)
    ? selectedParcelIds.value.filter((id) => id !== parcel.id)
    : [...selectedParcelIds.value, parcel.id]
}

function getSelectedTargets() {
  return selectedParcelIds.value
    .map((id) => parcels.value.find((parcel) => parcel.id === id))
    .filter(Boolean)
}

function changePage(page) {
  if (page < 1 || page > meta.value.totalPages) return
  loadParcels(page)
}

function openCalendar() {
  calendarInstance?.open()
}

function clearDateFilter() {
  dateRange.value = []
  calendarInstance?.clear()
}

function openFilter() {
  showFilterPopup.value = !showFilterPopup.value
  openStatusMenuId.value = null
}

function closeFilter() {
  showFilterPopup.value = false
}

function toggleStatusMenu(parcelId) {
  showFilterPopup.value = false
  openStatusMenuId.value = openStatusMenuId.value === parcelId ? null : parcelId
}

async function chooseParcelStatus(parcel, status) {
  openStatusMenuId.value = null

  if (status === parcel.status) {
    return
  }

  await updateParcelStatus(parcel, status)
}

function clearFilter() {
  Object.keys(filterStatus.value).forEach(key => { filterStatus.value[key] = false })
  Object.keys(filterPlatform.value).forEach(key => { filterPlatform.value[key] = false })
}

function handleDocumentClick(event) {
  if (showFilterPopup.value && filterAnchor.value && !filterAnchor.value.contains(event.target)) {
    closeFilter()
  }

  if (openStatusMenuId.value) {
    openStatusMenuId.value = null
  }
}

function setActionMessage(message, type = 'success') {
  actionMessage.value = message
  actionMessageType.value = type
}

async function submitScan() {
  const trackingNumber = scanTracking.value.trim()

  if (!trackingNumber) {
    scanFeedbackType.value = 'error'
    scanFeedback.value = 'Please scan or enter a tracking number.'
    return
  }

  scanFeedback.value = ''
  scanningParcel.value = true

  try {
    const parcel = await apiRequest('/parcels/scan', {
      method: 'POST',
      body: { trackingNumber },
    })

    scanFeedbackType.value = 'success'
    scanFeedback.value = `${parcel.trackingNumber} moved to ${parcel.status}.`
    scanTracking.value = ''
    await loadParcels(1)
    selectedParcelIds.value = [parcel.id]
    scanInput.value?.focus()
  } catch (error) {
    scanFeedbackType.value = 'error'
    scanFeedback.value = error.message
    scanInput.value?.focus()
  } finally {
    scanningParcel.value = false
  }
}

function openAddParcelModal() {
  addError.value = ''
  addForm.value = { tracking: '', manualInput: true, platform: '', status: '' }
  showAddParcelModal.value = true
}

function closeAddParcelModal() {
  showAddParcelModal.value = false
}

function openScannerWindow() {
  window.open('https://online-scanner.netlify.app/', '_blank')
}

async function submitAddParcel() {
  addError.value = ''
  savingAddParcel.value = true

  try {
    await apiRequest('/parcels', {
      method: 'POST',
      body: {
        trackingNumber: addForm.value.tracking,
        platform: addForm.value.platform,
        status: addForm.value.status,
      },
    })
    closeAddParcelModal()
    await loadParcels(1)
    await new Promise(resolve => setTimeout(resolve, 300))
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'OrderRecords' })
    emitDataEvent(DATA_EVENTS.parcelsRefresh)
  } catch (error) {
    addError.value = error.message
  } finally {
    savingAddParcel.value = false
  }
}

function openEdit(parcel = null) {
  const targets = parcel ? [parcel] : getSelectedTargets()
  if (!targets.length) return
  editError.value = ''

  if (targets.length === 1) {
    const [target] = targets
    editForm.value = {
      ids: [target.id],
      trackingNumber: target.trackingNumber,
      status: target.status,
      summary: target.trackingNumber,
    }
    selectedParcelIds.value = [target.id]
  } else {
    editForm.value = {
      ids: targets.map((target) => target.id),
      trackingNumber: `${targets.length} parcels selected`,
      status: '',
      summary: targets.map((target) => target.trackingNumber).join('\n'),
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

function getEditTargets() {
  return editForm.value.ids
    .map((id) => parcels.value.find((parcel) => parcel.id === id))
    .filter(Boolean)
}

function willParcelReceiveUpdate(parcel, nextStatus) {
  if (!nextStatus) {
    return false
  }

  if (parcel.status !== nextStatus) {
    return true
  }

  return nextStatus === 'Outbound' && !parcel.outboundDate
}

async function updateParcel() {
  editError.value = ''
  savingEditParcel.value = true

  try {
    const body = {}

    if (editForm.value.status) {
      body.status = editForm.value.status
    }

    if (Object.keys(body).length === 0) {
      throw new Error('Select at least one field to update.')
    }

    const editTargets = getEditTargets()
    const actionableTargets = editTargets.filter((parcel) => willParcelReceiveUpdate(parcel, editForm.value.status))

    if (!actionableTargets.length) {
      throw new Error(
        editForm.value.ids.length > 1
          ? 'All selected parcels already have that status.'
          : 'This parcel already has that status.',
      )
    }

    await Promise.all(
      actionableTargets.map((parcel) =>
        apiRequest(`/parcels/${parcel.id}`, {
          method: 'PATCH',
          body,
        })
      )
    )

    closeEdit()
    await loadParcels(meta.value.page)
    setActionMessage(
      `${actionableTargets.length} parcel${actionableTargets.length === 1 ? '' : 's'} updated successfully.`,
      'success',
    )
    // Wait for backend to sync before emitting events
    await new Promise(resolve => setTimeout(resolve, 300))
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'OrderRecords' })
    emitDataEvent(DATA_EVENTS.parcelsRefresh)
  } catch (error) {
    editError.value = error.message
  } finally {
    savingEditParcel.value = false
  }
}

async function updateParcelStatus(parcel, status) {
  savingInlineParcelId.value = parcel.id

  try {
    await apiRequest(`/parcels/${parcel.id}`, {
      method: 'PATCH',
      body: { status },
    })

    await loadParcels(meta.value.page)
    // Wait for backend to sync before emitting events
    await new Promise(resolve => setTimeout(resolve, 300))
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'OrderRecords' })
    emitDataEvent(DATA_EVENTS.parcelsRefresh)
  } catch (error) {
    setActionMessage(error.message, 'error')
  } finally {
    savingInlineParcelId.value = null
  }
}

function openReportModal() {
  if (!selectedParcel.value) return
  reportError.value = ''
  reportForm.value = { remarks: '' }
  showReportModal.value = true
}

function closeReportModal() {
  showReportModal.value = false
}

async function submitReport() {
  if (!selectedParcel.value) return
  reportError.value = ''
  savingReport.value = true

  try {
    await apiRequest('/reports', {
      method: 'POST',
      body: {
        trackingNumber: selectedParcel.value.trackingNumber,
        remarks: reportForm.value.remarks,
        status: 'Unresolved',
      },
    })
    closeReportModal()
    setActionMessage('Report submitted successfully.', 'success')
    await new Promise(resolve => setTimeout(resolve, 300))
    emitDataEvent(DATA_EVENTS.notificationsRefresh, { source: 'OrderRecords' })
    emitDataEvent(DATA_EVENTS.parcelsRefresh)
  } catch (error) {
    reportError.value = error.message
  } finally {
    savingReport.value = false
  }
}

async function downloadCSV() {
  isDownloading.value = true
  try {
    await downloadFile('/parcels/export.csv', {
      params: buildParcelParams(),
      filename: 'order-records.csv',
    })
    setActionMessage('CSV downloaded successfully.', 'success')
  } catch (error) {
    setActionMessage(error.message, 'error')
  } finally {
    isDownloading.value = false
  }
}

watch([search, dateRange, filterStatus, filterPlatform], () => {
  clearTimeout(filterTimer)
  filterTimer = setTimeout(() => loadParcels(1), 250)
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

watch(
  () => route.query.status,
  (nextStatus) => {
    if (typeof nextStatus !== 'string') {
      return
    }

    const normalizedStatus = nextStatus.trim().toLowerCase()
    const statusMap = {
      returned: 'Returned',
      pending: 'Pending',
      outbound: 'Outbound',
      cancelled: 'Cancelled',
      'double waybill': 'Double Waybill',
      missing: 'Missing',
      lost: 'Lost',
    }

    if (!statusMap[normalizedStatus]) {
      return
    }

    filterStatus.value = Object.fromEntries(
      Object.keys(filterStatus.value).map((key) => [key, key === statusMap[normalizedStatus]]),
    )
  },
  { immediate: true },
)

watch(
  () => [route.query.highlight, parcels.value],
  async ([nextHighlight]) => {
    if (typeof nextHighlight !== 'string' || !nextHighlight) {
      return
    }

    await revealParcelByTracking(nextHighlight)
  },
  { immediate: true, deep: true },
)

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
  cleanupNotifications = subscribeToDataEvent(DATA_EVENTS.notificationsRefresh, () => loadParcels(1))
  cleanupParcels = subscribeToDataEvent(DATA_EVENTS.parcelsRefresh, () => setTimeout(() => loadParcels(1), 200))
  loadParcels(1)
  scanInput.value?.focus()
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick)
  cleanupNotifications?.()
  cleanupParcels?.()
})
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 16px;
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
.controls-right,
.card-buttons {
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

.controls input,
.scan-input,
.form-group input,
.form-group select,
.remarks-box {
  width: 100%;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid var(--border-soft);
  background: #fbfcfe;
  color: var(--text-main);
  box-shadow: inset 0 1px 2px rgba(15, 23, 42, 0.02);
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

.btn.primary,
.page-btn.active {
  border-color: transparent;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.export-btn {
  min-width: 118px;
  background: #fff;
  color: var(--text-main);
  border: 1px solid var(--border-soft);
  box-shadow: none;
}


.btn:disabled,
.page-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
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

.filter {
  gap: 10px;
  min-width: 122px;
}

.controls-right {
  justify-content: flex-end;
  flex-wrap: wrap;
  align-items: flex-end;
}

.page-message,
.panel-message {
  margin: 14px 0 0;
  padding: 12px 16px;
  border-radius: 14px;
  font-size: 13px;
}

.error {
  color: #b64712;
  background: var(--bg-danger-soft);
}

.success {
  color: #0f7f57;
  background: var(--bg-success-soft);
}

.scan-panel {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 14px;
  margin: 22px 0 8px;
  flex-wrap: wrap;
}

.scan-panel-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 280px;
  flex: 1;
}

.scan-label {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-muted);
}

.table-state {
  text-align: center;
  color: var(--text-faint);
}

table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  font-size: 14px;
  margin-top: 18px;
}

th,
td {
  padding: 14px 20px;
  border-bottom: 1px solid rgba(112, 128, 154, 0.16);
  color: var(--text-main);
}

th:nth-child(2),
td:nth-child(2) { width: 24%; }
th:nth-child(3),
td:nth-child(3) { width: 16%; }
th:nth-child(4),
td:nth-child(4) { width: 18%; }
th:nth-child(5),
td:nth-child(5) { width: 18%; }
th:nth-child(6),
td:nth-child(6) { width: 18%; }

th {
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

table td {
  text-align: center;
  vertical-align: middle;
}

td:first-child,
th:first-child {
  width: 54px;
  padding-left: 10px;
  text-align: center;
}

tr.selected td {
  background: rgba(255, 111, 0, 0.08);
}

tr.highlight td {
  background: rgba(255, 196, 92, 0.28);
  box-shadow: inset 0 0 0 1px rgba(224, 138, 0, 0.22);
}

.select-cell {
  width: 54px;
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

.status {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 118px;
  padding: 7px 14px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.status.pending { background: var(--bg-warning-soft); color: #9d6500; }
.status.returned { background: #edf3ff; color: #3c63b7; }
.status.outbound { background: #f5ecff; color: #7d42bd; }
.status.cancelled { background: #fff0ed; color: #bf4b17; }
.status.double-waybill { background: #edfbf2; color: #138559; }
.status.missing { background: #fff0ed; color: #bf4b17; }
.status.lost { background: #ffe7e5; color: #b42318; }

.status-dropdown-wrap {
  position: relative;
  display: flex;
  justify-content: center;
}

.status-dropdown {
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  min-width: 148px;
  min-height: 40px;
  padding: 0 13px 0 16px;
  border-radius: 999px;
  border: 1px solid transparent;
  font-size: 0.9rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 8px 18px rgba(15, 23, 42, 0.05);
}

.status-dropdown-chevron {
  display: inline-flex;
  width: 12px;
  height: 12px;
  flex: 0 0 auto;
}

.status-dropdown-chevron svg {
  width: 100%;
  height: 100%;
}

.status-dropdown.open .status-dropdown-chevron {
  transform: rotate(180deg);
}

.status-dropdown.order.pending {
  background-color: var(--bg-warning-soft);
  border-color: rgba(157, 101, 0, 0.12);
  color: #9d6500;
}

.status-dropdown.order.returned {
  background-color: #edf3ff;
  border-color: rgba(60, 99, 183, 0.12);
  color: #3c63b7;
}

.status-dropdown.order.outbound {
  background-color: #f5ecff;
  border-color: rgba(125, 66, 189, 0.12);
  color: #7d42bd;
}

.status-dropdown.order.cancelled {
  background-color: #fff0ed;
  border-color: rgba(191, 75, 23, 0.12);
  color: #bf4b17;
}

.status-dropdown.order.double-waybill {
  background-color: #edfbf2;
  border-color: rgba(19, 133, 89, 0.12);
  color: #138559;
}

.status-dropdown.order.missing {
  background-color: #fff0ed;
  border-color: rgba(191, 75, 23, 0.12);
  color: #bf4b17;
}

.status-dropdown.order.lost {
  background-color: #ffe7e5;
  border-color: rgba(180, 35, 24, 0.12);
  color: #b42318;
}

.status-menu {
  position: absolute;
  top: calc(100% + 8px);
  left: 50%;
  z-index: 35;
  width: 196px;
  padding: 8px;
  border: 1px solid rgba(255, 133, 51, 0.18);
  border-radius: 18px;
  background:
    radial-gradient(circle at top left, rgba(255, 161, 78, 0.1), transparent 38%),
    linear-gradient(180deg, #fffdfb 0%, #fff8ef 100%);
  box-shadow: 0 22px 44px rgba(15, 23, 42, 0.16);
  transform: translateX(-50%);
}

.status-menu-option {
  display: flex;
  align-items: center;
  width: 100%;
  min-height: 36px;
  padding: 0 12px;
  border: 0;
  border-radius: 12px;
  background: transparent;
  color: #9d6500;
  font-size: 14px;
  font-weight: 700;
  text-align: left;
}

.status-menu-option:hover,
.status-menu-option.selected {
  background: rgba(255, 111, 0, 0.12);
  color: #c75a10;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.35);
  z-index: 1000;
  padding: 16px;
}

.modal,
.filter-popup {
  background: #ffffff;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  color: var(--text-main);
  box-shadow: var(--shadow-soft);
}

.modal {
  position: relative;
  width: min(420px, calc(100vw - 32px));
  max-height: calc(100vh - 48px);
  overflow-y: auto;
  padding: 28px;
}

.modal h3 {
  margin: 0 0 18px;
  text-align: center;
  font-size: 1.5rem;
}

.modal-close {
  position: absolute;
  top: 10px;
  right: 12px;
  border: none;
  background: transparent;
  font-size: 22px;
  color: var(--text-muted);
}

.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 14px;
}

.form-group label {
  font-size: 13px;
  font-weight: 700;
  margin-bottom: 6px;
  color: var(--text-muted);
}

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.checkbox-row label {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  white-space: nowrap;
}

.checkbox-row input[type="checkbox"] {
  margin: 0;
  vertical-align: middle;
}

.remarks-box {
  min-height: 110px;
  resize: vertical;
}

.bulk-edit-hint {
  margin: 4px 0 0;
  color: var(--text-muted);
  font-size: 13px;
  line-height: 1.5;
}

.bulk-summary {
  min-height: 96px;
  white-space: pre-wrap;
}

.tracking-input-row {
  display: flex;
  align-items: flex-end;
  gap: 10px;
}

.tracking-input-wrap {
  display: flex;
  flex-direction: column;
  flex: 1;
  gap: 6px;
}

.tracking-input-wrap label {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-muted);
}

.tracking-input-wrap input {
  padding: 10px 14px;
  border: 1px solid var(--border-soft);
  border-radius: 8px;
  font-size: 14px;
  background: #fff;
  color: var(--text-main);
}

.tracking-input-wrap input:disabled {
  background: #f5f7fa;
  color: var(--text-muted);
  cursor: not-allowed;
  opacity: 0.68;
}

.lock-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  min-width: 44px;
  padding: 0;
  border-radius: 8px;
  border: 1.5px solid var(--border-soft);
  background: #fff;
  cursor: pointer;
  transition: all 0.2s ease;
  flex: 0 0 auto;
}

.lock-btn:hover {
  border-color: #d85d14;
  background: rgba(255, 111, 0, 0.06);
}

.lock-btn.unlocked {
  border-color: #2f62d9;
  background: #eef4ff;
  color: #2f62d9;
}

.lock-btn.locked {
  border-color: #9d6500;
  background: #fff1da;
  color: #dd7a00;
}

.lock-icon {
  width: 20px;
  height: 20px;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 22px;
  flex-wrap: wrap;
}

.btn.secondary {
  border: 1px solid var(--border-soft);
  background: #fff;
  color: var(--text-main);
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn.secondary:hover {
  background: #f5f7fa;
  border-color: #d85d14;
}

.action-icon {
  width: 18px;
  height: 18px;
}

.filter-anchor {
  position: relative;
}

.filter-popup {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  z-index: 40;
  width: min(388px, calc(100vw - 32px));
  padding: 24px;
  background:
    radial-gradient(circle at top left, rgba(255, 161, 78, 0.08), transparent 34%),
    linear-gradient(180deg, #fffdfb 0%, #ffffff 100%);
  border: 1px solid rgba(255, 133, 51, 0.16);
  border-radius: 24px;
  box-shadow: 0 26px 56px rgba(15, 23, 42, 0.16);
}

.filter-popup h4 {
  margin: 0 0 16px;
  font-size: 13px;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.filter-group {
  display: grid;
  grid-template-columns: 1fr 1fr;
  column-gap: 18px;
  row-gap: 10px;
  margin-bottom: 18px;
  font-size: 15px;
}

.filter-option {
  display: grid;
  grid-template-columns: 18px minmax(0, 1fr);
  align-items: center;
  gap: 10px;
  min-height: 44px;
  margin: 0;
  color: var(--text-main);
  line-height: 1.35;
}

.filter-option input {
  width: 16px;
  height: 16px;
  margin: 0;
  accent-color: #ff6f00;
  justify-self: center;
}

.filter-option span {
  min-width: 0;
  overflow-wrap: anywhere;
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

.card-buttons {
  justify-content: flex-end;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
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

.table-footer {
  display: flex;
  justify-content: center;
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
  .controls,
  .scan-panel,
  .card-buttons {
    flex-direction: column;
    align-items: stretch;
  }

  .header-actions,
  .controls-right,
  .card-buttons {
    width: 100%;
  }

  .controls-left,
  .controls-left > input,
  .date-filter,
  .date-filter-row,
  .date-trigger,
  .btn,
  .page-btn {
    width: 100%;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .date-filter-row {
    flex-direction: column;
    align-items: stretch;
  }

  .controls-right {
    justify-content: stretch;
  }
}
</style>
