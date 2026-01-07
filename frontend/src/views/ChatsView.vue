<script setup>
  import { computed } from "vue";
  import { onMounted } from "vue";
  import { useRouter } from "vue-router";
  import { useSocketStore } from "@/stores/socket";

  import Sidebar from "@/components/layout/Sidebar.vue";
  import ChatList from "@/components/chats/ChatList.vue";
  import ChatHeader from "@/components/chats/ChatHeader.vue";
  import ChatMessages from "@/components/chats/ChatMessages.vue";
  import ChatInput from "@/components/chats/ChatInput.vue";

  const router = useRouter();
  const socketStore = useSocketStore();
  const user = computed(() => socketStore.userInfo);

  onMounted(() => {
    const token = sessionStorage.getItem("token");
    if (token){
      socketStore.connect(token);
    }
  });

  function logout() {
    sessionStorage.removeItem("token");
    socketStore.disconnect();
    router.push("/login");
  }
</script>

<template>
  <div class="chats-layout">
    <div class="left">
      <img src="/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
      <div class="main">
        <Sidebar />
        <ChatList />
      </div>
    </div>
    <div class="right">
      <ChatHeader />
      <ChatMessages />
      <ChatInput />
    </div>
  </div>
</template>

<style scoped>
.chats-layout {
  display: flex;
  flex-direction: row;
  height: 100vh;
  /*overflow: hidden;     /* no scroll global */
}
.left {
  display: flex;
  flex-direction: column;
  align-items: baseline;
  height: 100%;
  width: 40%;
}
.logo {
  height: 6rem;
	padding: 2rem;
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

.chat-area {
  width: 70%;
  display: flex;
  flex-direction: column;
}
</style>