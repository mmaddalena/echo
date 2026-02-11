import { defineStore } from "pinia"

export const useUIStore = defineStore("ui", {
  state: () => ({
    leftPanel: "chats",
    selectedChatId: null,
    selectedPerson: null,
  }),
  actions: {
    showChats() {
      this.leftPanel = "chats"
      this.selectedChatId = null
      this.selectedPerson = null
    },
    showPeople() {
      this.leftPanel = "people"
    },
    showChatInfo(chat) {
      this.selectedChatId = chat.id
      this.leftPanel = "chat-info"
    },
    showPersonInfo(member) {
      this.selectedPerson = member
      this.leftPanel = "person-info"
    }
  },
})
