<script setup>
  import ChatListItem from "./ChatListItem.vue";
  const chats = [
    {
      name: "Manu",
      status: "Activo",
      unread: 0,
      lastMessage: {
        type: "outgoing",
        text: "Sale cs?",
        state: "sent",
        time: "9:25"
      }
    },
    {
      name: "Rocío",
      status: "Activo",
      unread: 0,
      lastMessage: {
        type: "outgoing",
        text: "Buenasss",
        state: "delivered",
        time: "9:10"
      }
    },
    {
      name: "Martín",
      status: "Activo",
      unread: 0,
      lastMessage: {
        type: "outgoing",
        text: "jasjajsjaja",
        state: "read",
        time: "9:06"
      }
    },
    {
      name: "Mati",
      status: "Activo",
      unread: 3,
      lastMessage: {
        type: "incoming",
        text: "Dale entreguen el tp",
        state: "delivered",
        time: "9:25"
      }
    },
    {
      name: "Ricky",
      status: "Activo",
      unread: 5,
      lastMessage: {
        type: "incoming",
        text: "su lol?",
        state: "delivered",
        time: "9:30"
      }
    }
  ]
</script>

<template>
  <div class="chat-list">
    <ChatListItem 
      v-for="chat in chats"
      :key="chat.name"
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
