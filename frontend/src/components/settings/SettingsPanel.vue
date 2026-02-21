<script setup>
  import ProfileSettings from "@/components/settings/sections/ProfileSettings.vue";
  import PrivacySettings from "@/components/settings/sections/PrivacySettings.vue";
  import NotificationsSettings from "@/components/settings/sections/NotificationsSettings.vue";
</script>

<template>
  <div class="settings-scroll">
    <section id="profile">
      <ProfileSettings />
    </section>

    <!-- <section id="privacy">
      <PrivacySettings />
    </section>

    <section id="notifications">
      <NotificationsSettings />
    </section> -->

    <button
      class="logout"
      @click="$emit('logout')"
    >
      Cerrar sesión
    </button>
</div>

</template>

<style scoped>
.settings-scroll {
  height: 100%;
  overflow-y: auto;
  scroll-behavior: smooth;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  
}

.logout {
  all: unset;
  
  padding: 1rem 1.6rem;
  margin: 0 1rem;
  cursor: pointer;
  font-size: 1.4rem;
  color: var(--text-main);
  border-radius: 1rem;
  transition: "background" 0.15s ease, color 0.15s ease;

  margin-top: auto;
  margin-bottom: 1rem;
  color: var(--text-main-light);
  background-color: var(--bg-logout);
  width: fit-content;
}
.logout:hover {
  background: rgb(182, 75, 75);
}

</style>