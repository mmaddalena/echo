<script setup>
    import { ref } from "vue";

    const text = ref("");
</script>

<template>
  <div class="chat-input">
    <div class="main">
      <input
        v-model="text"
        placeholder="Escribe un mensaje..."
      />
      <button>➤</button>
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
  padding: 0.5rem 1rem 0.5rem 2rem;
  display: flex;
  justify-content: space-between;
  background: var(--bg-input);
  border-radius: 3rem;
}
input {
  height: 5rem;
  border: none;
  background: none;
  color: var(--text-main);
}
button {
  background-color: var(--msg-out);
  border: none;
  border-radius: 50%;
  width: 5rem;
  height: 5rem;
  color: white;
}
</style>
