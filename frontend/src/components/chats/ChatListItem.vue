<script setup>
  const { chat } = defineProps({
    chat: Object
  });
  import IconMessageState from '../icons/IconMessageState.vue';
  import { formatChatTime } from '@/utils/formatChatTime'

  const isMuted = 
    chat.last_message.type === 'outgoing' ||
    (chat.last_message.type === 'incoming' &&
     chat.last_message.state === 'read')
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
        >
          {{ chat.unread_messages }}
        </div>
      </div>
      <div class="down">
        <div class="last-message">
          <IconMessageState 
            v-if="chat.last_message.type === 'outgoing'"
            class="icon" 
            :state="chat.last_message.state" 
          />
          <p 
            class="text"
            :class="{muted: isMuted}"
          >
            {{ chat.last_message.content }}
          </p>
        </div>
        <span 
          class="time"
          :class="{muted: isMuted}"
        >
          {{ formatChatTime(chat.last_message.time)}}
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
  background: var(--bg-chatlist-hover);
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
  min-width: 0;
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
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
  min-width: 0;
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
  overflow: hidden;
  flex: 1;
  min-width: 0;
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
