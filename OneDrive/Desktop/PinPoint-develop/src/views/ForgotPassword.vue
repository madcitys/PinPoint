<template>
  <div class="forgot-page">
    <form class="forgot-card" @submit.prevent="handleResetPassword">
      <img src="../assets/logo1.png" alt="Logo" class="logo" />

      <h2>Reset Password</h2>
      <p class="subtitle">Enter your details to reset your password</p>

      <div class="form-group">
        <label>User ID</label>
        <input
          type="text"
          placeholder="Enter your user ID"
          v-model="userId"
          autocomplete="username"
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
        <label>New Password</label>
        <div class="password-wrapper">
          <input
            :type="showPassword ? 'text' : 'password'"
            placeholder="Enter your new password"
            v-model="newPassword"
            autocomplete="new-password"
          />
          <button type="button" class="toggle" @click="showPassword = !showPassword">
            {{ showPassword ? 'Hide' : 'Show' }}
          </button>
        </div>
      </div>

      <div class="form-group">
        <label>Confirm New Password</label>
        <div class="password-wrapper">
          <input
            :type="showConfirm ? 'text' : 'password'"
            placeholder="Re-enter your new password"
            v-model="confirmPassword"
            autocomplete="new-password"
          />
          <button type="button" class="toggle" @click="showConfirm = !showConfirm">
            {{ showConfirm ? 'Hide' : 'Show' }}
          </button>
        </div>
      </div>

      <p v-if="errorMessage" class="form-message error">{{ errorMessage }}</p>

      <button class="reset-btn" type="submit" :disabled="isSubmitting">
        {{ isSubmitting ? 'Updating Password...' : 'Reset Password' }}
      </button>
    </form>

    <div v-if="showSuccess" class="success-overlay">
      <div class="success-card">
        <p class="success-eyebrow">Password Updated</p>
        <h3>You're all set.</h3>
        <p class="success-copy">Your password has been changed successfully.</p>
        <button class="reset-btn success-btn" type="button" @click="goToLogin">
          Continue to Login
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { apiRequest } from '../lib/api';

const router = useRouter();

const userId = ref('');
const securityCode = ref('');
const newPassword = ref('');
const confirmPassword = ref('');

const showSecurity = ref(false);
const showPassword = ref(false);
const showConfirm = ref(false);
const isSubmitting = ref(false);
const errorMessage = ref('');
const showSuccess = ref(false);

async function handleResetPassword() {
  errorMessage.value = '';
  isSubmitting.value = true;

  try {
    await apiRequest('/auth/reset-password', {
      method: 'POST',
      body: {
        userId: userId.value,
        securityCode: securityCode.value,
        newPassword: newPassword.value,
        confirmPassword: confirmPassword.value,
      },
      token: null,
    });

    showSuccess.value = true;
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    isSubmitting.value = false;
  }
}

async function goToLogin() {
  await router.push('/login');
}
</script>

<style scoped>
.forgot-page {
  min-height: 100vh;
  background: url("../assets/bg2.jpg") no-repeat center center / cover;
  display: flex;
  justify-content: center;
  align-items: center;
}

.forgot-card {
  background: #e5e5e5;
  width: 380px;
  padding: 30px 25px;
  border-radius: 8px;
  text-align: center;
}

.logo {
  width: 70px;
  margin-bottom: 10px;
}

h2 {
  margin: 10px 0 5px;
  font-size: 29px;
  color: #000;
}

.subtitle {
  font-size: 14px;
  color: #555;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 16px;
  text-align: left;
}

label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #000;
  margin-bottom: 6px;
}

input {
  width: 100%;
  padding: 12px;
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
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  opacity: 0.7;
  color: #000;
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

.form-message {
  margin-bottom: 12px;
  font-size: 13px;
  text-align: left;
}

.form-message.error {
  color: #a32900;
}

.reset-btn {
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

.reset-btn:disabled {
  opacity: 0.7;
  cursor: wait;
}

.reset-btn:hover:enabled {
  background: #b52d00;
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
  width: min(400px, calc(100vw - 32px));
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

.success-copy {
  margin: 10px 0 18px;
  color: #475467;
}

.success-btn {
  margin-top: 0;
}
</style>
