<script setup>
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <div>
    <h1>Echo Front</h1>
    <p>Conectando con el backend...</p>
    <a href="https://github.com/rochimgg/echo" target="_blank">
      <img src="/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
    </a>
  </div>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
</style>
