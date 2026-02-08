<script setup>
import { ref, computed, watch } from "vue";
import { useSocketStore } from "@/stores/socket";
import { storeToRefs } from "pinia";
import PeopleSearchBar from "@/components/people/PeopleSearchBar.vue";

const emit = defineEmits(["close"]);

const socketStore = useSocketStore();
const { contacts } = storeToRefs(socketStore);
const { userInfo } = storeToRefs(socketStore);
const { peopleSearchResults } = storeToRefs(socketStore);
/* -----------------------
 * Step control
 * --------------------- */
const step = ref(1); // 1: select members, 2: group info

/* -----------------------
 * Local state
 * --------------------- */
const selectedIds = ref([]);
const name = ref("");
const description = ref("");
const avatarFile = ref(null);
const avatarPreview = ref(null);
const searchText = ref(null);
const selectedPeopleMap = ref(new Map());

/* -----------------------
 * Computed
 * --------------------- */

const canGoNext = computed(() => selectedIds.value.length >= 1);

const canCreate = computed(() => name.value.trim().length > 0);

/* -----------------------
 * Methods
 * --------------------- */
function toggleMember(person) {
	const id = person.id;

	if (selectedIds.value.includes(id)) {
		selectedIds.value = selectedIds.value.filter((i) => i !== id);
		selectedPeopleMap.value.delete(id);
	} else {
		selectedIds.value.push(id);
		selectedPeopleMap.value.set(id, person);
	}
}

function onAvatarChange(e) {
	const file = e.target.files[0];
	if (!file) return;

	avatarFile.value = file;
	avatarPreview.value = URL.createObjectURL(file);
}

function nextStep() {
	if (!canGoNext.value) return;
	step.value = 2;
}

function prevStep() {
	step.value = 1;
}

async function createGroup() {
	if (!canCreate.value) return;

	let avatarUrl = null;

	try {
		if (avatarFile.value) {
			// temporary UUID so we can upload before group exists
			const tempGroupId = crypto.randomUUID();
			avatarUrl = await uploadGroupAvatar(tempGroupId, avatarFile.value);
		}

		socketStore.send({
			type: "create_group",
			name: name.value.trim(),
			description: description.value.trim(),
			avatar_url: avatarUrl,
			member_ids: selectedIds.value,
		});

		close();
	} catch (e) {
		console.error("Error creating group:", e);
	}
}

function close() {
	reset();
	emit("close");
}

function reset() {
	step.value = 1;
	selectedIds.value = [];
	name.value = "";
	description.value = "";
	avatarFile.value = null;
	avatarPreview.value = null;
	searchText.value = null;

	socketStore.deletePeopleSearchResults();
}

async function uploadGroupAvatar(groupId, file) {
	const formData = new FormData();
	formData.append("avatar", file);

	try {
		const res = await fetch(
			`http://localhost:4000/api/groups/${groupId}/avatar`,
			//"/api/users/me/avatar",
			{
				method: "POST",
				headers: {
					Authorization: `Bearer ${sessionStorage.getItem("token")}`,
				},
				body: formData,
			},
		);

		const data = await res.json();

		// update avatar in store
		socketStore.updateGroupAvatar(data.avatar_url);
		return data.avatar_url;
	} catch (err) {
		console.error("Avatar upload failed", err);
	}
}

function searchPeople(input) {
	searchText.value = input;

	if (input && input.trim()) {
		socketStore.searchPeople(input);
	} else {
		socketStore.deletePeopleSearchResults();
	}
}

const peopleToShow = computed(() => {
	const q = searchText.value?.trim();

	if (!q) return [];

	return (peopleSearchResults.value || []).filter(
		(p) => p.id !== userInfo.value?.id && !selectedIds.value.includes(p.id),
	);
});

function getDisplayName(person) {
	const contact = contacts.value.find((c) => c.id === person.id);

	if (contact) {
		// prefer nickname → name → username
		return contact.contact_info?.nickname || contact.name || person.username;
	}

	return `@${person.username}`;
}

const selectedPeople = computed(() =>
	Array.from(selectedPeopleMap.value.values()),
);

const unselectedContacts = computed(() =>
	contacts.value.filter((p) => !selectedIds.value.includes(p.id)),
);
</script>

<template>
	<div class="panel-header">
		<h3 v-if="step === 1">Nuevo grupo</h3>
		<h3 v-else>Información del grupo</h3>

		<button class="close-btn" @click="close">✕</button>
	</div>

	<PeopleSearchBar v-if="step === 1" @search-people="searchPeople" />

	<!-- STEP 1: SELECT MEMBERS -->
	<div v-if="step === 1" class="panel-body">
		<p class="subtitle">Selecciona al menos 1 miembro</p>
		<div class="contacts-list">
			<!-- SELECTED (contacts + non-contacts) -->
			<template v-if="step === 1 && !searchText && selectedPeople.length">
				<p class="selected-label">Seleccionados</p>
				<label
					v-for="person in selectedPeople"
					:key="`selected-${person.id}`"
					class="contact-item selected"
				>
					<input type="checkbox" checked @change="toggleMember(person)" />

					<img :src="person.avatar_url" class="avatar" />
					{{ getDisplayName(person) }}
				</label>
			</template>

			<!-- SEARCH RESULTS -->
			<label
				v-if="searchText"
				v-for="person in peopleToShow"
				:key="person.id"
				class="contact-item"
			>
				<input
					type="checkbox"
					:checked="selectedIds.includes(person.id)"
					@change="toggleMember(person)"
				/>

				<img :src="person.avatar_url" class="avatar" />
				{{ getDisplayName(person) }}
			</label>

			<!-- CONTACTS (when no search) -->
			<template v-else>
				<p v-if="unselectedContacts.length" class="selected-label">Contactos</p>

				<label
					v-for="person in unselectedContacts"
					:key="person.id"
					class="contact-item"
				>
					<input
						type="checkbox"
						:checked="selectedIds.includes(person.id)"
						@change="toggleMember(person)"
					/>

					<img :src="person.avatar_url" class="avatar" />
					{{ getDisplayName(person) }}
				</label>
			</template>
		</div>
	</div>

	<!-- STEP 2: GROUP INFO -->
	<div v-else class="panel-body">
		<div class="avatar-section">
			<img v-if="avatarPreview" :src="avatarPreview" class="group-avatar" />
			<div v-else class="group-avatar placeholder">👥</div>

			<input type="file" accept="image/*" @change="onAvatarChange" />
		</div>

		<input v-model="name" type="text" placeholder="Group name" class="input" />

		<textarea
			v-model="description"
			placeholder="Description (optional)"
			class="textarea"
		/>
	</div>

	<!-- Footer -->
	<div class="panel-footer">
		<button v-if="step === 2" @click="prevStep">Atras</button>

		<button v-if="step === 1" :disabled="!canGoNext" @click="nextStep">
			Siguiente
		</button>

		<button v-if="step === 2" :disabled="!canCreate" @click="createGroup">
			Crear grupo
		</button>
	</div>
</template>

<style scoped>
.panel {
	width: 100%;
	height: 100%;

	display: flex;
	flex-direction: column;

	background: var(--bg-peoplelist-panel);
	border-radius: 0;
	box-shadow: none;
	overflow: hidden;

	color: var(--text-primary);
	min-height: 0;
}

/* ---------- HEADER ---------- */
.panel-header {
	padding: 14px 18px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.panel-header h3 {
	font-size: 16px;
	font-weight: 600;
	margin: 0;
}

.close-btn {
	background: transparent;
	border: none;
	color: #aaa;
	font-size: 18px;
	cursor: pointer;
}

.close-btn:hover {
	color: #fff;
}

/* ---------- BODY ---------- */
.panel-body {
	flex: 1;
	min-height: 0;
	padding: 16px 18px;
	overflow-y: auto;
	min-width: 0;
	overflow-x: hidden;
	scrollbar-gutter: stable;
}

.subtitle {
	font-size: 13px;
	color: rgba(255, 255, 255, 0.65);
	margin-bottom: 10px;
}

/* ---------- CONTACT LIST ---------- */
.contacts-list {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.contact-item {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 8px 10px;
	border-radius: 10px;
	cursor: pointer;
	transition: background 0.15s ease;
}

.contact-item:hover {
	background: rgba(255, 255, 255, 0.05);
}

.contact-item input {
	accent-color: var(--msg-out);
	cursor: pointer;
}

.avatar {
	width: 36px;
	height: 36px;
	border-radius: 50%;
	object-fit: cover;
}

.contact-item span {
	font-size: 14px;
	font-weight: 500;
}

/* ---------- AVATAR PICKER ---------- */
.avatar-section {
	display: flex;
	align-items: center;
	gap: 14px;
	margin-bottom: 14px;
}

.group-avatar {
	width: 64px;
	height: 64px;
	border-radius: 50%;
	object-fit: cover;
	background: rgba(255, 255, 255, 0.08);
}

.placeholder {
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 26px;
	color: rgba(255, 255, 255, 0.6);
}

.avatar-section input[type="file"] {
	font-size: 12px;
	color: rgba(255, 255, 255, 0.7);
}

/* ---------- INPUTS ---------- */
.input,
.textarea {
	width: 100%;
	padding: 10px 12px;
	margin-top: 10px;
	border-radius: 10px;
	border: none;
	background: rgba(255, 255, 255, 0.06);
	color: white;
	font-size: 14px;
}

.input::placeholder,
.textarea::placeholder {
	color: rgba(255, 255, 255, 0.5);
}

.textarea {
	resize: none;
	min-height: 80px;
}

/* ---------- FOOTER ---------- */
.panel-footer {
	padding: 12px 18px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	border-top: 1px solid rgba(255, 255, 255, 0.06);
}

/* ---------- BUTTONS ---------- */
button {
	border: none;
	border-radius: 20px;
	padding: 6px 16px;
	font-size: 14px;
	font-weight: 500;
	cursor: pointer;
	transition:
		opacity 0.15s ease,
		transform 0.05s ease;
}

button:active {
	transform: scale(0.97);
}

button:disabled {
	opacity: 0.4;
	cursor: not-allowed;
}

.panel-footer button {
	background: var(--msg-out);
	color: white;
}

.panel-footer button:first-child {
	/* background: transparent; */
	color: white;
}

.panel-footer button:first-child:hover {
	color: white;
}

.search {
	margin: 0;
	padding: 0.5rem 1rem;
	width: 100%;
	box-sizing: border-box;
}

.selected-label {
	margin: 6px 0 4px;
	font-size: 12px;
	font-weight: 600;
	color: rgba(255, 255, 255, 0.6);
	text-transform: uppercase;
}

.contact-item.selected {
	background: rgba(255, 255, 255, 0.08);
}
</style>
