<script setup>
import { ref, computed } from "vue";
import { useSocketStore } from "@/stores/socket";

const socketStore = useSocketStore();

const username = ref("Manu");
const status = ref("Activo");

const uploading = ref(false);
const fileInput = ref(null);

const avatarUrl = computed(() => socketStore.userInfo?.avatar_url);

function triggerFilePicker() {
	fileInput.value.click();
}

async function onAvatarSelected(e) {
	const file = e.target.files[0];
	if (!file) return;

	if (file.size > 5_000_000) {
		alert("Max 5MB");
		return;
	}

	const formData = new FormData();
	formData.append("avatar", file);

	uploading.value = true;

	try {
		const res = await fetch("http://localhost:4000/api/users/me/avatar", {
			method: "POST",
			headers: {
				Authorization: `Bearer ${sessionStorage.getItem("token")}`,
			},
			body: formData,
		});

		const data = await res.json();

		// 🔥 update avatar in store
		socketStore.updateAvatar(data.avatar_url);
	} catch (err) {
		console.error("Avatar upload failed", err);
	} finally {
		uploading.value = false;
	}
}
</script>

<template>
	<section id="profile" class="settings-section">
		<h2>Perfil</h2>

		<div class="field">
			<label>Nombre</label>
			<input v-model="username" type="text" />
		</div>

		<div class="field">
			<label>Estado</label>
			<input v-model="status" type="text" />
		</div>

		<!-- Avatar -->
		<div class="avatar-block">
			<img
				:src="avatarUrl || '/default-avatar.png'"
				class="avatar"
				alt="Avatar"
			/>

			<button @click="triggerFilePicker" :disabled="uploading">
				{{ uploading ? "Subiendo..." : "Cambiar avatar" }}
			</button>

			<input
				ref="fileInput"
				type="file"
				accept="image/*"
				hidden
				@change="onAvatarSelected"
			/>
		</div>

		<button class="save">Guardar cambios</button>
	</section>
</template>

<style scoped>
.settings-section {
	padding: 2.4rem 0;
}

h2 {
	margin-bottom: 2rem;
	font-size: 2rem;
}

.field {
	display: flex;
	flex-direction: column;
	gap: 0.6rem;
	margin-bottom: 1.6rem;
}

label {
	font-size: 1.3rem;
	color: var(--text-muted);
}

input {
	background: none;
	border: 1px solid #2f3e63;
	border-radius: 0.8rem;
	padding: 0.8rem;
	color: var(--text-main);
}

.save {
	margin-top: 1.6rem;
	padding: 0.8rem 1.6rem;
	border-radius: 1rem;
	background: var(--msg-out);
	border: none;
	cursor: pointer;
}

.avatar-block {
	display: flex;
	align-items: center;
	gap: 1.6rem;
	margin-bottom: 2.4rem;
}

.avatar {
	width: 72px;
	height: 72px;
	border-radius: 50%;
	object-fit: cover;
	border: 2px solid #2f3e63;
}

.avatar-block button {
	padding: 0.6rem 1.2rem;
	border-radius: 0.8rem;
	border: none;
	background: var(--msg-out);
	cursor: pointer;
}

.avatar-block button:disabled {
	opacity: 0.6;
	cursor: not-allowed;
}
</style>
