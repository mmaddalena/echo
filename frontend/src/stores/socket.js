import { defineStore } from "pinia";
import { ref } from "vue";
import { generateId } from '@/utils/idGenerator'

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

      const savedChatId = sessionStorage.getItem("activeChatId");
        if (savedChatId) {
          activeChatId.value = savedChatId;
          send({
            type: "open_chat",
            chat_id: savedChatId
          });
        }
		};
    

		socket.value.onmessage = (event) => {
			const payload = JSON.parse(event.data);

      if (payload.type === "user_info") {
        userInfo.value = payload.user;
        chats.value = payload.last_chats ?? [];
      }
      else if (payload.type === "chat_info") {
        const chat = payload.chat;

        const normalizedMessages = chat.messages.map(m => ({
          ...m,
          front_msg_id: generateId(),
        }))

        chatsInfo.value = {
          ...chatsInfo.value,
          [chat.id]: {
            ...chat,
            messages: normalizedMessages
          }
        };
        activeChatId.value = chat.id;

      } else if (payload.type === "new_message") {
        const msg = payload.message;
        const chatId = msg.chat_id;
        
        // Actualizo la lista de chats
        chats.value = chats.value.map(chat => {
          if (chat.id !== chatId) return chat

          const isIncoming = msg.user_id !== userInfo.value.id

          return {
            ...chat,
            last_message: {
              type: isIncoming ? "incoming" : "outgoing",
              content: msg.content,
              state: msg.state,
              time: msg.time
            },
            unread_messages: isIncoming
              ? chat.unread_messages + 1
              : chat.unread_messages
          }
        })


        // Ahora sí, actualizo la caché de chatsInfo
        if (msg.user_id == userInfo.value.id) {
          // El mensaje es outgoing...
          const index = chatsInfo.value[chatId].messages.findIndex(m => m.front_msg_id === msg.front_msg_id)
          if(index !== -1){// Por safety, debería entrar
            Object.assign(chatsInfo.value[chatId].messages[index], msg);
          }
        }else{
          // El mensaje es incoming...
          const normalizedMsg = {
            ...msg,
            front_msg_id: msg.front_msg_id ?? generateId(),
          }
          
          const chat = chatsInfo.value[chatId]
          
          if (chat) {
            chatsInfo.value = {
              ...chatsInfo.value,
              [chatId]: {
                ...chat,
                messages: [...chat.messages, normalizedMsg]
              }
            }
          }
        }
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
    sessionStorage.clear()
  }

	function send(data) {
		if (socket.value?.readyState === WebSocket.OPEN) {
			socket.value.send(JSON.stringify(data));
		} else {
			console.error("El socket no está abierto");
		}
	}

  function openChat(chatId) {
    activeChatId.value = chatId;
    sessionStorage.setItem("activeChatId", chatId)

    if (!chatsInfo.value[chatId]) {
      send({
        type: "open_chat",
        chat_id: chatId
      });
    }
  }

  function sendMessage(front_msg) {
    const chat_id = front_msg.chat_id
    const chat = chatsInfo.value[chat_id]

    if (chat) {
      chatsInfo.value = {
        ...chatsInfo.value,
        [chat_id]: {
          ...chat,
          messages: [...chat.messages, front_msg]
        }
      }
    }

    send({
      type: "send_message",
      msg: front_msg
    })


    // const chat_id = front_msg.chat_id
    // // Meto el mensaje de front a los mensajes del chatInfo actual
    // if(chatsInfo.value[chat_id]){
    //   chatsInfo.value[chat_id].messages.push(front_msg)
    // }
    // // Mando el mensaje al back
    // send({
    //   type: "send_message",
    //   msg: front_msg
    // });
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
    openChat,
    sendMessage
  };
});
