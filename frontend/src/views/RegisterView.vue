<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useSocketStore } from "@/stores/socket";

const username = ref("");
const password = ref("");
const name = ref("");
const email = ref("");
const avatarFile = ref(null);
const avatarPreview = ref(null);

const router = useRouter();
const socketStore = useSocketStore();

async function handleRegister() {
	try {
		const formData = new FormData();

		formData.append("username", username.value);
		formData.append("password", password.value);
		formData.append("name", name.value);
		formData.append("email", email.value);

		// only send avatar if user selected one
		if (avatarFile.value) {
			formData.append("avatar", avatarFile.value);
		}

		const res = await fetch(
			"http://localhost:4000/api/register", 
			//"api/register", 
			{
			method: "POST",
			body: formData, // multipart/form-data
		});

		if (!res.ok) throw new Error("Error en los datos");

		const data = await res.json();
		const token = data.token;

		sessionStorage.setItem("token", token);

		socketStore.disconnect();
		socketStore.connect(token);
		router.push("/chats");
	} catch (err) {
		console.error(err);
		alert("Registro fallido");
	}
}

function onFileChange(e) {
	const file = e.target.files[0] || null;
	avatarFile.value = file;

	if (file) {
		avatarPreview.value = URL.createObjectURL(file);
	} else {
		avatarPreview.value = null;
	}
}
</script>

<template>
	<div class="body">
		<div class="register-container">
			<img
				src="@/assets/logo/Echo_Logo_Completo_Negativo.svg"
				class="logo"
				alt="Echo logo"
			/>
			<p>Iniciar sesión</p>

			<form @submit.prevent="handleRegister">
				<input type="text" placeholder="Username" v-model="username" />

				<input type="text" placeholder="Nombre Completo" v-model="name" />

				<input type="email" placeholder="Correo electrónico" v-model="email" />

				<input type="password" placeholder="Contraseña" v-model="password" />

				<div v-if="avatarPreview" class="avatar-preview">
					<img :src="avatarPreview" alt="Avatar preview" />
				</div>
				<label class="file-upload">
					<input type="file" accept="image/*" @change="onFileChange" />
					<span>
						{{ avatarFile ? "Cambiar avatar" : "Elegir avatar" }}
					</span>
				</label>

				<button type="submit">Registrar</button>
			</form>
		</div>
		<p>¿Ya tenés cuenta?</p>
		<router-link to="/login" class="login-link"> Iniciar Sesión </router-link>
	</div>
</template>

<style scoped>
.body {
	display: flex;
	flex-direction: column;
	justify-content: center;
	place-items: center;
	min-width: 320px;
	min-height: 100vh;
}
p {
	margin-bottom: 20px;
}
.logo {
	height: 12rem;
	padding: 0 0 4.5rem 0;
	will-change: filter;
	transition: filter 300ms;
}

.register-container {
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	color: white;
	margin-bottom: 4rem;
}

form {
	display: flex;
	flex-direction: column;
	gap: 12px;
	width: 280px;
}

input {
	padding: 10px;
	border-radius: 6px;
	border: none;
}

button {
	padding: 10px;
	border-radius: 6px;
	border: none;
	background: #2563eb;
	color: white;
	cursor: pointer;
}

.login-link {
	color: #93c5fd;
	cursor: pointer;
	text-decoration: none;
}
.login-link:hover {
	color: #6b8fb8;
}

.avatar-preview {
	width: 120px;
	height: 120px;
	border-radius: 50%;
	overflow: hidden;
	margin: 0 auto 12px auto;
	border: 2px solid #93c5fd;
	display: flex;
	align-items: center;
	justify-content: center;
	background: #1e293b;
}

.avatar-preview img {
	width: 100%;
	height: 100%;
	object-fit: cover;
}

.file-upload {
	display: flex;
	justify-content: center;
}

.file-upload input {
	display: none;
}

.file-upload span {
	padding: 8px 16px;
	border-radius: 6px;
	background: #2563eb; /* same as register button */
	color: white;
	font-size: 14px;
	font-weight: 500;
	cursor: pointer;
	transition:
		background-color 0.2s ease,
		transform 0.1s ease;
}

.file-upload span:hover {
	background: #1d4ed8;
}

.file-upload span:active {
	transform: scale(0.97);
}
</style>
