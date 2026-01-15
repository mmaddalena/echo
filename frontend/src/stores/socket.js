import { defineStore } from "pinia";
import { ref } from "vue";

export const useSocketStore = defineStore("socket", () => {
  const socket = ref(null);
  const userInfo = ref(null);
  const chats = ref([]);
  const chatsInfo = ref({});
  const activeChatId = ref(null);


  function connect(token) {
    if (socket.value) return; // ya conectado

    socket.value = new WebSocket(`ws://localhost:4000/ws?token=${token}`);

    socket.value.onopen = () => {
      console.log("WS conectado");
    };

    socket.value.onmessage = (event) => {
      const payload = JSON.parse(event.data);

      if (payload.type === "user_info") {
        userInfo.value = payload.user;
        chats.value = payload.last_chats ?? [];
      }
      else if (payload.type === "chat_info") {
        console.log("chat_info recibido:", payload.chat);
        const chat = payload.chat;

        chatsInfo.value = {
          ...chatsInfo.value,
          [chat.id]: chat
        };
        activeChatId.value = chat.id;

      } else if (payload.type === "new_message") {
        
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
    chats.value = [];
    chatsInfo.value = {};
    activeChatId.value = null;
  }

  function send(data) {
    if (socket.value?.readyState === WebSocket.OPEN) {
      socket.value.send(JSON.stringify(data));
    }else{
      console.error("El socket no está abierto")
    }
  }

  function openChat(chatId) {
    activeChatId.value = chatId;

    if (!chatsInfo.value[chatId]) {
      send({
        type: "open_chat",
        chat_id: chatId
      });
    }
  }

  return {
    socket,
    userInfo,
    chats,
    chatsInfo,
    activeChatId,
    connect,
    disconnect,
    send,
    openChat
  };
});
