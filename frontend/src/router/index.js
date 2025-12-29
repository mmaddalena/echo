import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/views/LoginView.vue'
import RegisterView from '@/views/RegisterView.vue'
import ChatsView from '@/views/ChatsView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/login'},
    { path: '/login', component: LoginView},
    { path: '/register', component: RegisterView},
    { path: '/chats', component: ChatsView}
  ]
})

export default router
