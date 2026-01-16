<script setup>
  import IconSearch from '../icons/IconSearch.vue';
  import IconOptsMenu from '../icons/IconOptsMenu.vue';
import { computed } from 'vue';

  const props = defineProps({
    chatInfo: {
      type: Object,
      default: null
    }
  })

  const membersStr = computed(() => {
    return props.chatInfo?.members
      ?.map(m => m.username)
      .join(', ') ?? ''
  })
</script>

<template>
  <header v-if="chatInfo" class="chat-header">
    <div class="user_info">
      <img class="avatar" />
      <div class="texts">
        <p class="name">{{ chatInfo.name }}</p>
        <span class="status">
          <p v-if="chatInfo.type == 'private'">{{ chatInfo.status }}</p>
          <p v-else>{{ membersStr }}</p>
        </span>
      </div>
    </div>
    <div class="opts_icons">
      <IconSearch class="icon" />
      <IconOptsMenu class="icon" />
    </div>
  </header>
</template>

<style scoped>
.chat-header {
  background-color: var(--bg-chat-header);
  height: 7rem;
  padding: 1.5rem 1.6rem;
  display: flex;
  box-sizing: content-box;
  align-items: center;
  justify-content: space-between;
  border-bottom: 0.3rem solid rgba(255,255,255,0.05);
}
.user_info {
  display: flex;
  gap: 2rem;
  align-items: center;
}
.avatar {
  background-color: aqua;
  height: 5rem;
  width: 5rem;
  border-radius: 50%;
}
.name {
  color: var(--text-main);
  font-size: 2.2rem;
  font-weight: bold;
}
.status {
  font-size: 1.5REM;
  color: var(--text-muted);
}
.opts_icons {
  display: flex;
  gap: 2rem;
}
.icon {
  height: 2.5rem;
  color: var(--text-main);
  fill: var(--text-main);
}
</style>
