<script setup>
    defineProps({
        chat: Object
    });
</script>

<template>
  <div class="chat-item">
    <img class="avatar" />
    <div class="info">
      <p class="name">Manu</p>
      <p class="last-message">Sale cs?</p>
    </div>
    <span class="time">9:25</span>
  </div>
</template>

<style scoped>
.chat-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  cursor: pointer;
}
.chat-item:hover {
  background: #233356;
  border-radius: 1.5rem;
}
.name {
  color: var(--text-main);
  font-weight: 600;
}
.last-message {
  color: var(--text-muted);
  font-size: 13px;
}
.time {
  margin-left: auto;
  font-size: 12px;
  color: var(--text-muted);
}
</style>
