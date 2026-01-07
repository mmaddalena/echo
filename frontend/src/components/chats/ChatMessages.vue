<script setup>
  import ChatMessage from "./ChatMessage.vue";
</script>

<template>
  <div class="chat-messages">
    <ChatMessage text="Hola bro" type="incoming" time="9:25" />
    <ChatMessage text="Todo bien?" type="incoming" time="9:25" />
    <ChatMessage text="Sí, vos?" type="outgoing" time="9:26" />
    <ChatMessage text="Sí todo tranqui" type="incoming" time="9:27" />
    <ChatMessage text="Cuchá" type="incoming" time="9:27" />
    <ChatMessage text="Acordate que tenemos que estar a las 10:00" type="incoming" time="9:27" />
    <ChatMessage text="Dale amigo sisi" type="outgoing" time="9:28" />
    <ChatMessage text="Igual ya había avisado en el grupo" type="outgoing" time="9:29" />
    
    <ChatMessage text="Hola bro" type="incoming" time="9:25" />
    <ChatMessage text="Todo bien?" type="incoming" time="9:25" />
    <ChatMessage text="Sí, vos?" type="outgoing" time="9:26" />
    <ChatMessage text="Sí todo tranqui" type="incoming" time="9:27" />
    <ChatMessage text="Cuchá" type="incoming" time="9:27" />
    <ChatMessage text="Acordate que tenemos que estar a las 10:00" type="incoming" time="9:27" />
    <ChatMessage text="Dale amigo sisi" type="outgoing" time="9:28" />
    <ChatMessage text="Igual ya había avisado en el grupo" type="outgoing" time="9:29" />
    
    <ChatMessage text="Hola bro" type="incoming" time="9:25" />
    <ChatMessage text="Todo bien?" type="incoming" time="9:25" />
    <ChatMessage text="Sí, vos?" type="outgoing" time="9:26" />
    <ChatMessage text="Sí todo tranqui" type="incoming" time="9:27" />
    <ChatMessage text="Cuchá" type="incoming" time="9:27" />
    <ChatMessage text="Acordate que tenemos que estar a las 10:00" type="incoming" time="9:27" />
    <ChatMessage text="Dale amigo sisi" type="outgoing" time="9:28" />
    <ChatMessage text="Igual ya había avisado en el grupo" type="outgoing" time="9:29" />

    <ChatMessage text="Hola bro" type="incoming" time="9:25" />
    <ChatMessage text="Todo bien?" type="incoming" time="9:25" />
    <ChatMessage text="Sí, vos?" type="outgoing" time="9:26" />
    <ChatMessage text="Sí todo tranqui" type="incoming" time="9:27" />
    <ChatMessage text="Cuchá" type="incoming" time="9:27" />
    <ChatMessage text="Acordate que tenemos que estar a las 10:00" type="incoming" time="9:27" />
    <ChatMessage text="Dale amigo sisi" type="outgoing" time="9:28" />
    <ChatMessage text="Igual ya había avisado en el grupo" type="outgoing" time="9:29" />
  </div>
</template>

<style scoped>
.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 5px;
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
  background-color: var(--bg-chat);
}
</style>
