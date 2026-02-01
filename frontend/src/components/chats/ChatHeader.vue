<script setup>
import IconSearch from "../icons/IconSearch.vue";
import IconOptsMenu from "../icons/IconOptsMenu.vue";
import { computed, ref } from "vue";

const props = defineProps({
	chatInfo: {
		type: Object,
		default: null,
	},
});

const zoomedImage = ref(null);

function openImage(src) {
	zoomedImage.value = src;
}

function closeImage() {
	zoomedImage.value = null;
}

const membersStr = computed(() => {
	return props.chatInfo?.members?.map((m) => m.username).join(", ") ?? "";
});
</script>

<template>
	<header v-if="chatInfo" class="chat-header">
		<div class="user_info">
			<img
				:src="chatInfo.avatar_url"
				class="avatar content image clickable"
				loading="lazy"
				@click="openImage(chatInfo.avatar_url)"
			/>
			<div class="texts">
				<p class="name">{{ chatInfo.name }}</p>
				<span class="status">
					<p v-if="chatInfo.type == 'private'">{{ chatInfo.status }}</p>
					<p v-else>{{ membersStr }}</p>
				</span>
			</div>
		</div>
		<div class="opts_icons">
			<IconSearch class="icon" />
			<IconOptsMenu class="icon" />
		</div>
	</header>

	<Teleport to="body">
		<Transition name="zoom">
			<div v-if="zoomedImage" class="image-overlay" @click.self="closeImage">
				<img :src="zoomedImage" class="zoomed-image" />
			</div>
		</Transition>
	</Teleport>
</template>

<style scoped>
.chat-header {
	background-color: var(--bg-chat-header);
	height: 7rem;
	padding: 1.5rem 1.6rem;
	display: flex;
	box-sizing: content-box;
	align-items: center;
	justify-content: space-between;
	border-bottom: 0.3rem solid rgba(255, 255, 255, 0.05);
}
.user_info {
	display: flex;
	gap: 2rem;
	align-items: center;
}
.avatar {
	background-color: aqua;
	height: 5rem;
	width: 5rem;
	border-radius: 50%;
}
.name {
	color: var(--text-main);
	font-size: 2.2rem;
	font-weight: bold;
}
.status {
	font-size: 1.5rem;
	color: var(--text-muted);
}
.opts_icons {
	display: flex;
	gap: 2rem;
}
.icon {
	height: 2.5rem;
	color: var(--text-main);
	fill: var(--text-main);
}

.clickable {
	cursor: zoom-in;
}

/* Overlay */
.image-overlay {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.85);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 9999;
	backdrop-filter: blur(4px);
}

/* Zoomed image */
.zoomed-image {
	max-width: 90vw;
	max-height: 90vh;
	border-radius: 1rem;
	object-fit: contain;
	cursor: zoom-out;
}

/* Animation */
.zoom-enter-active,
.zoom-leave-active {
	transition: opacity 0.25s ease;
}
.zoom-enter-from,
.zoom-leave-to {
	opacity: 0;
}
</style>
