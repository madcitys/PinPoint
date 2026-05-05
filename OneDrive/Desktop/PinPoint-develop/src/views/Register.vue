<template>
  <div class="register-page">
    <form class="register-card" @submit.prevent="handleRegister">
      <img src="../assets/logo1.png" alt="Logo" class="logo" />

      <h2>Creating Account</h2>
      <p class="subtitle">View your growth and connect!</p>

      <div class="form-group">
        <label>First Name</label>
        <input
          type="text"
          placeholder="Enter First Name"
          v-model="firstName"
          autocomplete="given-name"
        />
      </div>

      <div class="form-group">
        <label>Last Name</label>
        <input
          type="text"
          placeholder="Enter Last Name"
          v-model="lastName"
          autocomplete="family-name"
        />
      </div>

      <div class="form-group">
        <label>Security Code</label>
        <div class="password-wrapper">
          <input
            :type="showSecurity ? 'text' : 'password'"
            placeholder="Enter Security Code"
            v-model="securityCode"
          />
          <button type="button" class="toggle" @click="showSecurity = !showSecurity">
            {{ showSecurity ? 'Hide' : 'Show' }}
          </button>
        </div>
      </div>

      <div class="form-group">
        <label>Password</label>
        <div class="password-wrapper">
          <input
            :type="showPassword ? 'text' : 'password'"
            placeholder="Enter your Password"
            v-model="password"
            autocomplete="new-password"
          />
          <button type="button" class="toggle" @click="showPassword = !showPassword">
            {{ showPassword ? 'Hide' : 'Show' }}
          </button>
        </div>
      </div>

      <div class="form-group">
        <label>Confirm Password</label>
        <div class="password-wrapper">
          <input
            :type="showConfirm ? 'text' : 'password'"
            placeholder="Confirm your Password"
            v-model="confirmPassword"
            autocomplete="new-password"
          />
          <button type="button" class="toggle" @click="showConfirm = !showConfirm">
            {{ showConfirm ? 'Hide' : 'Show' }}
          </button>
        </div>
      </div>

      <p v-if="errorMessage" class="form-message error">{{ errorMessage }}</p>

      <button class="register-btn" type="submit" :disabled="isSubmitting">
        {{ isSubmitting ? 'Creating Account...' : 'Register' }}
      </button>
    </form>

    <div v-if="successSession" class="success-overlay">
      <div class="success-card">
        <p class="success-eyebrow">Account Created</p>
        <h3>Welcome, {{ successSession.user.fullName || `${firstName} ${lastName}`.trim() }}!</h3>
        <p class="success-copy">
          Your account was created successfully.
        </p>
        <div class="user-id-box">
          <span class="user-id-label">Your User ID</span>
          <strong>{{ successSession.user.userId }}</strong>
        </div>
        <p class="success-note">Use this ID for future logins.</p>
        <button class="register-btn success-btn" type="button" @click="goToDashboard">
          Continue to Dashboard
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { apiRequest } from '../lib/api';
import { setAuthSession } from '../lib/auth';

const router = useRouter();

const firstName = ref('');
const lastName = ref('');
const securityCode = ref('');
const password = ref('');
const confirmPassword = ref('');

const showSecurity = ref(false);
const showPassword = ref(false);
const showConfirm = ref(false);
const isSubmitting = ref(false);
const errorMessage = ref('');
const successSession = ref(null);

async function handleRegister() {
  errorMessage.value = '';
  isSubmitting.value = true;

  try {
    const session = await apiRequest('/auth/register', {
      method: 'POST',
      body: {
        firstName: firstName.value,
        lastName: lastName.value,
        securityCode: securityCode.value,
        password: password.value,
        confirmPassword: confirmPassword.value,
      },
    });

    setAuthSession(session);
    successSession.value = session;
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    isSubmitting.value = false;
  }
}

async function goToDashboard() {
  await router.push('/dashboard');
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: url("../assets/bg2.jpg") no-repeat center center / cover;
  display: flex;
  justify-content: center;
  align-items: center;
}

.register-card {
  background: #e5e5e5;
  width: 480px;
  padding: 30px 25px;
  border-radius: 8px;
  text-align: center;
}

.logo {
  width: 70px;
  margin-bottom: 2px;
}

h2 {
  margin: 10px 0 5px;
  font-size: 29px;
  color: #000000;
}

.subtitle {
  font-size: 14px;
  color: #555;
  margin-bottom: 20px;
}

input {
  width: 100%;
  padding: 12px;
  margin-bottom: 15px;
  border-radius: 6px;
  border: 1px solid #bbb;
  background-color: #f4f7f8;
  color: #333;
  outline: none;
}

input::placeholder {
  color: #6c757d;
}

.password-wrapper {
  position: relative;
}

.toggle {
  position: absolute;
  right: 12px;
  top: 34%;
  transform: translateY(-50%);
  cursor: pointer;
  opacity: 0.7;
  color: #000000;
  background: none;
  border: none;
  font-size: 12px;
}

.toggle:hover {
  opacity: 1;
}

input:-webkit-autofill,
input:-webkit-autofill:hover,
input:-webkit-autofill:focus {
  -webkit-box-shadow: 0 0 0 1000px #f4f7f8 inset !important;
  -webkit-text-fill-color: #333 !important;
}

.register-btn {
  width: 100%;
  padding: 14px;
  background: #cc3300;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-weight: bold;
  cursor: pointer;
  margin-top: 10px;
}

.register-btn:disabled {
  opacity: 0.7;
  cursor: wait;
}

.register-btn:hover:enabled {
  background: #b52d00;
}

.form-group {
  margin-bottom: 3px;
  text-align: left;
}

label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #000;
  margin-bottom: 6px;
}

.form-message {
  margin-bottom: 12px;
  font-size: 13px;
  text-align: left;
}

.form-message.error {
  color: #a32900;
}

.success-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.45);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  z-index: 50;
}

.success-card {
  width: min(420px, calc(100vw - 32px));
  background: #f8f4ef;
  border: 1px solid rgba(204, 51, 0, 0.15);
  border-radius: 20px;
  padding: 28px;
  box-shadow: 0 24px 60px rgba(15, 23, 42, 0.18);
  text-align: left;
}

.success-eyebrow {
  margin: 0 0 8px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #cc3300;
}

.success-card h3 {
  margin: 0;
  font-size: 28px;
  color: #101828;
}

.success-copy,
.success-note {
  color: #475467;
}

.success-copy {
  margin: 10px 0 18px;
}

.user-id-box {
  background: #ffffff;
  border: 1px solid #e4d9cc;
  border-radius: 16px;
  padding: 14px 16px;
}

.user-id-label {
  display: block;
  font-size: 12px;
  color: #667085;
  margin-bottom: 6px;
}

.user-id-box strong {
  font-size: 22px;
  color: #18212f;
  letter-spacing: 0.03em;
}

.success-note {
  margin: 12px 0 18px;
}

.success-btn {
  margin-top: 0;
}
</style>
