<script setup>
  import { computed } from "vue";
  import { onMounted } from "vue";
  import { useRouter } from "vue-router";
  import { useSocketStore } from "@/stores/socket";

  import Sidebar from "@/components/layout/Sidebar.vue";
  import SettingsSectionsList from "../components/settings/SettingsSectionsList.vue";
  import SettingsPanel from "../components/settings/SettingsPanel.vue";

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
  <div class="settings-layout">
    <div class="left">
      <img src="@/assets/logo/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
      <div class="main">
        <Sidebar />
        <SettingsSectionsList @logout="logout" />
      </div>
    </div>
    <div class="right">
      <SettingsPanel />
    </div>
  </div>
</template>

<style scoped>
.settings-layout {
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