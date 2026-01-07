<script setup></script>

<template>
  <aside class="sidebar">
    <button>💬</button>
    <button>👥</button>
    <button>⚙️</button>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 9rem;
  height: 100%;
  background: none;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  align-items: center;
  padding: 16px 0;
  gap: 20px;
}
button {
  background: none;
  border: none;
  color: var(--text-muted);
  font-size: 20px;
  cursor: pointer;
}
</style>
