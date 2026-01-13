<script setup>
  import ChatListItem from "./ChatListItem.vue";
  defineProps({
    chats: {
      type: Array,
      required: true
    }
  })
</script>

<template>
  <div class="chat-list">
    <ChatListItem 
      v-for="chat in chats"
      :key="chat.id"
      :chat="chat"
    />
  </div>
</template>

<style scoped>
.chat-list {
  height: 100%;
  flex: 1;
  background: var(--bg-chatlist-panel);
  overflow-y: auto;
}
</style>
