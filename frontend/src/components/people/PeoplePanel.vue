<script setup>
  import PeopleTabs from "./PeopleTabs.vue";
  import PeopleList from "./PeopleList.vue";
  import { useSocketStore } from "@/stores/socket"
  import { ref, computed } from "vue";
  import { onMounted } from "vue";
  import { watch } from "vue";


  const socketStore = useSocketStore();
  
  const activeTab = ref("contacts");

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

</script>

<template>
  <div class="panel">
    <PeopleTabs 
      :activeTab="activeTab"
      @change-to-tab="handleChangeTab"
    />

    <PeopleList 
      :people="peopleToShow"
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