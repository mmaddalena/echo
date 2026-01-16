<script setup>
  import { ref } from "vue";

  const text = ref("");

  import IconSend from '../icons/IconSend.vue';
</script>

<template>
  <div class="chat-input">
    <div class="main">
      <input
        v-model="text"
        placeholder="Escribe un mensaje..."
      />
      <button>
        <IconSend />
      </button>
    </div>
  </div>
</template>

<style scoped>
.chat-input {
  height: fit-content;
  background-color: var(--bg-chat);
  padding: 0 2rem 2rem 2rem;
}
.main {
  height: fit-content;
  padding: 0rem 1rem 0rem 2rem;
  display: flex;
  justify-content: space-between;
  background: var(--bg-input);
  border-radius: 3rem;
  align-items: center;
}
input {
  flex: 1;
  height: 5rem;
  border: none;
  background: none;
  color: var(--text-main);
  outline: none;
  font-size: 1.5rem;
}
button {
  background-color: var(--msg-out);
  border: none;
  border-radius: 50%;
  width: 4rem;
  height: 4rem;
  color: white;
}
</style>
