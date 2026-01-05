<script setup>
  import { computed } from "vue";
  import { useSocketStore } from "@/stores/socket";

  const socketStore = useSocketStore();
  const user = computed(() => socketStore.userInfo);
</script>

<template>
  <div class="chat-container">
    <img src="/Echo_Logo_Completo_Negativo.svg" class="logo" />

    <div v-if="user" class="user-card">
      <p><strong>Usuario:</strong> {{ user.username }}</p>
      <p><strong>Email:</strong> {{ user.email }}</p>
    </div>

    <p v-else>Cargando usuario...</p>
  </div>
</template>

<style scoped>
.chat-container {
  min-height: 100vh;
  width: 600px;
  border-radius: 20px;
  background: #0f172a;
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 40px;
}

.logo {
  height: 3em;
  margin-bottom: 24px;
}

.user-card {
  background: #1e293b;
  width: 200px;
  padding: 16px 24px;
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.3);
}
</style>