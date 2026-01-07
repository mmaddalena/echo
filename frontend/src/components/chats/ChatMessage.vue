<script setup>
  defineProps({
    text: String,
    type: String, // "incoming" | "outgoing"
    time: String
  });
</script>

<template>
  <div class="message" :class="type">
    <span class="message_body">{{ text }}</span>
    <span class="time">{{ time }}</span>
  </div>
</template>

<style scoped>
.message {
  display: inline-flex;
  align-items: flex-end;
  gap: 6px;

  max-width: 65%;
  padding: 6px 10px 3px 14px;
  border-radius: 15px;

  font-size: 14px;
  line-height: 1.3;
  text-align: left;
}

.outgoing {
  background: var(--msg-out);
  margin-left: auto;
}

.incoming {
  background: var(--msg-in);
  margin-right: auto;
}

.message_body {
  white-space: pre-wrap;
  word-break: break-word;
  padding-bottom: 3px;
}

.time {
  font-size: 11px;
  opacity: 0.6;
  flex-shrink: 0;
}
</style>
