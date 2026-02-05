<script setup>
  import { computed } from 'vue';
  import IconClose from '../icons/IconClose.vue';
  import IconChats from '../icons/IconChats.vue';
  import { formatAddedTime } from "@/utils/formatAddedTime";

  const {personInfo} = defineProps({
    personInfo: {
      type: Object,
      required: true
    }
  })

  const emit = defineEmits(["close-person-info-panel", "open-chat"]);

  function handleClosePanel(){
    emit("close-person-info-panel");
  }

  function handleSendMsg(){
    emit("open-chat", personInfo.private_chat_id);
  }

  const isContact = computed(() => personInfo.contact_info != null);
</script>

<template>
  <div class="panel">
    <button class="close-btn" @click="handleClosePanel">
      <IconClose />
    </button>
    <img class="avatar" :src="personInfo.avatar_url"></img>
    <p v-if="isContact" class="main-name">{{ personInfo.contact_info?.nickname}}</p>
    <p v-else class="main-name">{{personInfo.username }}</p>

    <p v-if="isContact" class="second-name">{{ personInfo.username}}</p>
    <p v-else class="second-name">{{personInfo.name }}</p>

    <p v-if="isContact" class="added-date">
      <!-- Agregado {{ formatAddedTime(personInfo.contact_info?.added_at) }} -->
       <p v-if="personInfo.status == 'Offline' && last_seen_at">
							- Ultima vez activo
							{{ formatAddedTime(last_seen_at) }}
       </p>
       <p v-else>
         Estado: {{ personInfo.status }}
         </p>
    </p>

    <div class="buttons">
      <button class="btn" @click="handleSendMsg">
        <IconChats class="btn-icon" />
        <p class="btn-text">
          Enviar Mensaje
        </p>
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
</style>