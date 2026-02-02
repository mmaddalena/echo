<script setup>
  import PeopleTabs from "./PeopleTabs.vue";
  import PeopleList from "./PeopleList.vue";
  import PersonInfoPanel from "./PersonInfoPanel.vue";
  import { useSocketStore } from "@/stores/socket"
  import { storeToRefs } from "pinia";
  import { ref, computed } from "vue";
  import { onUnmounted } from "vue";
  import { watch } from "vue";

  const socketStore = useSocketStore();
  
  const activeTab = ref("contacts");
  const { openedPersonInfo } = storeToRefs(socketStore);

  const peopleToShow = computed(() => {
    if (activeTab.value === "contacts") {
      return socketStore.contacts ?? []
    }
    return [] // después search results
  })

  function handleChangeTab(newTab) {
    activeTab.value = newTab;
  }

  watch(
    () => activeTab.value,
    (tab) => {
      console.log(`La tab activa es: ${tab}`)
    }
  )
  watch(
    () => socketStore.contacts,
    (val) => {
      console.log(`CONTACTS EN STORE DESDE EL PANEL: ${val}`)
    }
  )

  function getPersonInfo(person_id){ 
    socketStore.getPersonInfo(person_id)
  }

  function closePersonInfoPanel() {
    socketStore.deletePersonInfo()
  }

  onUnmounted(() => {
    closePersonInfoPanel()
  });

  function handleOpenChat(chatId) {
    socketStore.openChat(chatId);
  }

</script>

<template>
  <div class="panel">
    <PeopleTabs 
      v-if="openedPersonInfo == null"
      :activeTab="activeTab"
      @change-to-tab="handleChangeTab"
    />

    <PeopleList 
      v-if="openedPersonInfo == null"
      :people="peopleToShow"
      @open-person="getPersonInfo"
    />

    <PersonInfoPanel
      v-if="openedPersonInfo != null"
      :personInfo="openedPersonInfo"
      @close-person-info-panel="closePersonInfoPanel"
      @open-chat="handleOpenChat"
    />
  </div>
</template>

<style scoped>
.panel {
  display: flex;
  flex: 1;
  flex-direction: column;
}
</style>