import { defineStore } from "pinia";
import { ref } from "vue";

export const useSocketStore = defineStore("socket", () => {
  const socket = ref(null);
  const userInfo = ref(null);
  const chatInfo = ref(null);

  function connect(token) {
    if (socket.value) return; // ya conectado

    socket.value = new WebSocket(`ws://localhost:4000/ws?token=${token}`);

    socket.value.onopen = () => {
      console.log("WS conectado");
    };

    socket.value.onmessage = (event) => {
      const payload = JSON.parse(event.data);

      if (payload.type === "user_info") {
        userInfo.value = payload;
      }
      else if (payload.type === "chat_info") {
        chatInfo.value = payload.chat;
      }
    };

    socket.value.onerror = () => {
      console.error("Error en WS");
    };
  }

  function disconnect() {
    if (socket.value) {
      socket.value.close();
    }
    socket.value = null;
    userInfo.value = null;
    chatInfo.value = null;
  }

  function send(data) {
    if (socket.value?.readyState === WebSocket.OPEN) {
      socket.value.send(JSON.stringify(data));
    }else{
      console.error("El socket no está abierto")
    }
  }

  return {
    socket,
    userInfo,
    connect,
    disconnect,
    send
  };
});
