<script setup>
  import { computed, onMounted, ref} from 'vue';
  import IconClose from '../icons/IconClose.vue';
  import IconChats from '../icons/IconChats.vue';
  import { formatAddedTime } from "@/utils/formatAddedTime";
  import { useSocketStore } from "@/stores/socket";
  import { storeToRefs } from "pinia";
  import GroupMemberSelector from "@/components/groups/GroupMemberSelector.vue";


  const props = defineProps({
    chatId: {
      type: String,
      required: true
    }
  })

  const socketStore = useSocketStore();
  const { userInfo } = storeToRefs(socketStore);
  const chatInfo = computed(() =>
  socketStore.chatsInfo[props.chatId]
)
  const isPrivate = computed(() => chatInfo.value?.type === 'private')
  const isGroup = computed(() => chatInfo.value?.type === "group");
  const members = computed(() => chatInfo.value?.members ?? []);
  const isCurrentUserAdmin = computed(() => {
  return members.value.some(
    (m) => m.user_id === userInfo.value.id && m.role === "admin");});

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

  function handleSendMsg(){
    emit("open-chat", chatInfo.value?.private_chat_id);
  }

  function isYou(member) {
    return member.user_id === userInfo.value.id;
  }

  function canRemove(member) {
  if (!isCurrentUserAdmin.value) return false;
  if (isYou(member)) return false;

  return true;
  }

  async function removeMember(member) {
  const token = sessionStorage.getItem("token");

  await fetch(
    `/api/chats/${chatInfo.value?.id}/members/${member.user_id}`,
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

  await fetch(`/api/chats/${chatInfo.value.id}/members`, {
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

onMounted(() => {
  console.log("ChatInfoPanel mounted with chatInfo:", chatInfo.value);
  console.log("Current userInfo:", userInfo.value);
})
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
          @click="
            !isYou(member) &&
            emit('open-person-info', member)
          "
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
                  {{ member.username }}
                </p>

                <span
                  v-if="isYou(member)"
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
            v-if="canRemove(member)"
            class="remove-btn"
            @click.stop="removeMember(member)"
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
</style>