<script setup>
  import { computed } from 'vue'
  import ChatListItem from "./ChatListItem.vue";

  const emit = defineEmits(['open-chat'])

  const props = defineProps({
    chats: {
      type: Array,
      required: true
    }
  })

  function openChat(chatId) {
    emit('open-chat', chatId)
  }

  const orderedChats = computed(() => {
    return [...(props.chats ?? [])].sort((a, b) => {
      const tA = new Date(a.last_message?.time ?? 0)
      const tB = new Date(b.last_message?.time ?? 0)
      return tB - tA
    })
  })
</script>

<template>
  <div class="chat-list">
    <ChatListItem 
      v-for="chat in orderedChats"
      :key="chat.id"
      :chat="chat"
      @open="openChat"
    />
  </div>
</template>

<style scoped>
.chat-list {
  height: 100%;
  flex: 1;
  background: var(--bg-chatlist-panel);
  overflow-y: auto;
  padding: 1rem;
}
</style>
