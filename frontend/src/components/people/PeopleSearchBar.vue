<script setup>
  import IconSearch from '../icons/IconSearch.vue';
  import { ref } from 'vue'

  const emit = defineEmits(["search-people"])

  const text = ref("")

  function searchPeople(input){
    emit("search-people", input);
  }
</script>

<template>
  <div class="all">
    <div class="search">
      <div class="main">
        <input
          v-model="text"
          placeholder="Buscar"
          @keydown.enter="searchPeople(text)"
        />
        <button @click="searchPeople(text)">
          <IconSearch class="icon" />
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.all {
  background-color: var(--bg-chatlist-panel);;
}
.search {
  display: flex;
  height: 4rem;
  gap: 1rem;
  justify-content: center;
  background-color: var(--bg-chatlist-hover);
  justify-content: space-between;
  border-radius: 2rem;
  padding: 0.5rem 0.5rem 0.5rem 1.5rem;
  align-items: center;
  margin: 2rem 3rem;
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