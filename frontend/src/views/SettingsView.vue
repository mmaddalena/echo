<script setup>
import { computed } from "vue";
import { onMounted } from "vue";
import { useRouter } from "vue-router";
import { useSocketStore } from "@/stores/socket";
import { useUIStore } from "@/stores/ui";

import Sidebar from "@/components/layout/Sidebar.vue";
import SettingsSectionsList from "../components/settings/SettingsSectionsList.vue";
import SettingsPanel from "../components/settings/SettingsPanel.vue";

import logoLight from "@/assets/logo/Echo_Logo_Completo.svg";
import logoDark from "@/assets/logo/Echo_Logo_Completo_Negativo.svg";

import { useThemeStore } from "@/stores/theme"
const themeStore = useThemeStore()
const uiStore = useUIStore();
const theme = computed(() => themeStore.theme)

const router = useRouter();
const socketStore = useSocketStore();
const user = computed(() => socketStore.userInfo);

onMounted(() => {
	const token = sessionStorage.getItem("token");
	if (token) {
		socketStore.connect(token);
	}
});

function logout() {
	sessionStorage.removeItem("token");
	socketStore.disconnect();
	router.push("/login");
}

const isMobile = computed(() => uiStore.isMobile)
</script>

<template>
	<div class="settings-layout">
		<div class="left">
			<img
				:src="theme === 'dark' ? logoDark : logoLight"
				class="logo"
				alt="Echo logo"
			/>
			<div class="main">
				<Sidebar :avatarURL="user?.avatar_url" />
				<SettingsSectionsList 
					v-if="!isMobile"
					class="sections-list"
				/>
			</div>
		</div>
		<div class="right">
			<SettingsPanel @logout="logout" />
		</div>
	</div>
</template>

<style scoped>
.settings-layout {
	display: flex;
	flex-direction: row;
	height: 100vh;
}
.left {
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	height: 100%;
	width: var(--left-section-width);
}
.logo {
	height: 6rem;
	margin: 2rem;
}
.main {
	display: flex;
	flex-direction: row;
	flex: 1;
	width: 100%;
}
.right {
	display: flex;
	flex-direction: column;
	flex: 1;
	margin: 10rem 0 2rem 2rem;
}

.sections-list {
	background-color: var(--bg-chatlist-panel);
	border-radius: 1.5rem 1.5rem 0 0;
}


@media (max-width: 768px) {
  .settings-layout {
    flex-direction: column !important;
		height: 100dvh !important;
  }
  .left {
    width: 100% !important;
    height: auto !important;
  }
  .main {
    display: block !important;
  }
  .right {
    flex: 1 !important;
    width: 100% !important;
		height: auto !important;
		margin: 0 !important;
		padding-bottom: calc(var(--sidebar-mobile-heigth) + 2rem);
		padding-left: 2rem;
  }
}
</style>
