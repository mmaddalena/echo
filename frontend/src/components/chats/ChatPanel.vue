<script setup>
import ChatTabs from "./ChatTabs.vue";
import ChatList from "./ChatList.vue";
import ChatInfoPanel from "./ChatInfoPanel.vue";
// import ChatSearchBar from "./ChatSearchBar.vue";
import { useSocketStore } from "@/stores/socket";
import { storeToRefs } from "pinia";
import { ref, computed } from "vue";
import { onUnmounted } from "vue";
import { watch } from "vue";

const socketStore = useSocketStore();

const activeTab = ref("all");
const { activeChatId } = storeToRefs(socketStore);
const { chats } = storeToRefs(socketStore);

const contactSearchText = ref(null);

const filteredChats = computed(() => {
	if (activeTab.value === "groups") {
		return chats.value.filter((chat) => chat.type === "group");
	}
	return chats.value;
});

function handleChangeTab(newTab) {
	activeTab.value = newTab;
}

watch(
	() => activeTab.value,
	(tab) => {
		console.log(`La tab activa es: ${tab}`);
		socketStore.deletePeopleSearchResults();
		contactSearchText.value = null;
	},
);
watch(
	() => socketStore.contacts,
	(val) => {
		console.log(`CONTACTS EN STORE DESDE EL PANEL: ${val}`);
	},
);

function getPersonInfo(person_id) {
	socketStore.getPersonInfo(person_id);
}

function closePersonInfoPanel() {
	socketStore.deletePersonInfo();
	contactSearchText.value = null;
	socketStore.deletePeopleSearchResults();
}

onUnmounted(() => {
	closePersonInfoPanel();
});

function searchChat(input) {
	if (activeTab.value === "people") socketStore.searchPeople(input);
	else if (activeTab.value === "contacts") contactSearchText.value = input;
}

function handleOpenChat(chatId) {
	socketStore.openChat(chatId);
}
</script>

<template>
	<div class="panel">
		<ChatTabs :activeTab="activeTab" @change-to-tab="handleChangeTab" />

		<!-- <ChatSearchBar v-if="activeChatId == null" @search-chat="searchChat" /> -->

		<ChatList :chats="filteredChats" @open-chat="handleOpenChat" />

		<!-- <PersonInfoPanel
			v-if="activeChatId != null"
			:personInfo="openedPersonInfo"
			@close-person-info-panel="closePersonInfoPanel"
			@open-chat="handleOpenChat"
		/> -->
	</div>
</template>

<style scoped>
.panel {
	min-width: 0;
	display: flex;
	flex: 1;
	flex-direction: column;
}
</style>
