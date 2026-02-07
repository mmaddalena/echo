<script setup>
  import PeopleListItem from "./PeopleListItem.vue";

  const emit = defineEmits(["open-person"])

  const props = defineProps({
    people: {
      type: Array,
      required: true
    }
  })

  function getPersonInfo(personId){
    emit("open-person", personId);
  }

  

</script>

<template>
  <TransitionGroup
    name="people"
    tag="div"
    class="people-list"
  >
    <PeopleListItem 
      v-for="person in props.people"
      :key="person.id"
      :person="person"
      @get-person-info="getPersonInfo"
    />
  </TransitionGroup>

</template>

<style scoped>
.people-list {
  flex: 1;
  background: var(--bg-peoplelist-panel);
  flex-direction: column;
  padding: 0 1rem;
}

.people-move {
  transition: transform 200ms ease;
}
.people-enter-active {
  transition: all 180ms ease-out;
}
.people-enter-from {
  opacity: 0;
  transform: translateY(-8px);
}
.people-enter-to {
  opacity: 1;
  transform: translateY(0);
}


</style>
