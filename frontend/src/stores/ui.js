import { defineStore } from "pinia"

export const useUIStore = defineStore("ui", {
  state: () => ({
    leftPanel: "chats", // 'chats' | 'people'
  }),
  actions: {
    showChats() {
      this.leftPanel = "chats"
    },
    showPeople() {
      this.leftPanel = "people"
    },
  },
})
