<script setup>
  import { computed } from "vue";
  import { onMounted } from "vue";
  import { useRouter } from "vue-router";
  import { useRoute } from 'vue-router';
  import { useSocketStore } from "@/stores/socket";

  import IconContacts from '../icons/IconContacts.vue';
  import IconThemeMode from '../icons/IconThemeMode.vue';
  import IconSettings from '../icons/IconSettings.vue';
  import IconChats from '../icons/IconChats.vue';

  const router = useRouter();
  const route = useRoute();
  const socketStore = useSocketStore();
  const user = computed(() => socketStore.userInfo);

  onMounted(() => {
    const token = sessionStorage.getItem("token");
    if (token){
      socketStore.connect(token);
    }
  });
</script>

<template>
  <aside class="sidebar">
    <div class="perfil-opts">
      <button class="perfil"></button>
      <button>
        <IconContacts class="icon outline"/>
      </button>
    </div>
    <div class="config_opts">
      <button>
        <IconThemeMode class="icon icon-light" variant="light"/>
      </button>
      <button>
        <IconThemeMode class="icon icon-dark" variant="dark"/>
      </button>

      <button 
        v-if="route.name === 'chats'"
        @click="router.push('/settings')"
      >
        <IconSettings class="icon" />
      </button>
      <button 
        v-else-if="route.name === 'settings'"
        @click="router.push('/chats')"
      >
        <IconChats class="icon" />
      </button>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 9rem;
  height: 100%;
  background: none;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  flex-shrink: 0;
  align-items: center;
  padding: 16px 0;
  gap: 20px;
}
button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
}
.perfil-opts {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}
.perfil {
  height: 5rem;
  width: 5rem;
  border-radius: 50%;
  background-color: cyan;
}
.config_opts {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}
.icon {
  height: 4rem;
  color: var(--text-main);
}
.icon-light {
  color: var(--msg-in);
}
.icon-dark{
  color: var(--msg-out);
}
.outline {
  stroke: var(--text-main);
  fill: none;
}
</style>
