<script setup></script>

<template>
  <header class="chat-header">
    <img class="avatar" />
    <div>
      <p class="name">Manu</p>
      <span class="status">Activo</span>
    </div>
  </header>
</template>

<style scoped>
.chat-header {
  background-color: var(--bg-chat-header);
  height: 7rem;
  padding: 1.6rem;
  display: flex;
  align-items: center;
  gap: 1.2rem;
  /*border-bottom: 1px solid rgba(255,255,255,0.05);*/
}
.avatar {
  background-color: aqua;
  height: 5rem;
  width: 5rem;
  border-radius: 50%;
}
.name {
  color: var(--text-main);
  font-size: 2.2rem;
  font-weight: bold;
}
.status {
  font-size: 12px;
  color: var(--text-muted);
}
</style>
