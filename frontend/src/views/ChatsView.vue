<script setup>
  import { computed } from "vue";
  import { onMounted } from "vue";
  import { useRouter } from "vue-router";
  import { useSocketStore } from "@/stores/socket";
  import { storeToRefs } from "pinia";

  import Sidebar from "@/components/layout/Sidebar.vue";
  import ChatList from "@/components/chats/ChatList.vue";
  import ChatHeader from "@/components/chats/ChatHeader.vue";
  import ChatMessages from "@/components/chats/ChatMessages.vue";
  import ChatInput from "@/components/chats/ChatInput.vue";
   import { getCurrentISOTimeString } from '@/utils/formatChatTime'
   import { generateId } from '@/utils/idGenerator'

  const socketStore = useSocketStore();

  const { userInfo } = storeToRefs(socketStore);
  const { chats } = storeToRefs(socketStore);
  const { chatsInfo } = storeToRefs(socketStore);
  const { activeChatId } = storeToRefs(socketStore);
  
  onMounted(() => {
    const token = sessionStorage.getItem("token");
    if (token){
      socketStore.connect(token);
    }
  });

  const activeChat = computed(() =>
    activeChatId.value
      ? chatsInfo.value[activeChatId.value]
      : null
  );

  const messages = computed(() => activeChat.value?.messages ?? []);
  const chatType = computed(() => activeChat.value?.type ?? null);

  function handleOpenChat(chatId) {
    socketStore.openChat(chatId)
  }

  function handleSendMessage(text) {
    if (!activeChatId.value) return;
    socketStore.sendMessage({
      id: null,
      front_msg_id: generateId(),
      chat_id: activeChatId.value,
      content: text,
      state: "sending", // Cuando se guarde en el back se pisa por sent
      sender_user_id: userInfo.value.id,
      type: "outgoing",
      time: getCurrentISOTimeString() // Despues se pisa con el inserted_at del back
    })
  }
</script>

<template>
  <div class="chats-layout">
    <div class="left">
      <img src="@/assets/logo/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
      <div class="main">
        <Sidebar :avatarURL="userInfo?.avatar_url"/>
        <ChatList 
          :chats="chats" 
          @open-chat="handleOpenChat"
        />
      </div>
    </div>
    <div class="right">
      <ChatHeader 
        :chatInfo="activeChat"
      />
      <ChatMessages 
        :messages="messages"
        :chatType="chatType"
      />
      <ChatInput @send-message="handleSendMessage"/>
    </div>
  </div>
</template>

<style scoped>
.chats-layout {
  display: flex;
  flex-direction: row;
  height: 100vh;
}
.left {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  height: 100%;
  width: var(--left-section-width);
}
.logo {
  height: 6rem;
	margin: 2rem;
}
.main {
  display: flex;
  flex-direction: row;
  flex: 1;
  width: 100%;
}
.right {
  display: flex;
  flex-direction: column;
  flex: 1;
  height: 100%;
}
</style>