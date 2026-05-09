<template>
  <div class="dashboard-layout">
    <aside :class="['sidebar', { 'is-collapsed': !sidebarVisible }]">
      <div class="sidebar-top"></div>

      <nav class="nav">
        <router-link to="/dashboard" class="nav-item" exact-active-class="active" exact @click="handleNavClick">
          <span class="nav-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <rect x="3" y="3" width="7" height="7" rx="1.5" fill="currentColor" />
              <rect x="14" y="3" width="7" height="7" rx="1.5" fill="currentColor" />
              <rect x="3" y="14" width="7" height="7" rx="1.5" fill="currentColor" />
              <rect x="14" y="14" width="7" height="7" rx="1.5" fill="currentColor" />
            </svg>
          </span>
          <span class="nav-label">Dashboard</span>
        </router-link>

        <router-link to="/dashboard/order-records" class="nav-item" active-class="active" @click="handleNavClick">
          <span class="nav-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 3 4 7.5v9L12 21l8-4.5v-9L12 3Z" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M4 7.5 12 12l8-4.5" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M12 12v9" fill="none" stroke="currentColor" stroke-width="1.8" />
            </svg>
          </span>
          <span class="nav-label">Order Records</span>
        </router-link>

        <router-link to="/dashboard/history-records" class="nav-item" active-class="active" @click="handleNavClick">
          <span class="nav-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M4 12a8 8 0 1 0 2.3-5.6" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M4 4v4h4" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M12 8v5l3 2" fill="none" stroke="currentColor" stroke-width="1.8" />
            </svg>
          </span>
          <span class="nav-label">History Records</span>
        </router-link>

        <router-link to="/dashboard/reports-issues" class="nav-item" active-class="active" @click="handleNavClick">
          <span class="nav-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M7 3h7l5 5v13H7z" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M14 3v5h5" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M10 13h6M10 17h6M10 9h2" fill="none" stroke="currentColor" stroke-width="1.8" />
            </svg>
          </span>
          <span class="nav-label">Reports / Issues</span>
        </router-link>

        <router-link to="/dashboard/user-management" class="nav-item" active-class="active" @click="handleNavClick">
          <span class="nav-icon">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z" fill="none" stroke="currentColor" stroke-width="1.8" />
              <path d="M5 20a7 7 0 0 1 14 0" fill="none" stroke="currentColor" stroke-width="1.8" />
            </svg>
          </span>
          <span class="nav-label">User Management</span>
        </router-link>
      </nav>

      <div class="sidebar-bottom">
        <button
          class="sidebar-collapse-btn"
          type="button"
          :aria-label="sidebarVisible ? 'Collapse sidebar' : 'Expand sidebar'"
          @click="toggleSidebar"
        >
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path
              :d="sidebarVisible ? 'M19 12H7' : 'M5 12h12'"
              fill="none"
              stroke="currentColor"
              stroke-width="1.8"
              stroke-linecap="round"
            />
            <path
              :d="sidebarVisible ? 'm12 7-5 5 5 5' : 'm12 7 5 5-5 5'"
              fill="none"
              stroke="currentColor"
              stroke-width="1.8"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>
      </div>
    </aside>

    <main :class="['main', { 'is-collapsed': !sidebarVisible }]">
      <TopNavbar />
      <div class="page-content">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import TopNavbar from '../components/TopNavbar.vue';

const sidebarVisible = ref(true);

function toggleSidebar() {
  sidebarVisible.value = !sidebarVisible.value;
}

function handleNavClick() {
  if (window.innerWidth <= 960) {
    sidebarVisible.value = false;
  }
}
</script>

<style scoped>
.dashboard-layout {
  min-height: 100vh;
  background: transparent;
}

.sidebar {
  position: fixed;
  inset: 0 auto 0 0;
  width: 92px;
  min-width: 92px;
  height: 100vh;
  background: #2e2e2e;
  color: var(--text-inverse);
  display: flex;
  flex-direction: column;
  box-shadow: inset -1px 0 0 rgba(255, 255, 255, 0.04);
  overflow: hidden;
  transition: width 0.22s ease;
  z-index: 1300;
}

.sidebar-top {
  height: 40px;
  background: #1f1f1f;
}

.nav {
  display: flex;
  flex-direction: column;
  padding: 0;
  flex: 1;
}

.nav-item {
  position: relative;
  min-height: 88px;
  padding: 0 6px;
  border-left: 3px solid transparent;
  color: rgba(255, 255, 255, 0.96);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0;
  text-align: center;
  transition: background-color 0.18s ease, border-color 0.18s ease;
}

.nav-item:hover {
  background: #3a3a3a;
}

.nav-item.active {
  background: #3a3a3a;
  border-left-color: #ff4c55;
}

.nav-icon {
  width: 22px;
  height: 22px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.nav-icon svg {
  width: 100%;
  height: 100%;
  color: #ffffff;
}

.nav-item.active .nav-icon svg {
  color: #ff4c55;
}

.nav-item.active .nav-label {
  color: #ffffff;
  font-weight: 500;
}

.nav-label {
  width: 58px;
  margin-top: 8px;
  font-size: 10px;
  line-height: 1.08;
  font-weight: 500;
  transition: opacity 0.18s ease, max-height 0.18s ease, margin 0.18s ease;
}

.sidebar.is-collapsed {
  width: 58px;
  min-width: 58px;
}

.sidebar.is-collapsed .nav-item {
  min-height: 58px;
  padding: 0;
}

.sidebar.is-collapsed .nav-icon {
  width: 20px;
  height: 20px;
}

.sidebar.is-collapsed .nav-label {
  opacity: 0;
  max-height: 0;
  margin-top: 0;
  overflow: hidden;
  pointer-events: none;
}

.main {
  margin-left: 92px;
  width: calc(100% - 92px);
  display: flex;
  flex-direction: column;
  min-width: 0;
  min-height: 100vh;
  transition: margin-left 0.22s ease, width 0.22s ease;
}

.main.is-collapsed {
  margin-left: 58px;
  width: calc(100% - 58px);
}

.sidebar-bottom {
  padding: 0 0 8px;
  display: flex;
  justify-content: center;
}

.sidebar-collapse-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: rgba(255, 255, 255, 0.9);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.18s ease, color 0.18s ease;
}

.sidebar.is-collapsed .sidebar-collapse-btn {
  width: 34px;
  height: 34px;
}

.sidebar-collapse-btn svg {
  width: 22px;
  height: 22px;
}

.sidebar.is-collapsed .sidebar-collapse-btn svg {
  width: 20px;
  height: 20px;
}

.sidebar-collapse-btn:hover,
.sidebar-collapse-btn:focus-visible {
  background: rgba(255, 255, 255, 0.1);
  color: #ffffff;
  outline: none;
}

.page-content {
  flex: 1;
  padding: 100px 26px 34px;
}

@media (max-width: 960px) {
  .dashboard-layout {
    flex-direction: row;
  }

  .sidebar {
    z-index: 1300;
  }

  .main {
    margin-left: 0;
    width: 100%;
  }

  .nav {
    flex-direction: column;
  }

  .nav-item {
    min-height: 88px;
    border-left: 3px solid transparent;
  }

  .nav-item.active {
    border-bottom-color: transparent;
    border-left-color: #ff4c55;
  }

  .page-content {
    padding: 96px 18px 18px;
  }
}
</style>
