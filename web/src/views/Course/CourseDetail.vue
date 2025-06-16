<template>
  <div class="course-detail">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>{{ courseInfo.subject_name }}</h2>
          <div class="action-buttons">
            <a-button type="primary" @click="showChat = true">
              <template #icon><MessageOutlined /></template>
              课程聊天室
            </a-button>
            <a-button
              v-if="isTeacher"
              type="primary"
              @click="showCreateTaskModal"
            >
              <template #icon><PlusOutlined /></template>
              发布任务
            </a-button>
            <a-button
              v-if="isTeacher"
              type="primary"
              danger
              @click="handleEndCourse"
            >
              <template #icon><StopOutlined /></template>
              结束课程
            </a-button>
            <a-button type="primary" @click="showComments = true">
              <template #icon><CommentOutlined /></template>
              查看评论
            </a-button>
          </div>
        </div>
      </template>

      <!-- 课程基本信息 -->
      <a-descriptions :column="3" bordered>
        <a-descriptions-item label="授课教师">
          {{ courseInfo.teacher_name }}
          <a-tag>{{ courseInfo.teacher_title }}</a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="上课时间">
          {{ courseInfo.week_day_text }} {{ courseInfo.time_text }}
        </a-descriptions-item>
        <a-descriptions-item label="上课地点">
          {{ courseInfo.classroom_name }}
        </a-descriptions-item>
        <a-descriptions-item label="课程学分">{{
          courseInfo.credits
        }}</a-descriptions-item>
        <a-descriptions-item label="课时">{{
          courseInfo.class_hours
        }}</a-descriptions-item>
        <a-descriptions-item label="选课人数">
          {{ courseInfo.student_count }}/{{ courseInfo.max_students }}
        </a-descriptions-item>
      </a-descriptions>

      <!-- 教学任务列表 -->
      <div class="task-list">
        <h3>教学任务</h3>
        <a-table
          :columns="taskColumns"
          :data-source="taskList"
          :pagination="false"
          :loading="loading"
          rowKey="task_id"
        >
          <template #bodyCell="{ column, record }">
            <!-- 任务状态 -->
            <template v-if="column.dataIndex === 'status'">
              <a-tag :color="record.status === 'active' ? 'green' : 'red'">
                {{ record.status === "active" ? "进行中" : "已截止" }}
              </a-tag>
            </template>

            <!-- 任务时间 -->
            <template v-if="column.dataIndex === 'time'">
              {{ formatDate(record.start_time) }} 至
              {{ formatDate(record.end_time) }}
            </template>

            <!-- 操作列 -->
            <template v-if="column.dataIndex === 'action'">
              <div class="action-buttons">
                <a-button type="link" @click="viewTaskDetail(record)"
                  >查看</a-button
                >
                <template v-if="isTeacher">
                  <a-button type="link" @click="showEditTaskModal(record)"
                    >编辑</a-button
                  >
                  <a-popconfirm
                    title="确定要删除这个教学任务吗？"
                    @confirm="deleteTask(record.task_id)"
                    ok-text="确定"
                    cancel-text="取消"
                  >
                    <a-button type="link" danger>删除</a-button>
                  </a-popconfirm>
                </template>
              </div>
            </template>
          </template>
        </a-table>
      </div>
    </a-card>

    <!-- 创建/编辑教学任务弹窗 -->
    <a-modal
      v-model:open="taskModalVisible"
      :title="editingTask ? '编辑教学任务' : '创建教学任务'"
      @ok="handleTaskSubmit"
      :confirmLoading="submitting"
      width="800px"
    >
      <a-form
        ref="taskFormRef"
        :model="taskForm"
        :rules="taskRules"
        :label-col="{ span: 4 }"
        :wrapper-col="{ span: 20 }"
      >
        <a-form-item label="标题" name="title">
          <a-input
            v-model:value="taskForm.title"
            placeholder="请输入任务标题"
          />
        </a-form-item>
        <a-form-item label="描述" name="description">
          <a-textarea
            v-model:value="taskForm.description"
            :rows="4"
            placeholder="请输入任务描述"
          />
        </a-form-item>
        <a-form-item label="权重" name="weight">
          <a-input-number
            v-model:value="taskForm.weight"
            :min="0"
            :max="100"
            style="width: 100%"
            placeholder="请输入任务权重(0-100)"
          />
        </a-form-item>
        <a-form-item label="时间范围" name="timeRange">
          <a-range-picker
            v-model:value="taskForm.timeRange"
            :show-time="{ format: 'HH:mm' }"
            format="YYYY-MM-DD HH:mm"
            value-format="YYYY-MM-DD HH:mm:ss"
          />
        </a-form-item>
        <a-form-item label="附件" name="attachment_url">
          <a-upload
            v-model:file-list="fileList"
            :before-upload="beforeUpload"
            @remove="handleRemove"
          >
            <a-button>
              <upload-outlined />
              选择文件
            </a-button>
          </a-upload>
        </a-form-item>
        <a-form-item v-if="editingTask" label="状态" name="status">
          <a-select v-model:value="taskForm.status">
            <a-select-option value="active">进行中</a-select-option>
            <a-select-option value="closed">已截止</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 任务详情弹窗 -->
    <a-modal
      v-model:open="taskDetailVisible"
      title="任务详情"
      :footer="null"
      width="800px"
    >
      <div v-if="currentTask" class="task-detail">
        <h3>{{ currentTask.title }}</h3>
        <div class="task-info">
          <p><strong>描述：</strong>{{ currentTask.description }}</p>
          <p><strong>权重：</strong>{{ currentTask.weight }}%</p>
          <p>
            <strong>时间范围：</strong>
            {{ formatDate(currentTask.start_time) }} 至
            {{ formatDate(currentTask.end_time) }}
          </p>
          <p>
            <strong>状态：</strong>
            <a-tag :color="currentTask.status === 'active' ? 'green' : 'red'">
              {{ currentTask.status === "active" ? "进行中" : "已截止" }}
            </a-tag>
          </p>
          <p v-if="currentTask.attachment_url">
            <strong>附件：</strong>
            <a
              :href="getAttachmentUrl(currentTask.attachment_url)"
              target="_blank"
              >下载附件</a
            >
          </p>

          <!-- 学生提交作业部分 -->
          <template v-if="!isTeacher">
            <div class="submission-section">
              <h4>提交作业</h4>
              <div v-if="currentTask.submission" class="submitted-info">
                <p>
                  <strong>提交时间：</strong
                  >{{ formatDate(currentTask.submission.submitted_at) }}
                </p>
                <p v-if="currentTask.submission.score !== null">
                  <strong>得分：</strong>{{ currentTask.submission.score }}
                </p>
                <p v-if="currentTask.submission.feedback">
                  <strong>教师反馈：</strong
                  >{{ currentTask.submission.feedback }}
                </p>
                <p v-if="currentTask.submission.attachment_url">
                  <strong>已提交的附件：</strong>
                  <a
                    :href="
                      getAttachmentUrl(currentTask.submission.attachment_url)
                    "
                    target="_blank"
                    >下载</a
                  >
                </p>
              </div>
              <a-form
                v-if="currentTask.status === 'active'"
                :model="submissionForm"
                layout="vertical"
              >
                <a-form-item label="作业内容">
                  <a-textarea
                    v-model:value="submissionForm.content"
                    :rows="4"
                    placeholder="请输入作业内容"
                  />
                </a-form-item>
                <a-form-item label="附件">
                  <a-upload
                    v-model:file-list="submissionFileList"
                    :before-upload="beforeSubmissionUpload"
                    @remove="handleSubmissionRemove"
                  >
                    <a-button>
                      <upload-outlined />
                      选择文件
                    </a-button>
                  </a-upload>
                </a-form-item>
                <a-form-item>
                  <a-button type="primary" @click="submitAssignment">
                    提交作业
                  </a-button>
                </a-form-item>
              </a-form>
            </div>
          </template>
          <!-- 教师查看提交列表部分 -->
          <template v-else>
            <div class="submissions-list">
              <h4>学生提交列表</h4>
              <a-table
                :columns="submissionColumns"
                :data-source="submissionList"
                :loading="submissionLoading"
                rowKey="submission_id"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.dataIndex === 'score'">
                    <div v-if="record.score !== null">
                      {{ record.score }}
                    </div>
                    <a-input-number
                      v-else
                      v-model:value="record.tempScore"
                      :min="0"
                      :max="100"
                      placeholder="分数"
                      style="width: 80px"
                    />
                  </template>
                  <template v-if="column.dataIndex === 'feedback'">
                    <div v-if="record.feedback">
                      {{ record.feedback }}
                    </div>
                    <a-input
                      v-else
                      v-model:value="record.tempFeedback"
                      placeholder="请输入反馈"
                    />
                  </template>
                  <template v-if="column.dataIndex === 'action'">
                    <div class="action-buttons">
                      <a-button
                        v-if="record.attachment_url"
                        type="link"
                        @click="downloadSubmission(record)"
                      >
                        下载作业
                      </a-button>
                      <a-button
                        v-if="record.score === null"
                        type="primary"
                        size="small"
                        @click="gradeSubmission(record)"
                      >
                        评分
                      </a-button>
                    </div>
                  </template>
                </template>
              </a-table>
            </div>
          </template>
        </div>
      </div>
    </a-modal>

    <!-- 聊天室抽屉 -->
    <a-drawer
      v-model:visible="showChat"
      title="课程聊天室"
      placement="right"
      :width="600"
      :bodyStyle="{ padding: 0 }"
    >
      <div class="chat-room">
        <div class="chat-messages" ref="messageContainer">
          <div
            v-for="msg in messages"
            :key="msg.message_id"
            :class="['message', { 'my-message': isMyMessage(msg) }]"
          >
            <div class="message-header">
              <span class="sender-name">
                {{ msg.sender_name }}
                <a-tag v-if="msg.sender_type === 'teacher'" color="blue"
                  >老师</a-tag
                >
              </span>
              <span class="message-time">{{ formatTime(msg.created_at) }}</span>
            </div>
            <div class="message-content">{{ msg.content }}</div>
          </div>
        </div>

        <div class="chat-input">
          <a-input
            v-model:value="newMessage"
            placeholder="输入消息..."
            @pressEnter="sendMessage"
            size="large"
          >
            <template #suffix>
              <a-button type="primary" size="large" @click="sendMessage"
                >发送</a-button
              >
            </template>
          </a-input>
        </div>
      </div>
    </a-drawer>

    <!-- 评论弹窗 -->
    <a-modal
      v-model:visible="showComments"
      title="课程评论"
      :footer="null"
      width="100%"
      wrap-class-name="full-modal"
    >
      <CourseComments :course-id="courseId" />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from "vue";
import { useRoute } from "vue-router";
import { message, Modal } from "ant-design-vue";
import {
  UploadOutlined,
  PlusOutlined,
  MessageOutlined,
  StopOutlined,
  CommentOutlined,
} from "@ant-design/icons-vue";
import { io } from "socket.io-client";
import axios from "axios";
import dayjs from "dayjs";
import CourseComments from "@/components/Course/CourseComments.vue";

const route = useRoute();
const courseId = route.params.id;
const isTeacher = ref(localStorage.getItem("role") === "teacher");
const loading = ref(false);
const courseInfo = ref({});
const taskList = ref([]);

// 用户相关
const role = ref(localStorage.getItem("role"));
const studentId = ref("");
const teacherId = ref("");

// 聊天室相关
const showChat = ref(false);
const messages = ref([]);
const newMessage = ref("");
const messageContainer = ref(null);
const socket = ref(null);

// 表格列定义
const taskColumns = [
  {
    title: "标题",
    dataIndex: "title",
    width: "25%",
  },
  {
    title: "权重",
    dataIndex: "weight",
    width: "10%",
    customRender: ({ text }) => `${text}%`,
  },
  {
    title: "时间范围",
    dataIndex: "time",
    width: "25%",
  },
  {
    title: "状态",
    dataIndex: "status",
    width: "15%",
  },
  {
    title: "提交人数",
    dataIndex: "submission_count",
    width: "10%",
  },
  {
    title: "操作",
    dataIndex: "action",
    width: "15%",
  },
];

// 任务表单相关
const taskModalVisible = ref(false);
const submitting = ref(false);
const editingTask = ref(null);
const taskFormRef = ref(null);
const fileList = ref([]);

const taskForm = ref({
  title: "",
  description: "",
  weight: 0,
  timeRange: [],
  attachment_url: "",
  status: "active",
});

const taskRules = {
  title: [{ required: true, message: "请输入任务标题" }],
  description: [{ required: true, message: "请输入任务描述" }],
  weight: [{ required: true, message: "请输入任务权重" }],
  timeRange: [{ required: true, message: "请选择时间范围" }],
};

// 任务详情相关
const taskDetailVisible = ref(false);
const currentTask = ref(null);

// 获取课程信息
const fetchCourseInfo = async () => {
  try {
    const { data } = await axios.get(`/course/${courseId}`);
    if (data.success) {
      courseInfo.value = data.data;
    }
  } catch (error) {
    console.error("获取课程信息失败:", error);
    message.error("获取课程信息失败");
  }
};

// 获取教学任务列表
const fetchTaskList = async () => {
  loading.value = true;
  try {
    const { data } = await axios.get(`/course/${courseId}/tasks`);
    if (data.success) {
      taskList.value = data.data;
    }
  } catch (error) {
    console.error("获取教学任务列表失败:", error);
    message.error("获取教学任务列表失败");
  } finally {
    loading.value = false;
  }
};

// 显示创建任务弹窗
const showCreateTaskModal = () => {
  editingTask.value = null;
  taskForm.value = {
    title: "",
    description: "",
    weight: 0,
    timeRange: [],
    attachment_url: "",
    status: "active",
  };
  fileList.value = [];
  taskModalVisible.value = true;
};

// 显示编辑任务弹窗
const showEditTaskModal = (task) => {
  editingTask.value = task;
  taskForm.value = {
    title: task.title,
    description: task.description,
    weight: task.weight,
    timeRange: [dayjs(task.start_time), dayjs(task.end_time)],
    attachment_url: task.attachment_url,
    status: task.status,
  };
  if (task.attachment_url) {
    fileList.value = [
      {
        uid: "-1",
        name: task.attachment_url.split("/").pop(),
        status: "done",
        url: task.attachment_url,
      },
    ];
  } else {
    fileList.value = [];
  }
  taskModalVisible.value = true;
};

// 提交任务表单
const handleTaskSubmit = async () => {
  try {
    await taskFormRef.value.validate();
    submitting.value = true;

    const formData = {
      course_id: courseId,
      title: taskForm.value.title,
      description: taskForm.value.description,
      weight: taskForm.value.weight,
      attachment_url: taskForm.value.attachment_url,
      start_time: taskForm.value.timeRange[0],
      end_time: taskForm.value.timeRange[1],
      status: taskForm.value.status,
    };

    if (editingTask.value) {
      // 更新任务
      await axios.put(`/task/${editingTask.value.task_id}`, formData);
      message.success("更新教学任务成功");
    } else {
      // 创建任务
      await axios.post("/task", formData);
      message.success("创建教学任务成功");
    }

    taskModalVisible.value = false;
    fetchTaskList();
  } catch (error) {
    console.error("提交教学任务失败:", error);
    message.error(error.response?.data?.message || "提交失败");
  } finally {
    submitting.value = false;
  }
};

// 删除任务
const deleteTask = async (taskId) => {
  try {
    await axios.delete(`/task/${taskId}`);
    message.success("删除教学任务成功");
    fetchTaskList();
  } catch (error) {
    console.error("删除教学任务失败:", error);
    message.error(error.response?.data?.message || "删除失败");
  }
};

// 查看任务详情
const viewTaskDetail = async (task) => {
  try {
    const { data } = await axios.get(`/task/${task.task_id}`);
    if (data.success) {
      currentTask.value = data.data;
      if (isTeacher.value) {
        await fetchSubmissionList(task.task_id);
      } else {
        // 获取学生的提交记录
        const submissionRes = await axios.get(
          `/task/${task.task_id}/my-submission`,
          {
            headers: {
              "x-student-id": studentId.value,
            },
          }
        );
        if (submissionRes.data.success) {
          currentTask.value.submission = submissionRes.data.data;
        }
      }
      taskDetailVisible.value = true;
    }
  } catch (error) {
    console.error("获取任务详情失败:", error);
    message.error("获取任务详情失败");
  }
};

// 学生提交作业
const submitAssignment = async () => {
  try {
    if (!studentId.value) {
      message.error("请先登录");
      return;
    }

    if (!submissionForm.value.content) {
      message.error("请输入作业内容");
      return;
    }

    if (!currentTask.value || !currentTask.value.task_id) {
      message.error("无效的任务ID");
      return;
    }

    // 创建 FormData 对象
    const formData = new FormData();

    // 添加任务ID和内容
    formData.append("task_id", String(currentTask.value.task_id));
    formData.append("submission_content", submissionForm.value.content);

    // 如果有文件，添加到 FormData
    if (
      submissionFileList.value.length > 0 &&
      submissionFileList.value[0].originFileObj
    ) {
      formData.append("file", submissionFileList.value[0].originFileObj);
    }

    console.log("提交作业数据:", {
      task_id: currentTask.value.task_id,
      student_id: studentId.value,
      content: submissionForm.value.content,
      file: submissionFileList.value[0]?.name,
    });

    const response = await axios.post("/task-submission", formData, {
      headers: {
        "x-student-id": studentId.value,
        "Content-Type": "multipart/form-data",
      },
    });

    if (response.data.success) {
      message.success("作业提交成功");
      // 清空表单
      submissionForm.value = {
        content: "",
        attachment_url: "",
      };
      submissionFileList.value = [];
      // 刷新任务详情
      viewTaskDetail(currentTask.value);
    } else {
      message.error(response.data.message || "提交失败");
    }
  } catch (error) {
    console.error("提交作业失败:", error);
    console.error("错误响应:", error.response?.data);
    message.error(error.response?.data?.message || "提交失败");
  }
};

// 教师获取提交列表
const fetchSubmissionList = async (taskId) => {
  submissionLoading.value = true;
  try {
    const { data } = await axios.get(`/task/${taskId}/submissions`);
    if (data.success) {
      submissionList.value = data.data.map((item) => ({
        ...item,
        tempScore: null,
        tempFeedback: "",
      }));
    }
  } catch (error) {
    console.error("获取提交列表失败:", error);
    message.error("获取提交列表失败");
  } finally {
    submissionLoading.value = false;
  }
};

// 教师评分
const gradeSubmission = async (submission) => {
  try {
    await axios.put(`/task-submission/${submission.submission_id}`, {
      score: submission.tempScore,
      feedback: submission.tempFeedback,
    });
    message.success("评分成功");
    fetchSubmissionList(currentTask.value.task_id);
  } catch (error) {
    console.error("评分失败:", error);
    message.error(error.response?.data?.message || "评分失败");
  }
};

// 下载提交的作业
const downloadSubmission = (submission) => {
  window.open(`http://localhost:8088${submission.attachment_url}`, "_blank");
};

// 文件上传相关
const beforeSubmissionUpload = (file) => {
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    message.error("文件必须小于2MB!");
    return false;
  }
  return false; // 阻止自动上传
};

const handleSubmissionRemove = () => {
  submissionForm.value.attachment_url = "";
  submissionFileList.value = [];
  return true;
};

// 教师任务附件上传
const beforeUpload = async (file) => {
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    message.error("文件必须小于2MB!");
    return false;
  }

  try {
    const formData = new FormData();
    formData.append("file", file);

    const response = await axios.post("/upload/task-file", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    if (response.data.success) {
      taskForm.value.attachment_url = response.data.data.url;
      fileList.value = [
        {
          uid: "-1",
          name: response.data.data.name,
          status: "done",
          url: response.data.data.url,
        },
      ];
    } else {
      message.error("文件上传失败");
    }
  } catch (error) {
    console.error("文件上传失败:", error);
    message.error("文件上传失败");
  }

  return false;
};

const handleRemove = () => {
  taskForm.value.attachment_url = "";
  fileList.value = [];
  return true;
};

// 格式化日期
const formatDate = (date) => {
  return dayjs(date).format("YYYY-MM-DD HH:mm");
};

// 处理任务附件下载链接
const getAttachmentUrl = (url) => {
  if (!url) return "";
  return `http://localhost:8088${url}`;
};

// 在 script setup 中添加新的数据和方法
const submissionForm = ref({
  content: "",
  attachment_url: "",
});

const submissionFileList = ref([]);
const submissionList = ref([]);
const submissionLoading = ref(false);

const submissionColumns = [
  {
    title: "学生姓名",
    dataIndex: "student_name",
    width: "15%",
  },
  {
    title: "提交时间",
    dataIndex: "submitted_at",
    width: "20%",
    customRender: ({ text }) => formatDate(text),
  },
  {
    title: "分数",
    dataIndex: "score",
    width: "15%",
  },
  {
    title: "反馈",
    dataIndex: "feedback",
    width: "30%",
  },
  {
    title: "操作",
    dataIndex: "action",
    width: "20%",
  },
];

// 初始化用户信息
const initUserInfo = () => {
  console.log("localStorage 内容:", {
    role: localStorage.getItem("role"),
    userId: localStorage.getItem("userId"),
    teacherId: localStorage.getItem("teacherId"),
    teacher_id: localStorage.getItem("teacher_id"),
  });

  role.value = localStorage.getItem("role");

  // 如果是学生角色,设置学生ID
  if (role.value === "student") {
    studentId.value =
      localStorage.getItem("userId") ||
      localStorage.getItem("student_id") ||
      localStorage.getItem("studentId");

    console.log("当前学生ID:", studentId.value);

    if (!studentId.value) {
      message.warning("未找到学生信息,请重新登录");
    }
  } else if (role.value === "teacher") {
    // 如果是教师角色，设置教师ID
    teacherId.value =
      localStorage.getItem("userId") ||
      localStorage.getItem("teacher_id") ||
      localStorage.getItem("teacherId");

    console.log("当前教师ID:", teacherId.value);

    if (!teacherId.value) {
      message.warning("未找到教师信息,请重新登录");
    }
  }
};

// 聊天室相关方法
const scrollToBottom = () => {
  if (messageContainer.value) {
    setTimeout(() => {
      messageContainer.value.scrollTop = messageContainer.value.scrollHeight;
    }, 100);
  }
};

const connectSocket = () => {
  socket.value = io("http://localhost:8088", {
    transports: ["websocket"],
  });

  socket.value.on("connect", () => {
    console.log("WebSocket连接成功");
    socket.value.emit("joinRoom", {
      courseId: courseInfo.value.course_id,
      userId: role.value === "student" ? studentId.value : teacherId.value,
      userType: role.value,
    });
  });

  socket.value.on("history", (data) => {
    messages.value = data;
    scrollToBottom();
  });

  socket.value.on("message", (msg) => {
    messages.value.push(msg);
    scrollToBottom();
  });

  socket.value.on("error", (error) => {
    console.error("WebSocket错误:", error);
    message.error(error.message || "发送消息失败");
  });
};

const sendMessage = () => {
  if (!newMessage.value.trim()) return;

  socket.value.emit("message", {
    courseId: courseInfo.value.course_id,
    userId: role.value === "student" ? studentId.value : teacherId.value,
    userType: role.value,
    content: newMessage.value.trim(),
  });

  newMessage.value = "";
};

const isMyMessage = (msg) => {
  const currentUserId =
    role.value === "student" ? studentId.value : teacherId.value;
  return msg.sender_id === currentUserId && msg.sender_type === role.value;
};

const formatTime = (timestamp) => {
  const date = new Date(timestamp);
  return date.toLocaleString("zh-CN", {
    hour: "2-digit",
    minute: "2-digit",
  });
};

// 监听聊天室显示状态
watch(showChat, (newVal) => {
  if (newVal && !socket.value) {
    connectSocket();
  }
});

// 组卸载时断开连接
onUnmounted(() => {
  if (socket.value) {
    socket.value.emit("leaveRoom", {
      courseId: courseInfo.value.course_id,
    });
    socket.value.disconnect();
  }
});

onMounted(() => {
  initUserInfo(); // 初始化用户信息
  fetchCourseInfo();
  fetchTaskList();
});

// 添加结束课程的方法
const handleEndCourse = () => {
  Modal.confirm({
    title: "确认结束课程",
    content:
      "结束课程后，学生将无法继续提交作业，且无法进行选课操作。确定要结束课程吗？",
    okText: "确定",
    cancelText: "取消",
    onOk: async () => {
      try {
        const response = await axios.post(`/course/${courseId}/end`);
        if (response.data.success) {
          message.success("课程已结束");
          fetchCourseInfo(); // 刷新课程信息
        }
      } catch (error) {
        console.error("结束课程失败:", error);
        message.error(error.response?.data?.message || "结束课程失败");
      }
    },
  });
};

// 添加评论弹窗状态
const showComments = ref(false);
</script>

<style lang="less" scoped>
.course-detail {
  padding: 24px;
  background: #f0f2f5;
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;

  h2 {
    margin: 0;
  }

  .action-buttons {
    display: flex;
    gap: 8px;
  }
}

.task-list {
  margin-top: 24px;

  h3 {
    margin-bottom: 16px;
  }
}

.action-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
}

.task-detail {
  h3 {
    margin-bottom: 16px;
    color: #1890ff;
  }

  .task-info {
    p {
      margin-bottom: 12px;
      line-height: 1.5;

      strong {
        margin-right: 8px;
        color: #666;
      }
    }
  }
}

.chat-room {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #f7f7f7;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  margin-bottom: 0;
}

.message {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  animation: fadeIn 0.3s ease-in-out;
  width: 100%;
}

.my-message {
  align-items: flex-end;
}

.message:not(.my-message) {
  align-items: flex-start;
}

.message-header {
  margin-bottom: 8px;
  font-size: 14px;
  color: rgba(0, 0, 0, 0.65);
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 12px;
}

.my-message .message-header {
  flex-direction: row-reverse;
}

.sender-name {
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
}

.message-time {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.45);
}

.message-content {
  background: #fff;
  padding: 12px 16px;
  border-radius: 12px;
  word-break: break-word;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  font-size: 15px;
  line-height: 1.6;
  display: inline-block;
  max-width: 80%;
  min-width: 60px;
}

.my-message .message-content {
  background: #1890ff;
  color: #fff;
  border-top-right-radius: 4px;
}

.message:not(.my-message) .message-content {
  background: #fff;
  color: #333;
  border-top-left-radius: 4px;
}

.chat-input {
  padding: 16px 24px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
}

.chat-input :deep(.ant-input) {
  border-radius: 4px;
  padding: 8px 12px;
  font-size: 15px;
}

.chat-input :deep(.ant-input-group-addon) {
  padding: 0;
  background: transparent;
}

.chat-input :deep(.ant-btn) {
  border: none;
  height: 100%;
  padding: 0 24px;
  font-size: 15px;
}
.full-modal {
  .ant-modal {
    max-width: 100%;
    top: 0;
    padding-bottom: 0;
    margin: 0;
  }
  .ant-modal-content {
    display: flex;
    flex-direction: column;
    height: calc(100vh);
  }
  .ant-modal-body {
    flex: 1;
  }
}
</style>
