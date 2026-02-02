<script setup>
  import { computed, ref } from 'vue'
  import PeopleListItem from "./PeopleListItem.vue";
  import IconSearch from '../icons/IconSearch.vue';

  const emit = defineEmits(['open-chat', "open-person"])

  const props = defineProps({
    people: {
      type: Array,
      required: true
    }
  })

  const text = ref("")

  function getPersonInfo(personId){
    emit("open-person", personId);
  }

</script>

<template>
  <div class="people-list">
    <div class="search">
      <div class="main">
        <input
          v-model="text"
          placeholder="Buscar"
          @keydown.enter="send"
        />
        <button @click="send">
          <IconSearch class="icon"/>
        </button>
      </div>
    </div>
    <PeopleListItem 
      v-for="person in people"
      :key="person.id"
      :person="person"
      @get-person-info="getPersonInfo"
    />
  </div>
</template>

<style scoped>
.people-list {
  flex: 1;
  background: var(--bg-peoplelist-panel);
  flex-direction: column;
  padding: 0 1rem;
}
.search {
  display: flex;
  gap: 1rem;
  justify-content: center;
  background-color: var(--bg-chatlist-hover);
  justify-content: space-between;
  border-radius: 2rem;
  padding: 0.5rem 0.5rem 0.5rem 1.5rem;
  align-items: center;
  margin: 2rem 3rem;
  flex: 1;
}
.main {
  display: flex;
  flex: 1;
}
input, button {
  all: unset;
}
input {
  flex: 1;
}
button {
  height: 3rem;
  width: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--bg-main);
  border-radius: 50%;
  cursor: pointer;
}
.icon {
  height: 1.75rem;
}
</style>
