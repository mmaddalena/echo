<script setup>
import { ref } from "vue";

import IconSend from "../icons/IconSend.vue";

const emit = defineEmits(["send-message", "send-attachment"]);
const text = ref("");
const fileInput = ref(null);

function send() {
	if (!text.value.trim()) return;

	emit("send-message", text.value);
	text.value = "";
}

function pickFile() {
	fileInput.value.click();
}

async function onFileSelected(e) {
	const file = e.target.files[0];
	if (!file) return;

	emit("send-attachment", file);
	e.target.value = "";
}
</script>

<template>
	<div class="chat-input">
		<div class="main">
			<button @click="pickFile">📎</button>

			<input
				v-model="text"
				placeholder="Escribe un mensaje..."
				@keydown.enter="send"
			/>
			<button @click="send">
				<IconSend />
			</button>

			<input
				ref="fileInput"
				type="file"
				hidden
				accept="image/*,application/pdf"
				@change="onFileSelected"
			/>
		</div>
	</div>
</template>

<style scoped>
.chat-input {
	height: fit-content;
	background-color: var(--bg-chat);
	padding: 0 2rem 2rem 2rem;
}
.main {
	height: fit-content;
	padding: 0rem 1rem 0rem 2rem;
	display: flex;
	justify-content: space-between;
	background: var(--bg-input);
	border-radius: 3rem;
	align-items: center;
}
input {
	flex: 1;
	height: 5rem;
	border: none;
	background: none;
	color: var(--text-main);
	outline: none;
	font-size: 1.5rem;
}
button {
	background-color: var(--msg-out);
	border: none;
	border-radius: 50%;
	width: 4rem;
	height: 4rem;
	color: white;
	cursor: pointer;
}
</style>
