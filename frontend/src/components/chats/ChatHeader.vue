<script setup>
import IconSearch from '../icons/IconSearch.vue';
import IconOptsMenu from '../icons/IconOptsMenu.vue';

</script>

<template>
  <header class="chat-header">
    <div class="user_info">
      <img class="avatar" />
      <div>
        <p class="name">Manu</p>
        <span class="status">Activo</span>
      </div>
    </div>
    <div class="opts_icons">
      <IconSearch class="icon" />
      <IconOptsMenu class="icon" />
    </div>
  </header>
</template>

<style scoped>
.chat-header {
  background-color: var(--bg-chat-header);
  height: 7rem;
  padding: 1.6rem;
  display: flex;
  box-sizing: content-box;
  align-items: center;
  justify-content: space-between;
  /*border-bottom: 1px solid rgba(255,255,255,0.05);*/
}
.user_info {
  display: flex;
  gap: 2rem;
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
.opts_icons {
  display: flex;
  gap: 2rem;
}
.icon {
  height: 3.5rem;
  color: var(--text-main);
  fill: var(--text-main);
}
</style>
