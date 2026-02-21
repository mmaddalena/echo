<script setup>
  import PeopleTabs from "./PeopleTabs.vue";
  import PeopleList from "./PeopleList.vue";
  import PersonInfoPanel from "./PersonInfoPanel.vue";
  import PeopleSearchBar from "./PeopleSearchBar.vue";
  import { useSocketStore } from "@/stores/socket"
  import { useUIStore } from "@/stores/ui"
  import { storeToRefs } from "pinia";
  import { ref, computed, watch, onMounted, nextTick, onUnmounted } from "vue";

  const socketStore = useSocketStore();
  const uiStore = useUIStore();
  
  const activeTab = ref("contacts");
  const { openedPersonInfo } = storeToRefs(socketStore);
  const { contacts } = storeToRefs(socketStore);
  const { peopleSearchResults } = storeToRefs(socketStore);

  const contactSearchText = ref(null)

  const filteredContacts = computed(() => {
    if (!contactSearchText.value) return contacts.value

    const q = contactSearchText.value.toLowerCase().trim()

    return contacts.value.filter(c =>
      c.username.toLowerCase().includes(q) ||
      c.name?.toLowerCase().includes(q) ||
      c.contact_info?.nickname?.toLowerCase().includes(q)
    )
  })


  const peopleToShow = computed(() => {
    if (activeTab.value === "contacts") {
      return filteredContacts.value
    }
    return peopleSearchResults.value
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
    uiStore.showPersonInfo()
    socketStore.getPersonInfo(person_id)
  }

  function searchPeople(input){
    if (activeTab.value === "people")
      socketStore.searchPeople(input);
    else if (activeTab.value === "contacts")
      contactSearchText.value = input;
  }


  const searchBarRef = ref(null)
  onMounted(() => {
    searchBarRef.value?.focusInput()
  })
  watch(
    () => activeTab.value,
    () => {
      searchBarRef.value?.focusInput()
    }
  )

</script>

<template>
  <div class="panel">
    <PeopleTabs 
      v-if="openedPersonInfo == null"
      :activeTab="activeTab"
      @change-to-tab="handleChangeTab"
    />

    <PeopleSearchBar
      ref="searchBarRef"
      class="search-bar"
      v-if="openedPersonInfo == null"
      @search-people="searchPeople"
    />

    <PeopleList 
      v-if="openedPersonInfo == null"
      :people="peopleToShow"
      @open-person="getPersonInfo"
    />

    <!-- <PersonInfoPanel
      v-if="openedPersonInfo != null"
      :personInfo="openedPersonInfo"
      @close-person-info-panel="closePersonInfoPanel"
      @open-chat="handleOpenChat"
      @change-nickname="handleChangeNickname"
      @add-contact="handleAddContact"
      @delete-contact="handleDeleteContact"
    /> -->
  </div>
</template>

<style scoped>
.panel {
  display: flex;
  flex: 1;
  flex-direction: column;
}
.search-bar {
  padding: 2rem 3rem;
}
</style>