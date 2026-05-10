<template>
  <div class="page">
    <section class="card intro-card">
      <p class="page-eyebrow">Team Administration</p>
      <div class="page-header">
        <div class="page-header-copy">
          <h1 class="page-title">User Management</h1>
          <p class="page-subtitle">Manage team members and permissions</p>
        </div>
        <button class="header-add-btn" @click="openAddModal">Add User</button>
      </div>

      <p v-if="pageError" class="page-message error">{{ pageError }}</p>

      <div class="toolbar-card">
        <div class="toolbar-search">
          <input
            class="toolbar-input"
            type="text"
            v-model="search"
            placeholder="Search users..."
          />
        </div>

        <FancySelect
          v-model="roleFilter"
          class="toolbar-select"
          :options="roleFilterOptions"
          :full-width="false"
          align="right"
          variant="toolbar"
        />
      </div>

      <div class="summary-grid">
        <div class="card profile-card">
          <div class="profile-circle">
            <span class="profile-icon">{{ profileInitials }}</span>
          </div>
          <div class="profile-text">
            <h2>Hi, {{ summary.currentUser?.fullName ?? 'Admin' }}!</h2>
            <p class="role">{{ summary.currentUser?.role ?? 'staff' }}</p>
            <p class="started">Started on {{ formatDate(summary.currentUser?.createdAt) }}</p>
            <p class="user-id">User ID: {{ summary.currentUser?.userId ?? '-' }}</p>
          </div>
        </div>

        <div class="card stat-card">
          <p class="stat-label">Total Users</p>
          <p class="stat-value">{{ summary.totalUsers }}</p>
        </div>

        <div class="card stat-card">
          <p class="stat-label">Active Users</p>
          <p class="stat-value">{{ summary.activeUsers }}</p>
        </div>

        <div class="card stat-card">
          <p class="stat-label">On Leave</p>
          <p class="stat-value">{{ summary.onLeaveUsers }}</p>
        </div>
      </div>
    </section>

    <div class="grid">
      <div class="card security-card">
        <h3>Security Code</h3>
        <p class="security-note">
          The current code is stored hashed in Supabase, so it cannot be revealed. You can replace it here.
        </p>

        <div class="security-input-row">
          <input
            class="security-input"
            :type="showSecurityCode ? 'text' : 'password'"
            v-model="newSecurityCode"
            placeholder="Enter new security code"
          />
        </div>

        <div class="show-code">
          <input type="checkbox" id="show-security-code" v-model="showSecurityCode" />
          <label for="show-security-code">Show new security code</label>
        </div>

        <button class="security-btn" @click="updateSecurityCode" :disabled="securitySaving || !newSecurityCode.trim()">
          {{ securitySaving ? 'Updating...' : 'Update Security Code' }}
        </button>

        <p v-if="securityMessage" class="panel-message success">{{ securityMessage }}</p>
        <p v-if="securityError" class="panel-message error">{{ securityError }}</p>
        <p class="security-meta">
          Configured: {{ summary.registrationSecurityCodeConfigured ? 'Yes' : 'No' }}
        </p>
        <p class="security-meta">
          Last updated: {{ formatDate(summary.registrationSecurityCodeUpdatedAt, true) }}
        </p>
      </div>

      <div class="card users-card">
        <div class="users-header">
          <div>
            <h3>Users</h3>
            <p class="users-subtitle">Manage account roles, statuses, and inactivity reasons.</p>
          </div>

          <div class="users-actions">
            <button class="edit-btn" :disabled="selectedCount === 0 || usersLoading" @click="openEditModal()">
              EDIT
            </button>
          </div>
        </div>

        <table class="users-table">
          <thead>
            <tr>
              <th></th>
              <th>Employee Name</th>
              <th>Role</th>
              <th>Status</th>
              <th>Last Active</th>
              <th>Reason</th>
            </tr>
          </thead>

          <tbody>
            <tr v-if="usersLoading">
              <td colspan="6" class="table-state">Loading users...</td>
            </tr>

            <tr v-else-if="users.length === 0">
              <td colspan="6" class="table-state">No users found.</td>
            </tr>

            <tr
              v-for="user in users"
              :key="user.id"
              :class="{ selected: selectedUserIds.includes(user.id) }"
              @click="toggleSelection(user)"
            >
              <td>
                <button
                  type="button"
                  class="row-check"
                  :class="{ checked: selectedUserIds.includes(user.id) }"
                  :aria-pressed="selectedUserIds.includes(user.id)"
                  :aria-label="selectedUserIds.includes(user.id) ? `Deselect ${user.fullName}` : `Select ${user.fullName}`"
                  @click.stop="toggleSelection(user)"
                >
                  <svg viewBox="0 0 20 20" aria-hidden="true">
                    <path d="M5 10.5 8.2 13.5 15 6.8" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                </button>
              </td>
              <td>
                <div class="name-cell">{{ user.fullName }}</div>
                <div class="sub-cell">{{ user.userId }}</div>
              </td>
              <td>
                <div class="cell-actions">
                  <span class="role-pill">{{ user.role }}</span>
                  <button
                    type="button"
                    class="icon-action"
                    :aria-label="`Edit ${user.fullName}`"
                    @click.stop="openEditModal(user)"
                  >
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                      <path d="M4 20h4.5L19 9.5 14.5 5 4 15.5V20Z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" />
                      <path d="M12.5 7 17 11.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" />
                    </svg>
                  </button>
                </div>
              </td>
              <td>
                <span :class="['status-pill', user.status]">{{ user.status }}</span>
              </td>
              <td>{{ formatRelativeTime(user.lastLoginAt) }}</td>
              <td>{{ user.reason || '-' }}</td>
            </tr>
          </tbody>
        </table>

        <div class="table-footer">
          <span>Showing {{ users.length }} of {{ meta.total }} users</span>
          <div class="pagination" v-if="meta.totalPages > 1">
            <button class="page-btn" :disabled="meta.page === 1 || usersLoading" @click="changePage(meta.page - 1)">
              Prev
            </button>
            <span class="page-count">Page {{ meta.page }} / {{ meta.totalPages }}</span>
            <button class="page-btn" :disabled="meta.page === meta.totalPages || usersLoading" @click="changePage(meta.page + 1)">
              Next
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showEditModal && editForm" class="modal-backdrop" @click.self="closeEditModal">
      <div class="modal">
        <button class="modal-close" @click="closeEditModal">x</button>
        <h3>{{ editForm.ids.length > 1 ? 'Bulk Edit Users' : 'Edit User' }}</h3>
        <p class="modal-subtitle">
          {{ editForm.ids.length > 1 ? `${editForm.ids.length} users selected` : `${editForm.fullName} (${editForm.userId})` }}
        </p>

        <div v-if="editForm.ids.length > 1" class="bulk-users-box">
          {{ editForm.summary }}
        </div>

        <label class="field-label">Role</label>
        <FancySelect
          v-model="editForm.role"
          :options="userRoleOptions"
          :placeholder="editForm.ids.length > 1 ? 'Keep current role' : 'Select role'"
          variant="field"
        />

        <label class="field-label">Status</label>
        <FancySelect
          v-model="editForm.status"
          :options="userStatusOptions"
          :placeholder="editForm.ids.length > 1 ? 'Keep current status' : 'Select status'"
          variant="field"
        />

        <label class="field-label">Reason</label>
        <textarea
          v-model="editForm.reason"
          class="field-input textarea"
          placeholder="Reason for status change"
        ></textarea>

        <p v-if="editError" class="panel-message error">{{ editError }}</p>

        <div class="modal-actions">
          <button class="secondary-btn" @click="closeEditModal">Cancel</button>
          <button class="primary-btn" @click="saveUserChanges" :disabled="editSaving">
            {{ editSaving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="showAddModal" class="modal-backdrop" @click.self="closeAddModal">
      <div class="modal">
        <button class="modal-close" @click="closeAddModal">x</button>
        <h3>Add User</h3>
        <p class="modal-subtitle">Create a new team member account.</p>

        <label class="field-label">First Name</label>
        <input v-model="addForm.firstName" class="field-input" type="text" placeholder="Enter first name" />

        <label class="field-label">Last Name</label>
        <input v-model="addForm.lastName" class="field-input" type="text" placeholder="Enter last name" />

        <label class="field-label">Role</label>
        <FancySelect
          v-model="addForm.role"
          :options="userRoleOptions"
          variant="field"
        />

        <label class="field-label">Status</label>
        <FancySelect
          v-model="addForm.status"
          :options="userStatusOptions"
          variant="field"
        />

        <label class="field-label">Reason</label>
        <textarea
          v-model="addForm.reason"
          class="field-input textarea"
          placeholder="Required if creating an inactive user"
        ></textarea>

        <label class="field-label">Password</label>
        <input v-model="addForm.password" class="field-input" type="password" placeholder="Enter password" />

        <label class="field-label">Confirm Password</label>
        <input v-model="addForm.confirmPassword" class="field-input" type="password" placeholder="Confirm password" />

        <p v-if="addError" class="panel-message error">{{ addError }}</p>

        <div class="modal-actions">
          <button class="secondary-btn" @click="closeAddModal">Cancel</button>
          <button class="primary-btn" @click="submitAddUser" :disabled="addSaving">
            {{ addSaving ? 'Creating...' : 'Add User' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import FancySelect from '../components/FancySelect.vue'
import { apiJsonRequest, apiRequest, syncCurrentUser } from '../lib/api'

const users = ref([])
const usersLoading = ref(false)
const pageError = ref('')
const search = ref('')
const roleFilter = ref('')
const selectedUserIds = ref([])
const showEditModal = ref(false)
const showAddModal = ref(false)
const editForm = ref(null)
const editError = ref('')
const editSaving = ref(false)
const addSaving = ref(false)
const addError = ref('')
const newSecurityCode = ref('')
const showSecurityCode = ref(false)
const securitySaving = ref(false)
const securityMessage = ref('')
const securityError = ref('')

const summary = ref({
  currentUser: null,
  totalUsers: 0,
  activeUsers: 0,
  inactiveUsers: 0,
  onLeaveUsers: 0,
  registrationSecurityCodeConfigured: false,
  registrationSecurityCodeUpdatedAt: null,
})

const roleFilterOptions = [
  { value: '', label: 'All Roles' },
  { value: 'admin', label: 'Admin' },
  { value: 'staff', label: 'Staff' },
]

const userRoleOptions = [
  { value: 'staff', label: 'Staff' },
  { value: 'admin', label: 'Admin' },
]

const userStatusOptions = [
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
]

const addForm = ref({
  firstName: '',
  lastName: '',
  role: 'staff',
  status: 'active',
  reason: '',
  password: '',
  confirmPassword: '',
})

const meta = ref({
  page: 1,
  pageSize: 8,
  total: 0,
  totalPages: 1,
})

const selectedUsers = computed(() => users.value.filter((user) => selectedUserIds.value.includes(user.id)))
const selectedUser = computed(() => selectedUsers.value[0] ?? null)
const selectedCount = computed(() => selectedUsers.value.length)

const profileInitials = computed(() => {
  const fullName = summary.value.currentUser?.fullName ?? ''
  const [first = '', second = ''] = fullName.split(' ')
  return `${first[0] ?? ''}${second[0] ?? ''}`.toUpperCase() || 'AD'
})

function formatDate(value, withTime = false) {
  if (!value) {
    return '-'
  }

  return new Date(value).toLocaleString(undefined, withTime
    ? {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
      }
    : {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      })
}

function formatRelativeTime(value) {
  if (!value) {
    return '-'
  }

  const timestamp = new Date(value)
  const diffMs = Date.now() - timestamp.getTime()

  if (Number.isNaN(timestamp.getTime())) {
    return '-'
  }

  if (diffMs < 0) {
    return 'Just now'
  }

  const minute = 60 * 1000
  const hour = 60 * minute
  const day = 24 * hour
  const week = 7 * day
  const month = 30 * day
  const year = 365 * day

  if (diffMs < minute) {
    return 'Just now'
  }

  if (diffMs < hour) {
    const minutes = Math.floor(diffMs / minute)
    return `${minutes} min${minutes === 1 ? '' : 's'} ago`
  }

  if (diffMs < day) {
    const hours = Math.floor(diffMs / hour)
    return `${hours} hour${hours === 1 ? '' : 's'} ago`
  }

  if (diffMs < week) {
    const days = Math.floor(diffMs / day)
    return `${days} day${days === 1 ? '' : 's'} ago`
  }

  if (diffMs < month) {
    const weeks = Math.floor(diffMs / week)
    return `${weeks} week${weeks === 1 ? '' : 's'} ago`
  }

  if (diffMs < year) {
    const months = Math.floor(diffMs / month)
    return `${months} month${months === 1 ? '' : 's'} ago`
  }

  const years = Math.floor(diffMs / year)
  return `${years} year${years === 1 ? '' : 's'} ago`
}

async function loadUsers(page = meta.value.page) {
  usersLoading.value = true
  pageError.value = ''

  try {
    const payload = await apiJsonRequest('/users', {
      params: {
        page,
        pageSize: meta.value.pageSize,
        search: search.value.trim() || undefined,
        role: roleFilter.value || undefined,
      },
    })

    users.value = payload.data ?? []
    meta.value = payload.meta ?? meta.value
    summary.value = payload.summary ?? summary.value
    summary.value.totalUsers = (payload.summary?.activeUsers ?? 0) + (payload.summary?.inactiveUsers ?? 0)
    summary.value.onLeaveUsers = (payload.data ?? []).filter((user) => /leave/i.test(user.reason ?? '')).length

    selectedUserIds.value = selectedUserIds.value.filter((id) => users.value.some((user) => user.id === id))
  } catch (error) {
    pageError.value = error.message
    users.value = []
    selectedUserIds.value = []
  } finally {
    usersLoading.value = false
  }
}

function toggleSelection(user) {
  selectedUserIds.value = selectedUserIds.value.includes(user.id)
    ? selectedUserIds.value.filter((id) => id !== user.id)
    : [...selectedUserIds.value, user.id]
}

function openEditModal(user = null) {
  const isDirectUserSelection = user && typeof user === 'object' && 'id' in user
  const targets = isDirectUserSelection ? [user] : selectedUsers.value

  if (!targets.length) {
    return
  }

  editError.value = ''

  if (targets.length === 1) {
    const [target] = targets
    editForm.value = {
      ids: [target.id],
      userId: target.userId,
      fullName: target.fullName,
      summary: target.fullName,
      role: target.role,
      status: target.status,
      reason: target.reason ?? '',
    }
    selectedUserIds.value = [target.id]
  } else {
    editForm.value = {
      ids: targets.map((target) => target.id),
      userId: '',
      fullName: '',
      summary: targets.map((target) => `${target.fullName} (${target.userId})`).join(', '),
      role: '',
      status: '',
      reason: '',
    }
  }

  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  editForm.value = null
  editError.value = ''
}

function openAddModal() {
  addError.value = ''
  addForm.value = {
    firstName: '',
    lastName: '',
    role: 'staff',
    status: 'active',
    reason: '',
    password: '',
    confirmPassword: '',
  }
  showAddModal.value = true
}

function closeAddModal() {
  showAddModal.value = false
  addError.value = ''
}

async function submitAddUser() {
  addSaving.value = true
  addError.value = ''

  try {
    await apiRequest('/users', {
      method: 'POST',
      body: {
        firstName: addForm.value.firstName,
        lastName: addForm.value.lastName,
        role: addForm.value.role,
        status: addForm.value.status,
        reason: addForm.value.reason.trim() || undefined,
        password: addForm.value.password,
        confirmPassword: addForm.value.confirmPassword,
      },
    })

    closeAddModal()
    await loadUsers(1)
  } catch (error) {
    addError.value = error.message
  } finally {
    addSaving.value = false
  }
}

async function saveUserChanges() {
  if (!editForm.value) {
    return
  }

  editSaving.value = true
  editError.value = ''

  try {
    const body = {}

    if (editForm.value.role) {
      body.role = editForm.value.role
    }

    if (editForm.value.status) {
      body.status = editForm.value.status
    }

    if (editForm.value.reason.trim() || editForm.value.ids.length === 1) {
      body.reason = editForm.value.reason.trim() || undefined
    }

    if (Object.keys(body).length === 0) {
      throw new Error('Select at least one field to update.')
    }

    const updatedUsers = await Promise.all(
      editForm.value.ids.map((id) =>
        apiRequest(`/users/${id}`, {
          method: 'PATCH',
          body,
        })
      )
    )

    updatedUsers.forEach((updatedUser) => {
      users.value = users.value.map((user) => (user.id === updatedUser.id ? updatedUser : user))
      syncCurrentUser(updatedUser)

      if (summary.value.currentUser?.id === updatedUser.id) {
        summary.value.currentUser = {
          ...summary.value.currentUser,
          ...updatedUser,
        }
      }
    })

    await loadUsers(meta.value.page)
    closeEditModal()
  } catch (error) {
    editError.value = error.message
  } finally {
    editSaving.value = false
  }
}

async function updateSecurityCode() {
  securitySaving.value = true
  securityMessage.value = ''
  securityError.value = ''

  try {
    const data = await apiRequest('/users/registration-code', {
      method: 'PUT',
      body: {
        securityCode: newSecurityCode.value,
      },
    })

    summary.value.registrationSecurityCodeConfigured = data.configured
    summary.value.registrationSecurityCodeUpdatedAt = data.updatedAt
    securityMessage.value = 'Security code updated successfully.'
    newSecurityCode.value = ''
    showSecurityCode.value = false
  } catch (error) {
    securityError.value = error.message
  } finally {
    securitySaving.value = false
  }
}

function changePage(page) {
  if (page < 1 || page > meta.value.totalPages) {
    return
  }

  loadUsers(page)
}

let searchTimer = null
watch(search, () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    loadUsers(1)
  }, 250)
})

watch(roleFilter, () => {
  loadUsers(1)
})

onMounted(() => {
  loadUsers(1)
})
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-title {
  font-size: 2.35rem;
  margin: 0;
  color: var(--text-main);
}

.page-subtitle {
  margin: 0;
  color: var(--text-muted);
  font-size: 0.98rem;
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

.page-message {
  margin: 0;
  padding: 12px 14px;
  border-radius: 14px;
  font-size: 14px;
}

.error {
  background: var(--bg-danger-soft);
  color: #b64712;
}

.success {
  background: var(--bg-success-soft);
  color: #0f7f57;
}

.grid {
  display: grid;
  grid-template-columns: 340px minmax(0, 1fr);
  gap: 24px;
}

.card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 26px;
  box-shadow: var(--shadow-card);
  color: var(--text-main);
  border: 1px solid var(--border-soft);
}

.intro-card {
  padding: 26px;
}

.summary-grid {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr 1fr;
  gap: 18px;
}

.toolbar-card {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 26px;
  padding: 20px;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  background: #fff;
}

.toolbar-search {
  flex: 1;
}

.toolbar-input {
  width: 100%;
  min-height: 56px;
  padding: 0 18px;
  border: 1px solid var(--border-soft);
  border-radius: 16px;
  background: #fff;
  color: var(--text-main);
  font-size: 15px;
}

.toolbar-select {
  width: min(220px, 100%);
}

.profile-card {
  display: flex;
  gap: 18px;
  align-items: center;
  min-height: 138px;
}

.profile-circle {
  width: 90px;
  height: 90px;
  border-radius: 50%;
  background: linear-gradient(135deg, #23262d 0%, #343845 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

.profile-icon {
  color: #fff;
  font-size: 30px;
  font-weight: 700;
}

.profile-text h2 {
  margin: 0;
  font-size: 20px;
}

.profile-text .role {
  margin: 4px 0;
  font-style: italic;
  color: var(--text-muted);
  text-transform: capitalize;
}

.profile-text .started,
.profile-text .user-id {
  margin: 6px 0 0;
  color: var(--text-muted);
  font-size: 14px;
}

.stat-card {
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 138px;
}

.stat-label {
  margin: 0;
  font-size: 1.02rem;
  color: var(--text-main);
}

.stat-value {
  font-size: 2.2rem;
  line-height: 1;
  margin: 18px 0 0;
}

.security-card {
  display: flex;
  flex-direction: column;
  min-height: 340px;
}

.security-card h3 {
  margin: 0 0 12px;
  font-size: 16px;
}

.security-note,
.security-meta,
.users-subtitle,
.modal-subtitle,
.sub-cell {
  color: var(--text-muted);
  font-size: 13px;
}

.security-input-row {
  margin: 14px 0 8px;
}

.security-input,
.search-input,
.field-input {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--border-soft);
  border-radius: 14px;
  background: #fbfcfe;
  color: var(--text-main);
}

.show-code {
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.security-btn,
.primary-btn,
.secondary-btn,
.edit-btn,
.header-add-btn,
.page-btn {
  min-height: 44px;
  border-radius: 14px;
  cursor: pointer;
  font-weight: 700;
}

.security-btn,
.primary-btn,
.header-add-btn {
  margin-top: 14px;
  padding: 0 16px;
  border: none;
  background: var(--bg-accent);
  color: #fff;
  box-shadow: 0 14px 24px rgba(255, 90, 0, 0.24);
}

.header-add-btn {
  margin-top: 0;
  min-width: 132px;
}

.security-btn:disabled,
.primary-btn:disabled,
.header-add-btn:disabled,
.edit-btn:disabled,
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.panel-message {
  margin-top: 12px;
  font-size: 13px;
}

.users-card {
  min-width: 0;
}

.users-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}

.users-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.edit-btn,
.secondary-btn,
.page-btn {
  padding: 0 16px;
  border: 1px solid var(--border-soft);
  background: #fff;
  color: var(--text-main);
}

.users-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 18px;
  border: 1px solid var(--border-soft);
  border-radius: 22px;
  overflow: hidden;
  background: #fff;
}

.users-table th,
.users-table td {
  border-bottom: 1px solid #e0e0e0;
  padding: 14px 12px;
  text-align: left;
  vertical-align: middle;
}

.users-table th {
  color: var(--text-muted);
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.users-table tr.selected {
  background: rgba(255, 111, 0, 0.08);
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

.name-cell {
  font-weight: 600;
}

.cell-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.role-pill,
.status-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 72px;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  text-transform: capitalize;
}

.role-pill {
  background: #f2f4f7;
  color: #344054;
}

.icon-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 10px;
  border: 1px solid rgba(112, 128, 154, 0.22);
  background: #fff;
  color: var(--text-muted);
  transition: transform 0.18s ease, box-shadow 0.18s ease, color 0.18s ease, border-color 0.18s ease;
}

.icon-action svg {
  width: 16px;
  height: 16px;
}

.icon-action:hover {
  transform: translateY(-1px);
  color: #d85d14;
  border-color: rgba(216, 93, 20, 0.28);
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.08);
}

.status-pill.active {
  background: var(--bg-success-soft);
  color: #0f7f57;
}

.status-pill.inactive {
  background: var(--bg-danger-soft);
  color: #b64712;
}

.table-state {
  text-align: center;
  color: var(--text-faint);
}

.table-footer {
  margin-top: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: var(--text-muted);
  font-size: 13px;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 8px;
}

.page-count {
  min-width: 84px;
  text-align: center;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal {
  width: 420px;
  background: #fff;
  border-radius: 22px;
  padding: 24px;
  position: relative;
  box-shadow: var(--shadow-soft);
  border: 1px solid var(--border-soft);
}

.modal-close {
  position: absolute;
  top: 12px;
  right: 14px;
  border: none;
  background: transparent;
  font-size: 22px;
  cursor: pointer;
  color: var(--text-muted);
}

.field-label {
  display: block;
  margin: 14px 0 8px;
  font-size: 13px;
  font-weight: 600;
}

.textarea {
  min-height: 96px;
  resize: vertical;
}

.modal-actions {
  margin-top: 18px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.bulk-users-box {
  margin-top: 4px;
  padding: 12px 14px;
  border: 1px solid var(--border-soft);
  border-radius: 14px;
  background: #fbfcfe;
  color: var(--text-muted);
  font-size: 13px;
  line-height: 1.5;
}

@media (max-width: 1100px) {
  .summary-grid,
  .grid {
    grid-template-columns: 1fr;
  }

  .toolbar-card,
  .users-header,
  .users-actions,
  .table-footer {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-select,
  .header-add-btn {
    max-width: none;
    width: 100%;
  }
}
</style>
