<script setup>
  import ChatMessage from "./ChatMessage.vue";
  import { computed, watch, ref, nextTick, onMounted } from 'vue'
    import { formatDayLabel } from '@/utils/formatChatTime'

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

  const messagesWithDays = computed(() => {
    let lastDay = null
    const result = []

    enhancedMessages.value.forEach((message) => {
      const dayKey = new Date(message.time).toDateString()

      if (dayKey !== lastDay) {
        result.push({
          front_msg_id: `day-${dayKey}`,
          kind: 'day',
          label: formatDayLabel(message.time)
        })
        lastDay = dayKey
      }

      result.push({
        ...message,
        kind: 'message'
      })
    })

    return result
  })

  

  const messagesContainer = ref(null)

  function scrollToBottom() {
    nextTick(() => {
      if (messagesContainer.value) {
        messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
      }
    })
  }

  // Scroll al final al montar
  onMounted(() => {
    scrollToBottom()
  });

  // Scroll automático al agregar mensajes
  watch(
    () => messagesWithDays.value,
    async () => {
      await nextTick() // espera que Vue actualice el DOM
      scrollToBottom()
    },
    { deep: true }
  )
  
</script>

<template>
  <div class="chat-messages" ref="messagesContainer">
    <template v-for="item in messagesWithDays" :key="item.front_msg_id">
      <div v-if="item.kind === 'day'" class="day-separator">
        {{ item.label }}
      </div>

      <ChatMessage
        v-else
        :message="item"
        :chatType="chatType"
      />
    </template>
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
.day-separator {
  align-self: center;
  margin: 1rem 0;

  padding: 0.4rem 1rem;
  border-radius: 999px;

  font-size: 1.2rem;
  opacity: 0.7;
  background: rgba(0,0,0,0.15);
}

</style>
