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

        // Seteamos como read los incoming
        setReadIncomingMessages(chat.id);

        // Actualizamos el ChatListItem
        const lastMsg = getLastMessage(chat);

        updateChatListItem(lastMsg)

      } 
      else if (payload.type === "new_message") {
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

          if(index !== -1){// Por safety nomás, debería entrar sí o sí
            Object.assign(chatsInfo.value[chatId].messages[index], msg);
          }
          console.log(`Mensaje outgoing recibido: `, msg)
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

          // Si tengo este chat abierto
          if(normalizedMsg.chat_id == activeChatId.value) {
            // Notifico al back que leí el mensaje 
            send({
              type: "chat_messages_read",
              chat_id: chatId
            });

            // Seteamos como read los incoming
            setReadIncomingMessages(chatId)

            // Actualizamos el ChatListItem también
            updateChatListItem(normalizedMsg)
          }
        }
      }
      else if (payload.type === "chat_read") {
        const chat_id = payload.chat_id;
        const chat = chatsInfo.value[chat_id];

        if (!chat || chat.type != "private") return;        

        chatsInfo.value = {
          ...chatsInfo.value,
          [chat_id]: {
            ...chat,
            messages: chat.messages.map(m =>
              m.type === "outgoing" && m.state !== "read"
              ? { ...m, state: "read" }
              : m
            )
          }
        };

        const lastMsg = getLastMessage(chatsInfo.value[chat_id]);
        if (lastMsg) {
          updateChatListItem({ ...lastMsg, state: "read" });
        }

      }
      else if (payload.type === "messages_delivered") {
        markMessagesDelivered(payload.message_ids)
      }
    };

		socket.value.onerror = () => {
			console.error("Error en WS");
		};
	}

  function disconnect() {
    if (socket.value) {
      send({type: "logout"})
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

    const hasCache = !!chatsInfo.value[chatId];

    // Si no tenemos la info del chat se la pedimos al back
    if (!hasCache) {
      send({
        type: "open_chat",
        chat_id: chatId
      });
    }

    // Si no le pedimos al back, tenemos que actualizar el ChatListItem
    if (hasCache) {
      const lastMsg = getLastMessage(chatsInfo.value[chatId]);

      if (lastMsg) updateChatListItem(lastMsg);
    }

    // Le decimos al back que leímos los mensajes del chat
    send({
      type: "chat_messages_read",
      chat_id: chatId
    });
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

  function getLastMessage(chat) {
    return chat.messages.reduce((latest, m) => {
      if (!latest) return m;
      return new Date(m.time) > new Date(latest.time) ? m : latest;
    }, null);
  }
  
  function updateChatListItem(msg) {
    chats.value = chats.value.map(chat =>
      chat.id === msg.chat_id? { 
        ...chat, 
        unread_messages: 0,
        last_message: msg,
      }
        : chat
    );
  }

  function setReadIncomingMessages(chatId) {
    const hasCache = !!chatsInfo.value[chatId];
    if (hasCache) {
      const chat = chatsInfo.value[chatId];
      
      chatsInfo.value = {
        ...chatsInfo.value,
        [chatId]: {
          ...chat,
          messages: chat.messages.map(m =>
            m.type === "incoming" && m.state !== "read"
            ? { ...m, state: "read" }
            : m
          )
        }
      };
    }
  }

  function markMessagesDelivered(messageIds) {
    Object.keys(chatsInfo.value).forEach(chatId => {
      const chat = chatsInfo.value[chatId];
      if (!chat) return;

      // Actualizamos los mensajes
      const messages = chat.messages.map(m => {
        const msgId = m.id ?? m.front_msg_id;
        return messageIds.includes(msgId) && m.state === "sent"
          ? { ...m, state: "delivered" }
          : m;
      });

      // Reemplazamos en chatsInfo
      chatsInfo.value = {
        ...chatsInfo.value,
        [chatId]: { ...chat, messages }
      };

      // Actualizamos last_message si es uno de los que cambió
      const lastMsg = messages[messages.length - 1];
      if (lastMsg && messageIds.includes(lastMsg.id ?? lastMsg.front_msg_id)) {
        updateChatListItem(lastMsg);
      }
    });
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
