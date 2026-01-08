<script setup>
  defineProps({
    chat: Object
  });
  import IconSettings from '../icons/IconSettings.vue';
</script>

<template>
  <div class="chat-item">
    <img class="avatar" />
    <div class="info">
      <div class="up">
        <div class="texto">
          <p class="name">Manu</p>
          <p class="status">Activo</p>
        </div>
        <div class="unread-messages">
          5
        </div>
      </div>
      <div class="down">
        <div class="last-message">
          <IconSettings class="icon"/>
          <p class="text">Sale cs?</p>
        </div>
        <span class="time">9:25</span>
      </div>
    </div>
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
.avatar {
  height: 7rem;
  width: 7rem;
  background-color: cyan;
  border-radius: 50%;
}
.info {
  display: flex;
  flex-direction: column;
  flex: 1;
}
.up {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  flex: 1;
}
.texto {
  margin-right: 1.5rem;
  display: flex;
  align-items: flex-end;
  line-height: 1;
}
.name {
  color: var(--text-main);
  font-weight: 600;
  margin-right: 1.5rem;
}
.status, .last-message .text{
  color: var(--text-muted);
  font-size: 1.4rem;
}
.unread-messages {
  height: 2.4rem;
  width: 2.4rem;
  background-color: var(--msg-out);
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.down {
  display: flex;
  justify-content: space-between;
}
.last-message {
  display: flex;
  margin-right: 1.5rem;
}
.icon {
  height: 2.2rem;
  margin-right: 0.5rem;
}
.time {
  font-size: 1.2rem;
  color: var(--text-muted);
}
</style>
