<script setup>
  import { computed, onMounted, ref} from 'vue';
  import IconClose from '../icons/IconClose.vue';
  import { formatAddedTime } from "@/utils/formatAddedTime";
  import GroupMemberSelector from "@/components/groups/GroupMemberSelector.vue";


 const { chatInfo, currentUserId } = defineProps({
    chatInfo: Object,
    currentUserId: Number,
  });

  const isPrivate = computed(() => chatInfo?.type === 'private')
  const isGroup = computed(() => chatInfo?.type === 'group');
  const members = computed(() => chatInfo?.members ?? []);

  const isCurrentUserAdmin = computed(() => {
  return members.value.some(
    (m) => m.user_id === currentUserId && m.role === "admin");});

  const emit = defineEmits(["close-chat-info-panel", "open-chat", "open-person-info"]);

  /* -----------------------
  * Add members state
  * --------------------- */
  const showAddMembers = ref(false);
  const newMemberIds = ref([]);

  const existingMemberIds = computed(() =>
    members.value.map((m) => m.user_id)
  );

  function handleClosePanel(){
    emit("close-chat-info-panel");
  }

  function isYou(member_id) {
    return member_id === currentUserId;
  }

  function canRemove(member_id) {
    if (!isCurrentUserAdmin.value) return false;
    if (isYou(member_id)) return false;

    return true;
  }

  async function removeMember(member_id) {
    const token = sessionStorage.getItem("token");

    await fetch(
      `/api/chats/${chatInfo.id}/members/${member_id}`,
      {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );
  }

async function addMembers() {
  if (!newMemberIds.value.length) return;

  const token = sessionStorage.getItem("token");

  await fetch(`/api/chats/${chatInfo.id}/members`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      member_ids: newMemberIds.value,
    }),
  });

  showAddMembers.value = false;
  newMemberIds.value = [];
}

function cancelAddMembers() {
  showAddMembers.value = false;
  newMemberIds.value = [];
}

async function leaveGroup() {
  const confirmLeave = confirm(
    "¿Seguro que quieres abandonar el grupo?"
  );
  if (!confirmLeave) return;

  const token = sessionStorage.getItem("token");

  try {
    const res = await fetch(
      `/api/chats/${chatInfo.id}/members/${currentUserId}`,
      {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    console.log("Status:", res.status);
    console.log("Body:", await res.text());

    if (res.status === 204) {
      // Successfully left the group
      alert("Has abandonado el grupo");
      emit("close-chat-info-panel");
      // Optionally, you can emit a custom event to refresh the chat list
      // emit("left-group", chatInfo.value.id);
    } else {
      const data = await res.json();
      alert(`Error al abandonar el grupo: ${data.error}`);
    }
  } catch (err) {
    console.error(err);
    alert("Error de red al intentar abandonar el grupo");
  }
}

function handleOpenPersonInfo(member_id) {
  emit('open-person-info', member_id)
}
</script>

<template>
  <div class="panel">
    <button class="close-btn" @click="handleClosePanel">
      <IconClose />
    </button>

    <img class="avatar" :src="chatInfo?.avatar_url" />
    <p class="main-name">{{ chatInfo?.name }}</p>

    <p v-if="isGroup">
      {{ chatInfo?.description }}
    </p>

    <div v-if="isPrivate" class="added-date">
      <p
        v-if="
          chatInfo?.status == 'Offline' &&
          chatInfo?.last_seen_at
        "
      >
        Ultima vez activo:
        {{ formatAddedTime(chatInfo?.last_seen_at) }}
      </p>
      <p v-else>
        Estado: {{ chatInfo.status }}
      </p>
    </div>

    <!-- GROUP MEMBERS -->
    <div v-if="isGroup" class="members-section">
      <div class="members-header">
        <p class="members-title">
          Miembros ({{ members.length }})
        </p>

        <button
          v-if="isCurrentUserAdmin && !showAddMembers"
          class="add-member-btn"
          @click="showAddMembers = true"
        >
          Agregar
        </button>
      </div>

      <!-- MEMBER LIST -->
      <ul
        v-if="!showAddMembers"
        class="members-list"
      >
        <li
          v-for="member in members"
          :key="member.user_id"
          class="member-item clickable"
          @click="handleOpenPersonInfo(member.user_id)"
        >
          <!-- LEFT -->
          <div class="member-left">
            <img
              :src="member.avatar_url"
              class="member-avatar"
              loading="lazy"
            />

            <div class="member-info">
              <div class="member-name-row">
                <p class="member-name">
                  {{ member.nickname ?? member.name ?? member.username }}
                </p>

                <span
                  v-if="isYou(member.user_id)"
                  class="you-badge"
                >
                  Tú
                </span>

                <span
                  v-if="member.role === 'admin'"
                  class="admin-badge"
                >
                  Admin
                </span>
              </div>

              <span class="member-status">
                {{ member.status }}
              </span>
            </div>
          </div>

          <!-- RIGHT -->
          <button
            v-if="canRemove(member.user_id)"
            class="remove-btn"
            @click.stop="removeMember(member.user_id)"
          >
            ⛌
          </button>
        </li>
      </ul>

      <!-- ADD MEMBERS UI -->
      <div v-else class="add-members-panel">
        <GroupMemberSelector
          v-model="newMemberIds"
          :existing-member-ids="existingMemberIds"
        />

        <div class="add-members-actions">
          <button
            class="cancel-btn"
            @click="cancelAddMembers"
          >
            Cancelar
          </button>

          <button
            class="confirm-btn"
            :disabled="!newMemberIds.length"
            @click="addMembers"
          >
            Agregar
          </button>
        </div>
      </div>
    </div>

    <!-- ABANDON GROUP BUTTON -->
    <div v-if="isGroup" class="leave-group-section">
      <button class="leave-group-btn" @click="leaveGroup">
        Abandonar grupo
      </button>
    </div>
  </div>
</template>

<style scoped>

.panel {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: var(--bg-peoplelist-panel);
}
.close-btn {
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: var(--bg-main);
  height: 4rem;
  width: 4rem;
  border-radius: 50%;
  border: none;

  position: absolute;
  top: 1rem;
  right: 1rem;
  cursor: pointer;

  font-size: 2rem;
}

.avatar {
  width: 50%;
  border-radius: 50%;
  margin: 4rem auto 2rem auto;
}
.main-name {
  font-size: 3rem;
  font-weight: bold;
}
.second-name {
  font-size: 1.8rem;
  color: var(--text-muted);
}
.added-date {
  margin-top: 1rem;
  font-size: 1.5rem;
  color: var(--text-muted);
}

.buttons {
  margin-top: 2rem;
}

button {
  border: none;
  border-radius: 20px;
  padding: 6px 16px;
  font-size: 14px;
  cursor: pointer;
  background-color: var(--msg-out);
}

.btn {
  all: unset;
  width: auto;
  height: fit-content;
  background-color: var(--msg-out);
  border-radius: 1rem;
  padding: 0.5rem 1rem;
  cursor: pointer;

  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.btn-icon {
  height: 3.5rem;
}
.btn-text {
  font-size: 1.4rem;
}

.members-section {
  width: 100%;
  margin-top: 2rem;
  padding: 0 1.5rem;
}

.members-title {
  font-size: 1.6rem;
  font-weight: bold;
  color: var(--text-main);
  margin-bottom: 1rem;
}

.members-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.member-item {
  display: flex;
  align-items: center;
  padding: 0.6rem 0.8rem;
  justify-content: space-between;
  cursor: pointer;
}

.member-left {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
  min-width: 0;
}

.remove-btn {
  border: none;
  background: transparent;
  color: tomato;
  font-size: 1.6rem;
  cursor: pointer;
  padding: 0.4rem;
  border-radius: 0.5rem;
}

.remove-btn:hover {
  background-color: rgba(255, 99, 71, 0.15);
}

.member-item:hover {
  background-color: var(--bg-chatlist-hover);
  border-radius: 0.8rem;
}

.member-name-row {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.you-badge {
  font-size: 1.1rem;
  padding: 0.1rem 0.6rem;
  border-radius: 1rem;
  background-color: var(--accent);
  color: white;
}

.admin-badge {
  font-size: 1.1rem;
  padding: 0.1rem 0.6rem;
  border-radius: 1rem;
  background-color: #f59e0b;
  color: white;
}

.member-avatar {
  width: 3.2rem;
  height: 3.2rem;
  border-radius: 50%;
}

.member-info {
  display: flex;
  flex-direction: column;
}

.member-name {
  font-size: 1.5rem;
}

.member-status {
  font-size: 1.3rem;
  color: var(--text-muted);
}

.members-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.add-members-actions {
  display: flex;
  justify-content: end;
  align-items: center;
}

.cancel-btn {
  margin: 1rem;
}

.leave-group-section {
  margin-top: 3rem;
  width: 100%;
  display: flex;
  justify-content: center;
}
</style>