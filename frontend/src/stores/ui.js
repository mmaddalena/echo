import { defineStore } from "pinia"

export const useUIStore = defineStore("ui", {
  state: () => ({
    leftPanel: "chats",
    selectedChat: null,
    selectedPerson: null,
  }),
  actions: {
    showChats() {
      this.leftPanel = "chats"
      this.selectedChat = null
      this.selectedPerson = null
    },
    showPeople() {
      this.leftPanel = "people"
    },
    showChatInfo(chat) {
      this.selectedChat = chat
      this.leftPanel = "chat-info"
    },
    showPersonInfo(member) {
      this.selectedPerson = member
      this.leftPanel = "person-info"
    }
  },
})
