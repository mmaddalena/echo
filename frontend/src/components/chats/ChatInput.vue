<script setup>
import { ref, onMounted, onUnmounted, nextTick } from "vue";
import EmojiPicker from 'vue3-emoji-picker';
import 'vue3-emoji-picker/css';

import IconSend from "../icons/IconSend.vue";
import IconMedia from "../icons/IconMedia.vue";
import IconEmoji from "../icons/IconEmoji.vue";

const emit = defineEmits(["send-message", "send-attachment"]);
const text = ref("");
const fileInput = ref(null);
const inputRef = ref(null);
const showEmojiPicker = ref(false);
const emojiPickerRef = ref(null);
const emojiButtonRef = ref(null);

function send() {
	if (!text.value.trim()) return;

	emit("send-message", text.value);
	text.value = "";

	nextTick(() => {
    inputRef.value?.focus();
  });
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

function focusInput() {
	inputRef.value?.focus();
}
function clear() {
	text.value = ""
}

function toggleEmojiPicker() {
	showEmojiPicker.value = !showEmojiPicker.value;
}

function addEmoji(emoji) {
	text.value += emoji.i;
	inputRef.value?.focus();
}

function handleClickOutside(event) {
	if (showEmojiPicker.value) {
		const picker = emojiPickerRef.value;
		const button = emojiButtonRef.value;
		
		if (picker && !picker.contains(event.target) && 
			button && !button.contains(event.target)) {
			showEmojiPicker.value = false;
		}
	}
}

onMounted(() => {
	document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
	document.removeEventListener('click', handleClickOutside);
});

defineExpose({focusInput, clear});

</script>

<template>
	<div class="chat-input">
		<div class="main">
			<!-- Left side buttons group (file + emoji) -->
			<div class="left-buttons">
				<button @click="pickFile" class="action-button">
					<IconMedia class="icon"/>
				</button>
				
				<!-- Emoji button -->
				<button 
					ref="emojiButtonRef"
					@click="toggleEmojiPicker" 
					class="action-button"
					:class="{ 'active': showEmojiPicker }"
				>
					<IconEmoji class="icon"/>
				</button>
			</div>

			<input
				ref="inputRef"
				v-model="text"
				placeholder="Escribe un mensaje..."
				@keydown.enter.prevent="send"
			/>
			
			<!-- Send button -->
			<button 
				@click="send" 
				@mousedown.prevent
				class="send-button"
			>
				<IconSend class="icon"/>
			</button>

			<input
				ref="fileInput"
				type="file"
				hidden
				accept="image/*,application/pdf"
				@change="onFileSelected"
			/>
		</div>
		
		<!-- Emoji picker dropdown -->
		<div 
			v-if="showEmojiPicker" 
			ref="emojiPickerRef"
			class="emoji-picker-container"
			@click.stop
		>
			<EmojiPicker 
				@select="addEmoji"
				:auto-focus="true"
			/>
		</div>
	</div>
</template>

<style scoped>
.chat-input {
	height: fit-content;
	background-color: var(--bg-chat);
	padding: 0 2rem 2rem 2rem;
	position: relative;
}
.main {
	height: fit-content;
	padding: 0rem 1rem;
	display: flex;
	justify-content: space-between;
	background: var(--bg-input);
	border-radius: 3rem;
	align-items: center;
	gap: 0.5rem;
}

/* Left buttons group */
.left-buttons {
	display: flex;
	gap: 0.5rem;
	align-items: center;
	flex-shrink: 0;
}

input {
	flex: 1;
	height: 5rem;
	border: none;
	background: none;
	color: var(--text-main);
	outline: none;
	font-size: 1.5rem;

	flex: 1 1 auto;
	min-width: 0;
}

/* Base button styles */
.action-button, 
.send-button {
	/* display: flex; */
	padding-top: 0.5rem;
	align-items: center;
	justify-content: center;
	background-color: var(--msg-out);
	border: none;
	border-radius: 50%;
	width: 3.5rem;
	height: 3.5rem;
	color: white;
	cursor: pointer;
	transition: background-color 0.2s;

	flex-shrink: 0;
}

/* Active state for emoji button when picker is open */
.action-button.active {
	background-color: var(--accent-color);
}

.icon {
	color: var(--text-main);
	max-height: 2.5rem;
	max-width: 2.5rem;
}

/* Send button can have a different color if you want */
.send-button {
	background-color: var(--msg-out); /* or keep it same as others */
}

.emoji-picker-container {
	position: absolute;
	bottom: 100%;
	left: 2rem; /* Changed from right to left to align with buttons */
	margin-bottom: 0.5rem;
	z-index: 1000;
	box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
	border-radius: 8px;
	overflow: hidden;
}
</style>

<style>
.v3-emoji-picker {
  background-color: var(--bg-input);
  color: var(--text-main);

	--v3-picker-emoji-hover: var(--bg-chatlist-panel) !important;
}
.v3-sticky {
	background-color: var(--bg-input) !important;
}
.v3-text {
	color: var(--text-main);
}
.v3-header img {
	background-color: var(--text-main-light);
	border-radius: 0.6rem;
}
.v3-header input {
	background-color: var(--bg-chatlist-panel) !important;
	border: none !important;
	border-radius: 0.8rem !important;
}
.v3-skin-tones {
	background-color: var(--bg-input) !important;
}
</style>