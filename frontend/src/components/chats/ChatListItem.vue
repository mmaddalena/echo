<script setup>
  const props = defineProps({
    chat: Object
  });
  import IconMessageState from '../icons/IconMessageState.vue';

  const isMuted = 
    props.chat.lastMessage.type === 'outgoing' ||
    (props.chat.lastMessage.type === 'incoming' &&
     props.chat.lastMessage.state === 'read')
</script>

<template>
  <div class="chat-item">
    <img class="avatar" />
    <div class="info">
      <div class="up">
        <div class="texto">
          <p class="name">{{ chat.name }}</p>
          <p class="status">{{ chat.status }}</p>
        </div>
        <div 
          class="unread-messages"
          v-if="chat.unread > 0"
        >
          {{ chat.unread }}
        </div>
      </div>
      <div class="down">
        <div class="last-message">
        <IconMessageState 
          v-if="chat.lastMessage.type === 'outgoing'"
          class="icon" 
          :state="chat.lastMessage.state" 
        />
          <p 
            class="text"
            :class="{muted: isMuted}"
          >
            {{ chat.lastMessage.text }}
          </p>
        </div>
        <span 
          class="time"
          :class="{muted: isMuted}"
        >
          {{ chat.lastMessage.time }}
        </span>
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
  height: 5rem;
  width: 5rem;
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
.status {
  font-size: 1.4rem;
  color: var(--text-muted);
}
.last-message .text{
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
  color: var(--msg-out);
}
.time {
  font-size: 1.2rem;
}
.muted{
  color: var(--text-muted);
}
</style>
