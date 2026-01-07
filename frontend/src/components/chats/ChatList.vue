<script setup>
    import ChatListItem from "./ChatListItem.vue";
</script>

<template>
  <div class="chat-list">
    <ChatListItem />
    <ChatListItem />
    <ChatListItem />
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
