<template>
  <div class="ai-assistant">
    <!-- 固定头部 -->
    <div class="chat-header">
      <div class="header-content">
        <span class="title"> <RobotOutlined /> AI 学习助手 </span>
      </div>
    </div>

    <!-- 可滚动的消息区域 -->
    <div class="chat-messages" ref="messagesContainer">
      <div
        v-for="(message, index) in messages"
        :key="index"
        :class="['message', message.message_type === 'user' ? 'user' : 'assistant']"
      >
        <div class="avatar">
          <a-avatar :size="40">
            <template #icon>
              <UserOutlined v-if="message.message_type === 'user'" />
              <RobotOutlined v-else />
            </template>
          </a-avatar>
        </div>
        <div class="message-wrapper">
          <div class="message-content">
            <div class="message-header">
              <span class="message-sender">{{
                message.message_type === "user" ? userName : "AI 助手"
              }}</span>
              <span class="message-time">{{
                formatTime(message.created_at)
              }}</span>
            </div>
            <div
              class="message-text"
              v-html="formatMessage(message.content)"
            ></div>
          </div>
        </div>
      </div>
      <div v-if="loading" class="message assistant">
        <div class="avatar">
          <a-avatar :size="40">
            <template #icon>
              <RobotOutlined />
            </template>
          </a-avatar>
        </div>
        <div class="message-wrapper">
          <div class="message-content thinking">
            <div class="message-header">
              <span class="message-sender">AI 助手</span>
              <span class="message-time">正在思考...</span>
            </div>
            <div class="message-text">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 固定底部输入区域 -->
    <div class="chat-footer">
      <div class="chat-input">
        <a-input
          v-model:value="inputMessage"
          placeholder="输入您的问题..."
          @keyup.enter="sendMessage"
          :disabled="loading"
          :maxLength="1000"
          allowClear
        >
          <template #suffix>
            <a-button type="primary" @click="sendMessage" :loading="loading">
              发送
            </a-button>
          </template>
        </a-input>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";
import { UserOutlined, RobotOutlined } from "@ant-design/icons-vue";
const DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions";
const DEEPSEEK_API_KEY = "sk-6459476f53e84604837f62f2d7b8ae1b";

const api = axios.create({
  timeout: 60000,
  headers: {
    "Content-Type": "application/json",
  },
});

const messages = ref([]);
const inputMessage = ref("");
const loading = ref(false);
const messagesContainer = ref(null);

const studentId = localStorage.getItem("userId");
const userName = localStorage.getItem("name") || "我";

const formatMessage = (content) => {
  if (!content) return "";
  // 将换行符转换为 <br>
  return content.replace(/\n/g, "<br>");
};

const loadChatHistory = async () => {
  try {
    const response = await api.get(`/ai/chat-history/${studentId}`);
    if (response.data.success) {
      messages.value = response.data.data;
      scrollToBottom();
    }
  } catch (error) {
    console.error("加载聊天历史失败:", error);
    message.error("加载聊天历史失败");
  }
};

const sendMessage = async () => {
  if (!inputMessage.value.trim() || loading.value) return;
  let msg = inputMessage.value;
  inputMessage.value = "";

  try {
    await api.post("/ai/send-message", {
      student_id: studentId,
      content: msg,
      creater: "user",
    });
    messages.value.push({
      chat_id: 9999999999,
      studentId,
      message_type: "user",
      content: msg,
      created_at: new Date().toString(),
    });
    scrollToBottom();
    const response = await fetch(DEEPSEEK_API_URL, {
      method: "POST",
      headers: {
        responseType: "stream",
        Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        messages: [{ role: "user", content: msg.trim() }],
        model: "deepseek-chat",
        stream: true,
      }),
    });

    const reader = response.body.getReader();
    let aiMessage = "";
    const curAImsg = {
      chat_id: 99999999999,
      studentId,
      message_type: "assistant",
      content: "",
      created_at: new Date().toString(),
    };
    messages.value.push(curAImsg);
    while (true) {
      const wtf = await reader.read();

      const { done, value } = wtf;
      console.log(wtf, new TextDecoder().decode(value));

      if (done) {
        await api.post("/ai/send-message", {
          student_id: studentId,
          content: aiMessage,
          creater: "assistant",
        });
        loadChatHistory();
        break;
      }

      const text = new TextDecoder().decode(value);

      // 按行分割字符串
      const lines = text.split("\n");

      // 逐行解析 JSON
      const parsedData = [];
      for (const line of lines) {
        // 去掉前缀 "data: "
        const jsonStr = line.replace(/^data: /, "");

        // 如果是空行，跳过
        if (jsonStr.trim() === "") continue;

        try {
          // 解析 JSON
          const data = JSON.parse(jsonStr);
          parsedData.push(data);
        } catch (error) {
          console.error("解析 JSON 失败:", error);
        }
      }

      // 输出解析后的数据
      console.log("解析后的数据:", parsedData);
      scrollToBottom();
      parsedData.forEach((data) => {
        data?.choices?.forEach((choice) => {
          aiMessage += choice.delta.content;
        });
      });
      messages.value[messages.value.length - 1].content = aiMessage;
    }

    return;
  } catch (error) {
    console.error("发送消息失败:", error);
    if (error.code === "ECONNABORTED") {
      message.error("请求超时，请稍后重试");
    } else {
      message.error("发送消息失败");
    }
  } finally {
    loading.value = false;
  }
};

const formatTime = (timestamp) => {
  if (!timestamp) return "";
  const date = new Date(timestamp);
  return date.toLocaleTimeString("zh-CN", {
    hour: "2-digit",
    minute: "2-digit",
  });
};

const scrollToBottom = async () => {
  await nextTick();
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  }
};

onMounted(() => {
  loadChatHistory();
});
</script>

<style scoped>
.ai-assistant {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f5f5;
}

.chat-header {
  height: 64px;
  background-color: white;
  border-bottom: 1px solid #f0f0f0;
  padding: 0 24px;
  position: sticky;
  top: 0;
  z-index: 10;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.header-content {
  height: 100%;
  display: flex;
  align-items: center;
}

.title {
  font-size: 18px;
  font-weight: 600;
  color: #1890ff;
}

.title :deep(.anticon) {
  margin-right: 8px;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  background-color: #f5f5f5;
}

.chat-footer {
  background-color: white;
  border-top: 1px solid #f0f0f0;
  padding: 16px 24px;
  position: sticky;
  bottom: 0;
  z-index: 10;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.06);
}

.message {
  margin-bottom: 24px;
  display: flex;
  align-items: flex-start;
}

.message.user {
  flex-direction: row-reverse;
}

.message.assistant {
  flex-direction: row;
  justify-content: flex-start;
}

.avatar {
  margin: 0 12px;
  flex-shrink: 0;
}

.message-wrapper {
  max-width: 70%;
}

.message-content {
  padding: 12px 16px;
  border-radius: 12px;
  background-color: white;
  position: relative;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.message.user .message-content {
  background-color: #1890ff;
  color: white;
}

.message.user .message-content::after {
  content: "";
  position: absolute;
  right: -8px;
  top: 12px;
  border-style: solid;
  border-width: 8px 0 8px 8px;
  border-color: transparent transparent transparent #1890ff;
}

.message.assistant .message-content::after {
  content: "";
  position: absolute;
  left: -8px;
  top: 12px;
  border-style: solid;
  border-width: 8px 8px 8px 0;
  border-color: transparent white transparent transparent;
}

.message-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 12px;
}

.message.user .message-header {
  color: rgba(255, 255, 255, 0.85);
}

.message-sender {
  font-weight: 500;
}

.message-time {
  opacity: 0.7;
}

.message-text {
  word-wrap: break-word;
  line-height: 1.5;
}

.chat-input {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
}

:deep(.ant-input-affix-wrapper) {
  border-radius: 24px;
  padding: 8px 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

:deep(.ant-btn) {
  border-radius: 20px;
  margin-left: 8px;
  height: 32px;
}

/* 打字动画效果 */
.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 4px 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background-color: #a0a0a0;
  border-radius: 50%;
  animation: typing 1s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) {
  animation-delay: 0.2s;
}
.typing-indicator span:nth-child(2) {
  animation-delay: 0.4s;
}
.typing-indicator span:nth-child(3) {
  animation-delay: 0.6s;
}

@keyframes typing {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.thinking {
  min-width: 100px;
}

/* 滚动条样式 */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
