<script setup>
  import IconContacts from '../icons/IconContacts.vue';
  import IconThemeMode from '../icons/IconThemeMode.vue';
  import IconSettings from '../icons/IconSettings.vue';
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
        <IconThemeMode class="icon" variant="light"/>
      </button>
      <button>
        <IconSettings class="icon"/>
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
  fill: var(--text-main);
}
.outline {
  stroke: var(--text-main);
  fill: none;
}
</style>
