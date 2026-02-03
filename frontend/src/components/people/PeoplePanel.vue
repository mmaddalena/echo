<script setup>
  import PeopleTabs from "./PeopleTabs.vue";
  import PeopleList from "./PeopleList.vue";
  import PersonInfoPanel from "./PersonInfoPanel.vue";
  import PeopleSearchBar from "./PeopleSearchBar.vue";
  import { useSocketStore } from "@/stores/socket"
  import { storeToRefs } from "pinia";
  import { ref, computed } from "vue";
  import { onUnmounted } from "vue";
  import { watch } from "vue";

  const socketStore = useSocketStore();
  
  const activeTab = ref("contacts");
  const { openedPersonInfo } = storeToRefs(socketStore);

  const contactSearchText = ref(null)

  const filteredContacts = computed(() => {
    if (!contactSearchText.value) return socketStore.contacts
    if (!socketStore.contacts) return []

    const q = contactSearchText.value.toLowerCase().trim()

    return socketStore.contacts.filter(c =>
      c.username.toLowerCase().includes(q) ||
      c.name?.toLowerCase().includes(q) ||
      c.contact_info?.nickname?.toLowerCase().includes(q)
    )
  })

  const peopleToShow = computed(() => {
    if (activeTab.value === "contacts") {
      return filteredContacts.value ?? []
    }
    return socketStore.peopleSearchResults ?? []
  })

  function handleChangeTab(newTab) {
    activeTab.value = newTab;
  }

  watch(
    () => activeTab.value,
    (tab) => {
      console.log(`La tab activa es: ${tab}`)
      socketStore.deletePeopleSearchResults()
      contactSearchText.value = null;
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
    socketStore.deletePersonInfo();
    contactSearchText.value = null;
    socketStore.deletePeopleSearchResults();
  }

  onUnmounted(() => {
    closePersonInfoPanel()
  });




  function handleOpenChat(chatId) {
    socketStore.openChat(chatId);
  }

  function searchPeople(input){
    if (activeTab.value === "people")
      socketStore.searchPeople(input);
    else if (activeTab.value === "contacts")
      contactSearchText.value = input;
  }

</script>

<template>
  <div class="panel">
    <PeopleTabs 
      v-if="openedPersonInfo == null"
      :activeTab="activeTab"
      @change-to-tab="handleChangeTab"
    />

    <PeopleSearchBar
      v-if="openedPersonInfo == null"
      @search-people="searchPeople"
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