import { createRouter, createWebHistory } from 'vue-router';
import { isAuthenticated } from '../lib/auth';
import LandingPage from '../views/LandingPage.vue';
import Login from '../views/Login.vue';
import Register from '../views/Register.vue';
import ForgotPassword from '../views/ForgotPassword.vue';
import Dashboard from '../views/Dashboard.vue';

const DashboardHome = () => import('../views/DashboardHome.vue');
const OrderRecords = () => import('../views/OrderRecords.vue');
const HistoryRecords = () => import('../views/HistoryRecords.vue');
const ReportsIssues = () => import('../views/ReportsIssues.vue');
const UserManagement = () => import('../views/UserManagement.vue');
const NotificationsPage = () => import('../views/NotificationsPage.vue');

const DISABLE_AUTH_FOR_UI_PREVIEW = false;

const routes = [
  DISABLE_AUTH_FOR_UI_PREVIEW
    ? { path: '/', redirect: '/dashboard' }
    : { path: '/', component: LandingPage },
  { path: '/login', component: Login, meta: { guestOnly: true } },
  { path: '/register', component: Register, meta: { guestOnly: true } },
  { path: '/forgot-password', component: ForgotPassword, meta: { guestOnly: true } },
  {
    path: '/dashboard',
    component: Dashboard,
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'DashboardHome', component: DashboardHome },
      { path: 'order-records', name: 'OrderRecords', component: OrderRecords },
      { path: 'history-records', name: 'HistoryRecords', component: HistoryRecords },
      { path: 'reports-issues', name: 'ReportsIssues', component: ReportsIssues },
      { path: 'user-management', name: 'UserManagement', component: UserManagement },
      { path: 'notifications', name: 'Notifications', component: NotificationsPage },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to) => {
  if (DISABLE_AUTH_FOR_UI_PREVIEW) {
    if (to.path === '/login' || to.path === '/register' || to.path === '/forgot-password') {
      return '/dashboard';
    }

    return true;
  }

  const authenticated = isAuthenticated();

  if (to.matched.some((record) => record.meta.requiresAuth) && !authenticated) {
    return '/login';
  }

  if (to.matched.some((record) => record.meta.guestOnly) && authenticated) {
    return '/dashboard';
  }

  return true;
});

export default router;
