<script setup>
  import ChatMessage from "./ChatMessage.vue";
  import { computed } from 'vue'

  const props = defineProps({
    messages: {
      type: Array,
      required: true
    },
    chatType: String
  })
  const orderedMessages = computed(() => {
    return [...props.messages].sort((a, b) => {
      const tA = new Date(a.time ?? 0)
      const tB = new Date(b.time ?? 0)
      return tA - tB
    })
  })
  import { watch } from "vue"
  watch(orderedMessages, (val) => {
    console.log(val)
  })


  const enhancedMessages = computed(() => {
    let lastUserId = null

    return orderedMessages.value.map((message) => {
      const currentUserId = message.sender_user_id

      const isFirst = currentUserId !== lastUserId

      lastUserId = currentUserId

      return {
        ...message,
        isFirst
      }
  })
})

</script>

<template>
  <div class="chat-messages">
    <ChatMessage 
      v-for="message in enhancedMessages"
      :key="message.id"
      :message="message"
      :chatType="chatType"
    />
  </div>
</template>

<style scoped>
.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
  background-color: var(--bg-chat);
}
</style>
