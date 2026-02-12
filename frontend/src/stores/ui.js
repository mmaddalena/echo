import { defineStore } from "pinia"

export const useUIStore = defineStore("ui", {
  state: () => ({
    leftPanel: "chats",
  }),
  actions: {
    showChats() {
      this.leftPanel = "chats"
    },
    showPeople() {
      this.leftPanel = "people"
    },
    showChatInfo() {
      this.leftPanel = "chat-info"
    }
  },
})
