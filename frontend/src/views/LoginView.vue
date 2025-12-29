<script setup>
import { ref } from 'vue'

// estado (antes: variables JS sueltas)
const username = ref('')
const password = ref('')

function handleLogin() {
  console.log('Username:', username.value)
  console.log('Password:', password.value)

  // Cambiar por
  // llamada al login backend -> guardar el token -> abrir WS -> redirigir a /chats
}
</script>

<template>
  <div class="login-container">
    <img src="/Echo_Logo_Completo_Negativo.svg" class="logo" alt="Echo logo" />
    <p>Iniciar sesión</p>

    <form @submit.prevent="handleLogin">
      <input
        type="username"
        placeholder="Username"
        v-model="username"
      />

      <input
        type="password"
        placeholder="Contraseña"
        v-model="password"
      />

      <button type="submit">
        Entrar
      </button>
    </form>
  </div>
  <p>¿No tenés cuenta?</p>
  <router-link to="/register" class="register-link">
      Crear cuenta
  </router-link>
</template>

<style scoped>
.logo {
  height: 4em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}

.login-container {
  min-height: 50vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: white;
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

.register-link {
  margin-top: 16px;
  color: #93c5fd;
  cursor: pointer;
  text-decoration: none;
}
.register-link:hover {
  color: #6b8fb8;
}

</style>
