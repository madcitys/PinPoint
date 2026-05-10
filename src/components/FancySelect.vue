<template>
  <div
    ref="root"
    class="fancy-select"
    :class="[
      `fancy-select--${variant}`,
      `fancy-select--${tone}`,
      `fancy-select--align-${align}`,
      {
        'is-open': isOpen,
        'is-disabled': disabled,
        'is-empty': !selectedOption,
        'is-fluid': fullWidth,
      },
    ]"
    :style="componentStyle"
  >
    <button
      type="button"
      class="fancy-select-trigger"
      :disabled="disabled"
      :aria-expanded="isOpen"
      aria-haspopup="listbox"
      @click="toggleOpen"
    >
      <span class="fancy-select-value">
        {{ selectedOption?.label ?? placeholder }}
      </span>
      <span class="fancy-select-chevron" aria-hidden="true">
        <svg viewBox="0 0 20 20">
          <path
            d="M5.5 7.5 10 12l4.5-4.5"
            fill="none"
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.9"
          />
        </svg>
      </span>
    </button>

    <transition name="fancy-select-menu">
      <div
        v-if="isOpen"
        class="fancy-select-menu"
        role="listbox"
      >
        <button
          v-for="option in normalizedOptions"
          :key="option.key"
          type="button"
          class="fancy-select-option"
          :class="{
            selected: isSelected(option),
            disabled: option.disabled,
          }"
          :disabled="option.disabled"
          @click="selectOption(option)"
        >
          <span class="fancy-select-option-label">{{ option.label }}</span>
          <span v-if="isSelected(option)" class="fancy-select-check" aria-hidden="true">
            <svg viewBox="0 0 20 20">
              <path
                d="M4.5 10.5 8.2 14 15.5 6.8"
                fill="none"
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
              />
            </svg>
          </span>
        </button>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number, Boolean, null],
    default: '',
  },
  options: {
    type: Array,
    default: () => [],
  },
  placeholder: {
    type: String,
    default: 'Select an option',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  variant: {
    type: String,
    default: 'field',
  },
  tone: {
    type: String,
    default: 'neutral',
  },
  align: {
    type: String,
    default: 'left',
  },
  fullWidth: {
    type: Boolean,
    default: true,
  },
  menuMaxHeight: {
    type: String,
    default: '280px',
  },
})

const emit = defineEmits(['update:modelValue', 'change'])

const root = ref(null)
const isOpen = ref(false)

const normalizedOptions = computed(() =>
  props.options.map((option, index) => {
    if (typeof option === 'object' && option !== null) {
      const value = Object.prototype.hasOwnProperty.call(option, 'value') ? option.value : ''

      return {
        key: option.key ?? `${String(value)}-${index}`,
        label: option.label ?? String(value),
        value,
        disabled: Boolean(option.disabled),
      }
    }

    return {
      key: `${String(option)}-${index}`,
      label: String(option),
      value: option,
      disabled: false,
    }
  }),
)

const selectedOption = computed(
  () => normalizedOptions.value.find((option) => Object.is(option.value, props.modelValue)) ?? null,
)

const componentStyle = computed(() => ({
  '--select-menu-max-height': props.menuMaxHeight,
  width: props.fullWidth ? '100%' : 'auto',
}))

function isSelected(option) {
  return Object.is(option.value, props.modelValue)
}

function closeMenu() {
  isOpen.value = false
}

function toggleOpen() {
  if (props.disabled) {
    return
  }

  isOpen.value = !isOpen.value
}

function selectOption(option) {
  if (option.disabled) {
    return
  }

  if (!Object.is(option.value, props.modelValue)) {
    emit('update:modelValue', option.value)
    emit('change', option.value, option)
  }

  closeMenu()
}

function handleDocumentMouseDown(event) {
  if (root.value && !root.value.contains(event.target)) {
    closeMenu()
  }
}

function handleDocumentKeydown(event) {
  if (event.key === 'Escape') {
    closeMenu()
  }
}

watch(
  () => props.disabled,
  (nextDisabled) => {
    if (nextDisabled) {
      closeMenu()
    }
  },
)

onMounted(() => {
  document.addEventListener('mousedown', handleDocumentMouseDown)
  document.addEventListener('keydown', handleDocumentKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('mousedown', handleDocumentMouseDown)
  document.removeEventListener('keydown', handleDocumentKeydown)
})
</script>

<style scoped>
.fancy-select {
  position: relative;
  min-width: 0;
  --select-trigger-min-height: 56px;
  --select-trigger-padding: 0 18px;
  --select-trigger-radius: 18px;
  --select-trigger-font-size: 16px;
  --select-trigger-font-weight: 700;
  --select-trigger-border: rgba(210, 219, 231, 0.95);
  --select-trigger-background: #ffffff;
  --select-trigger-color: var(--text-main);
  --select-trigger-shadow: inset 0 1px 2px rgba(15, 23, 42, 0.03);
  --select-trigger-hover-border: rgba(216, 93, 20, 0.2);
  --select-trigger-hover-shadow: 0 14px 24px rgba(15, 23, 42, 0.08);
  --select-menu-min-width: 100%;
  --select-menu-padding: 10px;
}

.fancy-select-trigger {
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  width: 100%;
  min-height: var(--select-trigger-min-height);
  padding: var(--select-trigger-padding);
  border: 1px solid var(--select-trigger-border);
  border-radius: var(--select-trigger-radius);
  background: var(--select-trigger-background);
  color: var(--select-trigger-color);
  box-shadow: var(--select-trigger-shadow);
  font-size: var(--select-trigger-font-size);
  font-weight: var(--select-trigger-font-weight);
  text-align: left;
  cursor: pointer;
  transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease, background-color 0.18s ease;
}

.fancy-select-trigger:hover {
  transform: translateY(-1px);
  border-color: var(--select-trigger-hover-border);
  box-shadow: var(--select-trigger-hover-shadow);
}

.fancy-select.is-open .fancy-select-trigger {
  border-color: rgba(216, 93, 20, 0.22);
  box-shadow: 0 16px 30px rgba(15, 23, 42, 0.1);
}

.fancy-select.is-disabled .fancy-select-trigger {
  opacity: 0.58;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.fancy-select-value {
  min-width: 0;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.fancy-select.is-empty .fancy-select-value {
  color: #6b778c;
}

.fancy-select-chevron {
  display: inline-flex;
  width: 18px;
  height: 18px;
  flex: 0 0 auto;
  transition: transform 0.18s ease;
}

.fancy-select.is-open .fancy-select-chevron {
  transform: rotate(180deg);
}

.fancy-select-chevron svg {
  width: 100%;
  height: 100%;
}

.fancy-select-menu {
  position: absolute;
  top: calc(100% + 10px);
  z-index: 80;
  min-width: var(--select-menu-min-width);
  max-height: var(--select-menu-max-height);
  overflow-y: auto;
  padding: var(--select-menu-padding);
  border: 1px solid rgba(255, 133, 51, 0.16);
  border-radius: 24px;
  background:
    radial-gradient(circle at top left, rgba(255, 161, 78, 0.08), transparent 34%),
    linear-gradient(180deg, #fffdfb 0%, #ffffff 100%);
  box-shadow: 0 26px 56px rgba(15, 23, 42, 0.16);
}

.fancy-select--align-left .fancy-select-menu {
  left: 0;
}

.fancy-select--align-right .fancy-select-menu {
  right: 0;
}

.fancy-select-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
  min-height: 44px;
  padding: 0 14px;
  border: 0;
  border-radius: 14px;
  background: transparent;
  color: var(--text-main);
  font-size: 15px;
  font-weight: 600;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.18s ease, color 0.18s ease, transform 0.18s ease;
}

.fancy-select-option:hover {
  transform: translateY(-1px);
  background: rgba(255, 111, 0, 0.08);
  color: #c75a10;
}

.fancy-select-option.selected {
  background: rgba(255, 111, 0, 0.12);
  color: #c75a10;
}

.fancy-select-option.disabled {
  opacity: 0.52;
  cursor: not-allowed;
  transform: none;
}

.fancy-select-option-label {
  min-width: 0;
  overflow-wrap: anywhere;
}

.fancy-select-check {
  display: inline-flex;
  width: 16px;
  height: 16px;
  flex: 0 0 auto;
}

.fancy-select-check svg {
  width: 100%;
  height: 100%;
}

.fancy-select--toolbar {
  --select-trigger-min-height: 48px;
  --select-trigger-padding: 0 16px;
  --select-trigger-radius: 16px;
  --select-trigger-font-size: 15px;
  --select-trigger-font-weight: 700;
  --select-trigger-border: var(--border-soft);
  --select-trigger-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.75);
}

.fancy-select--status {
  --select-trigger-min-height: 50px;
  --select-trigger-padding: 0 18px;
  --select-trigger-radius: 999px;
  --select-trigger-font-size: 0.92rem;
  --select-trigger-font-weight: 700;
  --select-menu-min-width: 188px;
}

.fancy-select--warning {
  --select-trigger-background: #fff6d8;
  --select-trigger-border: rgba(159, 106, 0, 0.18);
  --select-trigger-color: #9f6a00;
  --select-trigger-shadow: none;
  --select-trigger-hover-border: rgba(159, 106, 0, 0.28);
  --select-trigger-hover-shadow: 0 12px 22px rgba(159, 106, 0, 0.12);
}

.fancy-select--success {
  --select-trigger-background: #ecfbf1;
  --select-trigger-border: rgba(15, 127, 87, 0.18);
  --select-trigger-color: #0f7f57;
  --select-trigger-shadow: none;
  --select-trigger-hover-border: rgba(15, 127, 87, 0.28);
  --select-trigger-hover-shadow: 0 12px 22px rgba(15, 127, 87, 0.12);
}

.fancy-select-menu-enter-active,
.fancy-select-menu-leave-active {
  transition: opacity 0.16s ease, transform 0.16s ease;
}

.fancy-select-menu-enter-from,
.fancy-select-menu-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}
</style>
