import { defineStore } from "pinia";
import { ref } from "vue";
import { generateId } from "@/utils/idGenerator";

export const useSocketStore = defineStore("socket", () => {
	const socket = ref(null);
	const userInfo = ref(null);
	const chats = ref([]);
	const chatsInfo = ref({});
	const activeChatId = ref(null);
	const contacts = ref(null);
	const openedPersonInfo = ref(null);
	const peopleSearchResults = ref(null);
	const pendingPrivateChat = ref(null);
	const pendingMessage = ref(null)


	function connect(token) {
		if (socket.value) return; // ya conectado

		const protocol = location.protocol === "https:" ? "wss" : "ws";
		socket.value = new WebSocket(
			// `${protocol}://${location.host}/ws?token=${token}`,
			`http://localhost:4000/ws?token=${token}`,
		);

		socket.value.onopen = () => {
			console.log("WS conectado");

			const savedChatId = sessionStorage.getItem("activeChatId");
			if (savedChatId) {
				activeChatId.value = savedChatId;
				send({
					type: "open_chat",
					chat_id: savedChatId,
				});
			}
		};

		socket.value.onmessage = (event) => {
			const payload = JSON.parse(event.data);

			if (payload.type === "user_info") {
				dispatch_user_info(payload);
			} else if (payload.type === "chat_info") {
				dispatch_chat_info(payload);
			} else if (payload.type === "new_message") {
				dispatch_new_message(payload);
			} else if (payload.type === "chat_read") {
				dispatch_chat_read(payload);
			} else if (payload.type === "messages_delivered") {
				markMessagesDelivered(payload.message_ids);
			} else if (payload.type === "contacts") {
				console.log("CONTACTS RECIBIDOS:", payload.contacts);
				contacts.value = payload.contacts;
				// const peopleStore = usePeopleStore()
				// peopleStore.setContacts(payload.contacts ?? [])
			} else if(payload.type === "person_info") {
				console.log(`LLegó la info de la persona ${payload.person_info.username}`)
				openedPersonInfo.value = payload.person_info
			} else if (payload.type === "search_people_results"){
				console.log(`LLegaron los resultados de la busqueda de personas: ${payload.search_people_results}`)
				peopleSearchResults.value = payload.search_people_results
			} else if (payload.type === "private_chat_created") {
				console.log(`Se creó el chat privado con id: ${payload.chat.id}`);
				// Meto la info en la caché de los chats
				chats.value = [payload.chat_item, ...chats.value]
				dispatch_chat_info(payload);
				// Mando el mensaje pendiente
				const msg = {...pendingMessage.value,
					chat_id: payload.chat.id
				}
				sendMessage(msg);
				// Seteo todo lo pending en null, ya que ya no hay nada pendiente
					pendingPrivateChat.value = null;
					pendingMessage.value = null;
			}
		};

		socket.value.onerror = () => {
			console.error("Error en WS");
		};
	}

	function dispatch_user_info(payload) {
		userInfo.value = payload.user;
		chats.value = payload.last_chats ?? [];
	}
	function dispatch_chat_info(payload) {
		const chat = payload.chat;

		const normalizedMessages = chat.messages.map((m) => ({
			...m,
			front_msg_id: generateId(),
		}));

		chatsInfo.value = {
			...chatsInfo.value,
			[chat.id]: {
				...chat,
				messages: normalizedMessages,
			},
		};
		activeChatId.value = chat.id;

		// Seteamos como read los incoming
		setReadIncomingMessages(chat.id);

		// Actualizamos el ChatListItem
		const lastMsg = getLastMessage(chat);

		updateChatListItem(lastMsg);
	}
	function dispatch_new_message(payload) {
		const msg = payload.message;
		const chatId = msg.chat_id;

		// Actualizo la lista de chats
		chats.value = chats.value.map((chat) => {
			if (chat.id !== chatId) return chat;

			const isIncoming = msg.user_id !== userInfo.value.id;
			console.log(msg.avatar_url);
			return {
				...chat,
				last_message: {
					type: isIncoming ? "incoming" : "outgoing",
					content: msg.content,
					state: msg.state,
					time: msg.time,
					avatar_url: msg.avatar_url,
					format: msg.format,
					filename: msg.filename,
				},
				unread_messages: isIncoming
					? chat.unread_messages + 1
					: chat.unread_messages,
			};
		});

		// Ahora sí, actualizo la caché de chatsInfo
		if (msg.user_id == userInfo.value.id) {
			// El mensaje es outgoing...
			const index = chatsInfo.value[chatId].messages.findIndex(
				(m) => m.front_msg_id === msg.front_msg_id,
			);

			if (index !== -1) {
				// Por safety nomás, debería entrar sí o sí
				Object.assign(chatsInfo.value[chatId].messages[index], msg);
			}
			console.log(`Mensaje outgoing recibido: `, msg);
		} else {
			// El mensaje es incoming...
			const normalizedMsg = {
				...msg,
				front_msg_id: msg.front_msg_id ?? generateId(),
			};

			const chat = chatsInfo.value[chatId];

			if (chat) {
				chatsInfo.value = {
					...chatsInfo.value,
					[chatId]: {
						...chat,
						messages: [...chat.messages, normalizedMsg],
					},
				};
			}

			// Si tengo este chat abierto
			if (normalizedMsg.chat_id == activeChatId.value) {
				// Notifico al back que leí el mensaje
				send({
					type: "chat_messages_read",
					chat_id: chatId,
				});

				// Seteamos como read los incoming
				setReadIncomingMessages(chatId);

				// Actualizamos el ChatListItem también
				updateChatListItem(normalizedMsg);
			}
		}
	}
	function dispatch_chat_read(payload) {
		const chat_id = payload.chat_id;
		const chat = chatsInfo.value[chat_id];

		if (!chat || chat.type != "private") return;

		chatsInfo.value = {
			...chatsInfo.value,
			[chat_id]: {
				...chat,
				messages: chat.messages.map((m) =>
					m.type === "outgoing" && m.state !== "read"
						? { ...m, state: "read" }
						: m,
				),
			},
		};

		const lastMsg = getLastMessage(chatsInfo.value[chat_id]);
		if (lastMsg) {
			updateChatListItem({ ...lastMsg, state: "read" });
		}
	}

	function disconnect() {
		if (socket.value) {
			send({ type: "logout" });
			socket.value.close();
		}
		socket.value = null;
		userInfo.value = null;
		chats.value = [];
		chatsInfo.value = {};
		activeChatId.value = null;
		contacts.value = null;
		openedPersonInfo.value = null;
		peopleSearchResults.value = null;
		pendingPrivateChat.value = null;
		pendingMessage.value = null;
		sessionStorage.clear();
	}

	function send(data) {
		if (socket.value?.readyState === WebSocket.OPEN) {
			socket.value.send(JSON.stringify(data));
		} else {
			console.error("El socket no está abierto");
		}
	}

	function openChat(chatId) {
		pendingPrivateChat.value = null;
		pendingMessage.value = null;

		activeChatId.value = chatId;
		sessionStorage.setItem("activeChatId", chatId);

		const hasCache = !!chatsInfo.value[chatId];

		console.log(`HasCache: ${hasCache}`);
		// Si no tenemos la info del chat se la pedimos al back
		if (!hasCache) {
			send({
				type: "open_chat",
				chat_id: chatId,
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
			chat_id: chatId,
		});
	}

	function sendMessage(front_msg) {
		const chat_id = front_msg.chat_id;
		const chat = chatsInfo.value[chat_id];

		if (chat) {
			chatsInfo.value = {
				...chatsInfo.value,
				[chat_id]: {
					...chat,
					messages: [...chat.messages, front_msg],
				},
			};
		}

		send({
			type: "send_message",
			msg: front_msg,
		});
	}

	function getLastMessage(chat) {
		return chat.messages.reduce((latest, m) => {
			if (!latest) return m;
			return new Date(m.time) > new Date(latest.time) ? m : latest;
		}, null);
	}

	function updateChatListItem(msg) {
		if (!msg) return;

		chats.value = chats.value.map((chat) =>
			chat.id === msg.chat_id
				? {
						...chat,
						unread_messages: 0,
						last_message: msg,
					}
				: chat,
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
					messages: chat.messages.map((m) =>
						m.type === "incoming" && m.state !== "read"
							? { ...m, state: "read" }
							: m,
					),
				},
			};
		}
	}

	function markMessagesDelivered(messageIds) {
		Object.keys(chatsInfo.value).forEach((chatId) => {
			const chat = chatsInfo.value[chatId];
			if (!chat) return;

			// Actualizamos los mensajes
			const messages = chat.messages.map((m) => {
				const msgId = m.id ?? m.front_msg_id;
				return messageIds.includes(msgId) && m.state === "sent"
					? { ...m, state: "delivered" }
					: m;
			});

			// Reemplazamos en chatsInfo
			chatsInfo.value = {
				...chatsInfo.value,
				[chatId]: { ...chat, messages },
			};

			// Actualizamos last_message si es uno de los que cambió
			const lastMsg = messages[messages.length - 1];
			if (lastMsg && messageIds.includes(lastMsg.id ?? lastMsg.front_msg_id)) {
				updateChatListItem(lastMsg);
			}
		});
	}

	function updateAvatar(avatarUrl) {
		if (!userInfo.value) return;

		userInfo.value = {
			...userInfo.value,
			avatar_url: avatarUrl,
		};
	}

	function requestContactsIfNeeded() {
		if (contacts.value !== null) {
			console.log(
				"El ref de contacts del request no es null, por lo que no le pedimos nada al back",
			);
			return;
		}
		console.log(
			"El ref de contacts del request es null, por lo que le pedimos los contactos al back",
		);
		send({ type: "get_contacts" });
	}

	function getPersonInfo(personId) {
		console.log(`Se quiere pedir la info de la persona cuyo id es ${personId}`)
		send({
			type: "get_person_info",
			person_id: personId
		})
	}

	function deletePersonInfo() {
		openedPersonInfo.value = null;
	}

	function deletePeopleSearchResults() {
		peopleSearchResults.value = null;
	}

	function searchPeople(input) {
		send({
			type: "search_people",
			input: input
		})
	}

	function openPendingPrivateChat(personInfo) {
		console.log("Se abre un chat que no está creado en el back")
		pendingPrivateChat.value = personInfo.value
		activeChatId.value = null
		sessionStorage.removeItem("activeChatId")
	}


	function createPrivateChatAndSendMessage(front_pending_msg) {
		console.log(`Queremos crear un chat para mandar despues '${front_pending_msg.content}'`)
		pendingMessage.value = front_pending_msg

		send({
			type: "create_private_chat",
			user_id: pendingPrivateChat.value.id
		})
		console.log(`Se hizo el send`)
	}


	return {
		socket,
		userInfo,
		chats,
		chatsInfo,
		activeChatId,
		contacts,
		openedPersonInfo,
		peopleSearchResults,
		pendingPrivateChat,
		pendingMessage,
		connect,
		disconnect,
		send,
		openChat,
		sendMessage,
		updateAvatar,
		requestContactsIfNeeded,
		getPersonInfo,
		deletePersonInfo,
		deletePeopleSearchResults,
		searchPeople,
		openPendingPrivateChat,
		createPrivateChatAndSendMessage
	};
});
