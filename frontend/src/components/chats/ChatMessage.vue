<script setup>
  defineProps({
    message: Object,
    chatType: String
  });

  function formatHM(isoString) {
    return new Date(isoString).toLocaleTimeString("es-AR", {
      hour: "2-digit",
      minute: "2-digit"
    })
  }
</script>

<template>
  <div class="all" :class="{'first' : message?.isFirst}">
    <img v-if="chatType == 'group' && message.type == 'incoming' && message?.isFirst" :src="message.avatar_url" class="avatar" alt="User Avatar">
    <div class="message"
      :class="[
        message.type,
        { 'with-avatar-offset': chatType == 'private' || (chatType == 'group' && !message.isFirst) }
      ]"
    >
      <div v-if="chatType == 'group' && message.type == 'incoming' && message?.isFirst" class="message-header">
        <span class="user-name">{{ message.sender_name }}</span>
      </div>
      <div class="message-body">
        <span class="content">{{ message.content }}</span>
        <span class="time">{{ formatHM(message.time) }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.all {
  display: flex;
  gap: 1rem;
}
.first {
  margin-top: 1rem;
}
.message {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;

  max-width: 65%;
  padding: 0.6rem 1rem 0.3rem 1.4rem;
  border-radius: 15px;
}
.with-avatar-offset {
  margin-left: calc(3rem + 1rem);
}
.outgoing {
  background: var(--msg-out);
  margin-left: auto;
  margin-right: calc(3rem + 1rem);
}
.incoming {
  background: var(--msg-in);
  margin-right: auto;
}

.message-header {
  display: flex;
  gap: 1rem;
  align-items: center;

  opacity: 0.8;
}
.avatar {
  height: 3rem;
  width: 3rem;
  border-radius: 50%;
  background-color: cyan;
}
.user-name {
  font-size: 1.28rem;
}

.message-body {
  display: inline-flex;
  align-items: flex-end;
  gap: 6px;


  font-size: 1.4rem;
  line-height: 1.3;
  text-align: left;
}
.content {
  white-space: pre-wrap;
  word-break: break-word;
  padding-bottom: 0.3rem;
}
.time {
  font-size: 1.1rem;
  opacity: 0.6;
  flex-shrink: 0;
}
</style>
