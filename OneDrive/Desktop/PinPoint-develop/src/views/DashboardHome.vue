<template>
  <div class="page dashboard-home">
    <section class="hero-card">
      <div class="topbar">
        <div>
          <p class="eyebrow">Operations overview</p>
          <h1>Monthly Report</h1>
        </div>
        <div class="topbar-right">
          <span class="date-chip">{{ summary.monthLabel }}</span>
          <button class="icon-btn" @click="goToPreviousMonth"><</button>
          <button class="icon-btn" @click="goToNextMonth">></button>
        </div>
      </div>

      <p v-if="errorMessage" class="page-message error">{{ errorMessage }}</p>

      <div class="stats">
        <button
          v-for="item in stats"
          :key="item.label"
          :class="['stat-card', 'stat-action', `stat-${item.statusClass}`]"
          type="button"
          @click="goToStat(item)"
        >
          <span class="stat-icon" aria-hidden="true">
            <svg v-if="item.icon === 'return'" viewBox="0 0 24 24">
              <path d="M9 7 4 12l5 5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
              <path d="M20 12H5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
            <svg v-else-if="item.icon === 'pending'" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M12 8v4l3 2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
            <svg v-else-if="item.icon === 'cancelled'" viewBox="0 0 24 24">
              <path d="m8 8 8 8M16 8l-8 8" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
            </svg>
            <svg v-else-if="item.icon === 'double'" viewBox="0 0 24 24">
              <rect x="4" y="6" width="10" height="10" rx="2" fill="none" stroke="currentColor" stroke-width="1.8" />
              <rect x="10" y="10" width="10" height="10" rx="2" fill="none" stroke="currentColor" stroke-width="1.8" />
            </svg>
            <svg v-else viewBox="0 0 24 24">
              <path d="M5 12h14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
              <path d="m13 6 6 6-6 6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </span>
          <p>{{ item.label }}</p>
          <h2>{{ item.value }}</h2>
          <span class="stat-hint">View records</span>
        </button>
      </div>
    </section>

    <section class="card">
      <h3>Unresolved Reports</h3>
      <div v-if="loading" class="empty-state">Loading reports...</div>
      <template v-else-if="summary.unresolvedReports.length">
        <div v-for="report in summary.unresolvedReports" :key="report.id" class="list-row">
          <span class="error">x</span>
          <span>{{ report.trackingNumber }} - {{ truncate(report.remarks, 42) }}</span>
          <span class="date-right">{{ formatDate(report.reportedAt) }}</span>
        </div>
      </template>
      <div v-else class="empty-state">No unresolved reports this month.</div>
      <button class="link" @click="router.push('/dashboard/reports-issues')">Go to Report/Issue Tab</button>
    </section>

    <div class="bottom">
      <section class="card">
        <h3>History Records</h3>
        <div v-if="loading" class="empty-state">Loading activity...</div>
        <template v-else-if="summary.recentHistory.length">
          <div v-for="entry in summary.recentHistory" :key="entry.id" class="history-row" :class="historyClass(entry.action)">
            {{ entry.trackingNumber ? `${entry.trackingNumber} - ` : '' }}{{ entry.action }}
          </div>
        </template>
        <div v-else class="empty-state">No recent history yet.</div>
        <button class="link" @click="router.push('/dashboard/history-records')">View Full History Records Tab</button>
      </section>

      <section class="card chart">
        <h3>Parcel Status Chart</h3>
        <span v-if="chartData.length" class="chart-total-badge">{{ totalChartValue }} Parcels</span>
        <div v-if="chartData.length" class="chart-layout">
          <div
            class="donut-wrap"
            @mouseleave="hoveredChartLabel = ''"
          >
            <svg class="donut-chart" viewBox="0 0 160 160" aria-hidden="true">
              <circle class="donut-base" cx="80" cy="80" r="44" />
              <circle
                v-for="item in chartData"
                :key="item.label"
                class="donut-segment"
                :class="{ active: hoveredChartLabel === item.label }"
                cx="80"
                cy="80"
                r="44"
                :stroke="item.color"
                :stroke-dasharray="item.dashArray"
                :stroke-dashoffset="item.dashOffset"
                @mouseenter="hoveredChartLabel = item.label"
              />
            </svg>

            <div class="donut-center">
              <template v-if="hoveredChartItem">
                <strong>{{ hoveredChartItem.value }}</strong>
                <span>{{ hoveredChartItem.label }}</span>
              </template>
              <template v-else>
                <strong>{{ totalChartValue }}</strong>
                <span>Total</span>
              </template>
            </div>
          </div>

          <div class="chart-legend">
            <div
              v-for="item in chartData"
              :key="item.label"
              class="legend-row"
              :class="{ active: hoveredChartLabel === item.label }"
              @mouseenter="hoveredChartLabel = item.label"
              @mouseleave="hoveredChartLabel = ''"
            >
              <div class="legend-label-group">
                <span class="legend-dot" :style="{ backgroundColor: item.color }"></span>
                <span class="legend-label">{{ item.label }}</span>
              </div>
              <div class="legend-meta">
                <span class="legend-percent">{{ item.percentText }}</span>
                <span v-if="hoveredChartLabel === item.label" class="legend-count">{{ item.value }}</span>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="chart-placeholder">No data yet</div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { apiRequest } from '../lib/api'

const router = useRouter()
const loading = ref(false)
const errorMessage = ref('')
const currentMonth = ref(new Date().toISOString().slice(0, 7))
const hoveredChartLabel = ref('')
const summary = ref({
  month: currentMonth.value,
  monthLabel: '-',
  totals: { Returned: 0, Pending: 0, Cancelled: 0, 'Double Waybill': 0, Outbound: 0, Missing: 0, Lost: 0 },
  chart: [],
  unresolvedReports: [],
  recentHistory: [],
})

const stats = computed(() => [
  { label: 'Returned', value: summary.value.totals.Returned ?? 0, status: 'returned', statusClass: 'returned', icon: 'return' },
  { label: 'Pending', value: summary.value.totals.Pending ?? 0, status: 'pending', statusClass: 'pending', icon: 'pending' },
  { label: 'Cancelled', value: summary.value.totals.Cancelled ?? 0, status: 'cancelled', statusClass: 'cancelled', icon: 'cancelled' },
  { label: 'Double Waybill', value: summary.value.totals['Double Waybill'] ?? 0, status: 'double waybill', statusClass: 'double', icon: 'double' },
  { label: 'Outbound', value: summary.value.totals.Outbound ?? 0, status: 'outbound', statusClass: 'outbound', icon: 'outbound' },
  { label: 'Missing', value: summary.value.totals.Missing ?? 0, status: 'missing', statusClass: 'missing', icon: 'pending' },
  { label: 'Lost', value: summary.value.totals.Lost ?? 0, status: 'lost', statusClass: 'lost', icon: 'cancelled' },
])

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
}

function truncate(value, maxLength) {
  if (!value) return '-'
  return value.length > maxLength ? `${value.slice(0, maxLength - 3)}...` : value
}

function historyClass(action) {
  if (/resolved|outbound|created|added/i.test(action)) return 'success'
  if (/cancelled|inactive|error/i.test(action)) return 'warning'
  return ''
}

const chartColors = {
  Returned: '#4f6da7',
  Pending: '#f2b544',
  Cancelled: '#f24848',
  Outbound: '#1fa84a',
  'Double Waybill': '#9b6bff',
  Missing: '#bf4b17',
  Lost: '#b42318',
}

const chartData = computed(() => {
  const rows = summary.value.chart ?? []
  const total = rows.reduce((sum, item) => sum + item.value, 0)
  const radius = 44
  const circumference = 2 * Math.PI * radius
  let offset = 0

  return rows.map((item) => {
    const ratio = total > 0 ? item.value / total : 0
    const dash = circumference * ratio
    const segment = {
      ...item,
      color: chartColors[item.label] ?? '#c75a10',
      percent: ratio * 100,
      percentText: `${(ratio * 100).toFixed(2)}%`,
      dashArray: `${dash} ${circumference - dash}`,
      dashOffset: -offset,
    }
    offset += dash
    return segment
  })
})

const totalChartValue = computed(() => chartData.value.reduce((sum, item) => sum + item.value, 0))
const hoveredChartItem = computed(() => chartData.value.find((item) => item.label === hoveredChartLabel.value) ?? null)

async function loadSummary() {
  loading.value = true
  errorMessage.value = ''

  try {
    const data = await apiRequest('/dashboard/summary', { params: { month: currentMonth.value } })
    summary.value = data
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

function shiftMonth(offset) {
  const [year, month] = currentMonth.value.split('-').map(Number)
  const nextDate = new Date(Date.UTC(year, month - 1 + offset, 1))
  currentMonth.value = nextDate.toISOString().slice(0, 7)
  loadSummary()
}

function goToPreviousMonth() { shiftMonth(-1) }
function goToNextMonth() { shiftMonth(1) }
function goToStat(item) {
  router.push({
    name: 'OrderRecords',
    query: {
      status: item.status,
    },
  })
}

onMounted(() => {
  loadSummary()
})
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.dashboard-home {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.hero-card,
.stat-card,
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  color: var(--text-main);
}

.hero-card {
  padding: 26px;
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 18px;
}

.eyebrow {
  margin: 0 0 6px;
  color: #c75a10;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: clamp(2.3rem, 4vw, 3.2rem);
  line-height: 1;
  color: var(--text-main);
}

.topbar-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.date-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 42px;
  padding: 0 16px;
  border-radius: 999px;
  border: 1px solid var(--border-soft);
  background: rgba(255, 255, 255, 0.86);
  color: var(--text-muted);
  font-weight: 700;
  box-shadow: var(--shadow-card);
}

.icon-btn {
  width: 42px;
  height: 42px;
  border: 1px solid var(--border-soft);
  background: var(--bg-surface-strong);
  color: var(--text-main);
  border-radius: 12px;
  font-weight: 700;
  box-shadow: var(--shadow-card);
}

.page-message {
  margin: 0;
  padding: 12px 16px;
  border-radius: 14px;
  font-size: 13px;
  border: 1px solid rgba(198, 77, 22, 0.12);
  background: var(--bg-danger-soft);
}

.page-message.error {
  color: #b64712;
}

.stats {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 16px;
  margin-top: 20px;
}

.stat-card,
.card {
  padding: 22px;
  backdrop-filter: blur(10px);
}

.stat-card p {
  margin: 0;
  font-size: 0.92rem;
  color: var(--text-muted);
}

.stat-card h2 {
  margin: 14px 0 0;
  font-size: 2.15rem;
  line-height: 1;
}

.stat-action {
  position: relative;
  text-align: left;
  cursor: pointer;
  transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
}

.stat-action:hover {
  transform: translateY(-2px);
  border-color: rgba(255, 122, 26, 0.18);
  box-shadow: 0 16px 28px rgba(15, 23, 42, 0.1);
}

.stat-hint {
  display: inline-flex;
  margin-top: 12px;
  font-size: 12px;
  font-weight: 700;
  color: #c75a10;
}

.stat-icon {
  position: absolute;
  top: 18px;
  right: 18px;
  width: 28px;
  height: 28px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.stat-icon svg {
  width: 14px;
  height: 14px;
}

.stat-returned .stat-icon {
  background: #dfe7ff;
  color: #6a86f6;
}

.stat-pending .stat-icon {
  background: #ffe2b8;
  color: #dd8a00;
}

.stat-cancelled .stat-icon {
  background: #ffcfd1;
  color: #e06267;
}

.stat-double .stat-icon {
  background: #d8f5d7;
  color: #34ae54;
}

.stat-outbound .stat-icon {
  background: #efd3ff;
  color: #b96cff;
}

.stat-missing .stat-icon {
  background: #fff0ed;
  color: #bf4b17;
}

.stat-lost .stat-icon {
  background: #ffe7e5;
  color: #b42318;
}

.card h3 {
  margin: 0 0 18px;
  font-size: 1.45rem;
}

.list-row,
.history-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 13px 0;
  border-bottom: 1px solid rgba(112, 128, 154, 0.14);
}

.date-right {
  margin-left: auto;
  color: var(--text-faint);
  font-size: 13px;
}

.error {
  color: #d14e0f;
  font-weight: 700;
}

.success {
  color: #11885d;
}

.warning {
  color: #c96200;
}

.link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
  color: #c75710;
  cursor: pointer;
  font-size: 14px;
  font-weight: 700;
  background: none;
  border: none;
  padding: 0;
}

.bottom {
  display: grid;
  grid-template-columns: minmax(0, 1.8fr) minmax(280px, 1fr);
  gap: 18px;
}

.empty-state,
.chart-placeholder {
  color: var(--text-faint);
  padding: 12px 0;
}

.chart-total-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 34px;
  padding: 0 12px;
  margin-bottom: 16px;
  border-radius: 12px;
  background: #eef1f5;
  color: var(--text-muted);
  font-size: 13px;
}

.chart-layout {
  display: grid;
  grid-template-columns: 210px 1fr;
  gap: 22px;
  align-items: center;
}

.donut-wrap {
  position: relative;
  width: 180px;
  height: 180px;
  margin: 0 auto;
}

.donut-chart {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.donut-base,
.donut-segment {
  fill: none;
  stroke-linecap: butt;
  stroke-width: 20;
}

.donut-base {
  stroke: #edf1f6;
}

.donut-segment {
  transition: opacity 0.18s ease, stroke-width 0.18s ease, filter 0.18s ease;
  cursor: pointer;
}

.donut-segment.active {
  stroke-width: 24;
  filter: brightness(1.03);
}

.donut-center {
  position: absolute;
  inset: 50% auto auto 50%;
  transform: translate(-50%, -50%);
  width: 92px;
  height: 92px;
  border-radius: 50%;
  background: #ffffff;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  box-shadow: inset 0 0 0 1px rgba(112, 128, 154, 0.1);
}

.donut-center strong {
  font-size: 1.35rem;
  line-height: 1;
}

.donut-center span {
  margin-top: 6px;
  font-size: 11px;
  color: var(--text-muted);
}

.chart-legend {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.legend-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 6px 0;
  border-radius: 12px;
  transition: background-color 0.18s ease;
}

.legend-row.active {
  background: rgba(255, 122, 26, 0.06);
}

.legend-label-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.legend-dot {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  flex: 0 0 auto;
}

.legend-label {
  font-size: 13px;
}

.legend-meta {
  display: flex;
  align-items: center;
  gap: 10px;
}

.legend-percent {
  font-size: 13px;
  color: var(--text-muted);
}

.legend-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 24px;
  padding: 0 8px;
  border-radius: 999px;
  background: #1f2d46;
  color: #ffffff;
  font-size: 12px;
  font-weight: 700;
}

@media (max-width: 1180px) {
  .stats {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .bottom {
    grid-template-columns: 1fr;
  }

  .chart-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .topbar {
    flex-direction: column;
    align-items: flex-start;
  }

  .stats {
    grid-template-columns: 1fr;
  }
}
</style>
