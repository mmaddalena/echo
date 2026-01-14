<script setup>
  import ChatMessage from "./ChatMessage.vue";
  import { computed } from 'vue'

  const props = defineProps({
    messages: {
      type: Array,
      required: true
    }
  })
  const orderedMessages = computed(() => {
    return [...props.messages].sort((a, b) => {
      const tA = new Date(a.time ?? 0)
      const tB = new Date(b.time ?? 0)
      return tB - tA
    })
  })
  import { watch } from "vue"
  watch(orderedMessages, (val) => {
    console.log(val)
  })
</script>

<template>
  <div class="chat-messages">
    <ChatMessage 
      v-for="message in orderedMessages"
      :key="message.id"
      :message="message"
    />
  </div>
</template>

<style scoped>
.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 5px;
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
  background-color: var(--bg-chat);
}
</style>
