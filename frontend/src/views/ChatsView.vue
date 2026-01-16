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

  const socketStore = useSocketStore();

  const { chats } = storeToRefs(socketStore);
  const { chatsInfo } = storeToRefs(socketStore);
  const { activeChatId } = storeToRefs(socketStore);
  
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
  onMounted(() => {
    const token = sessionStorage.getItem("token");
    if (token){
      socketStore.connect(token);
    }
  });
</script>

<template>
  <div class="chats-layout">
    <div class="left">
      <img src="@/assets/logo/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
      <div class="main">
        <Sidebar /> <!-- TODO: Pasarle user.avatar_url del user_info --> 
        <ChatList 
          :chats="chats" 
          @open-chat="handleOpenChat"
        />
      </div>
    </div>
    <div class="right">
      <ChatHeader />
      <ChatMessages 
        :messages="messages"
        :chatType="chatType"
      />
      <ChatInput />
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