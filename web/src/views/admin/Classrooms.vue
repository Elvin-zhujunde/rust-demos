<template>
  <div class="classrooms-container">
    <div class="header">
      <a-button type="primary" @click="showModal()">新增教室</a-button>
    </div>
    <a-table
      :columns="columns"
      :data-source="classrooms"
      :loading="loading"
      rowKey="classroom_id"
      bordered
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="showModal(record)">编辑</a>
            <a-popconfirm title="确定要删除吗？" @confirm="handleDelete(record)">
              <a class="danger">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:visible="modalVisible"
      :title="modalTitle"
      @ok="handleOk"
      @cancel="handleCancel"
      :destroyOnClose="true"
    >
      <a-form
        :model="formState"
        :rules="rules"
        ref="formRef"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item label="教学楼" name="building">
          <a-input v-model:value="formState.building" placeholder="请输入教学楼名称" />
        </a-form-item>
        <a-form-item label="房间号" name="room_number">
          <a-input v-model:value="formState.room_number" placeholder="请输入房间号" />
        </a-form-item>
        <a-form-item label="容纳人数" name="capacity">
          <a-input-number
            v-model:value="formState.capacity"
            :min="1"
            placeholder="请输入容纳人数"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";

const classrooms = ref([]);
const loading = ref(false);
const modalVisible = ref(false);
const formRef = ref(null);
const formState = ref({});
const editId = ref(null);

const columns = [
  { title: "教学楼", dataIndex: "building", key: "building" },
  { title: "房间号", dataIndex: "room_number", key: "room_number" },
  { title: "容纳人数", dataIndex: "capacity", key: "capacity" },
  { title: "操作", key: "action", fixed: "right", width: 120 },
];

const rules = {
  building: [{ required: true, message: "请输入教学楼名称" }],
  room_number: [{ required: true, message: "请输入房间号" }],
  capacity: [
    { required: true, message: "请输入容纳人数" },
    { type: "number", min: 1, message: "容纳人数必须大于0" },
  ],
};

const modalTitle = computed(() => (editId.value ? "编辑教室" : "新增教室"));

const fetchClassrooms = async () => {
  loading.value = true;
  try {
    const res = await axios.get("/classroomss");
    classrooms.value = res.data.data.items;
  } catch (e) {
    message.error("获取教室列表失败");
  } finally {
    loading.value = false;
  }
};

const showModal = (record) => {
  if (record) {
    editId.value = record.classroom_id;
    formState.value = { ...record };
  } else {
    editId.value = null;
    formState.value = {
      building: "",
      room_number: "",
      capacity: 30,
    };
  }
  modalVisible.value = true;
};

const handleOk = async () => {
  try {
    await formRef.value.validate();
    const data = { ...formState.value };
    if (editId.value) {
      await axios.put(`/classrooms/${editId.value}`, data);
      message.success("编辑成功");
    } else {
      await axios.post("/classrooms", data);
      message.success("新增成功");
    }
    modalVisible.value = false;
    fetchClassrooms();
  } catch (e) {
    message.error("操作失败");
  }
};

const handleCancel = () => {
  modalVisible.value = false;
  formRef.value?.resetFields();
};

const handleDelete = async (record) => {
  try {
    await axios.delete(`/classrooms/${record.classroom_id}`);
    message.success("删除成功");
    fetchClassrooms();
  } catch {
    message.error("删除失败");
  }
};

onMounted(() => {
  fetchClassrooms();
});
</script>

<style scoped>
.classrooms-container {
  padding: 24px;
}
.header {
  margin-bottom: 16px;
}
.danger {
  color: #ff4d4f;
}
</style> 