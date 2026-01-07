<script setup>
  defineProps({
    variant: {
      type: String,
      default: "light"
    }
  })
</script>

<template>
  <svg v-if="variant === 'light'" v-bind="$attrs" class="icon-light">
    
  </svg>
  <svg v-else v-bind="$attrs" class="icon-dark">
    
  </svg>
</template>

<style scoped>
.icon-light {
  fill: var(--msg-in);
}
.icon-dark{
  fill: var(--msg-out);
}
</style>