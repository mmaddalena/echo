<script setup>
	import { ref } from "vue";
	import { useRouter } from "vue-router";
	import { useSocketStore } from "@/stores/socket";


	const username = ref("");
	const password = ref("");
	const name = ref("");
	const email = ref("");

	const router = useRouter();
	const socketStore = useSocketStore();

	async function handleRegister() {
		try {
			const res = await fetch("http://localhost:4000/api/register", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					username: username.value,
					password: password.value,
			name: name.value,
			email: email.value,
				}),
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
</script>

<template>
	<div class="body">
		<div class="register-container">
			<img src="@/assets/logo/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
			<p>Iniciar sesión</p>

			<form @submit.prevent="handleRegister">
				<input type="text" placeholder="Username" v-model="username" />

		<input type="text" placeholder="Nombre Completo" v-model="name" />

		<input type="email" placeholder="Correo electrónico" v-model="email" />

				<input type="password" placeholder="Contraseña" v-model="password" />

				<button type="submit">Entrar</button>
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
</style>