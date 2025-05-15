<template>
  <div class="home-container">
    <div class="header">
      <h1 class="welcome-title">深圳北理莫斯科大学</h1>
    </div>

    <div class="nav-container">
      <div class="news-section">
        <h2>校园新闻</h2>
        <div class="news-list">
          <div class="news-item" v-for="item in news" :key="item.title">
            <img class="news-img" :src="item.img" alt="news" />
            <div class="news-main">
              <a
                class="news-title-link"
                :href="item.link"
                target="_blank"
                rel="noopener"
                >{{ item.title }}</a
              >
              <p class="news-content">{{ item.content }}</p>
              <span class="news-date">{{ item.date }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="notice-section">
        <h2>通知公告</h2>
        <div class="notice-list">
          <div class="notice-item" v-for="item in notices" :key="item.title">
            <div
              class="notice-date-circle"
              :class="item.important ? 'important' : ''"
            >
              <div class="notice-date-day">
                {{ item.date.split("-")[1] }}-{{ item.date.split("-")[2] }}
              </div>
              <div class="notice-date-year">{{ item.date.split("-")[0] }}</div>
            </div>
            <div class="notice-content">
              <div class="notice-title">{{ item.title }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";

const news = [
  {
    title: '深北莫语言系"罗蒙诺索夫-2025"国际青年学者论坛再启学术对话',
    content:
      '4月18日，莫斯科大学"罗蒙诺索夫-2025"国际青年学者论坛分论坛在深圳北理莫斯科大学举行。本次论坛设有"现代俄语"和"俄罗斯文学"两个分会场，采用线上线下相结合的形式，吸引了莫斯科大学、南联邦大学、白俄罗斯国立师范大学、北京大学、北京外国语大学等众多海内外知名高校的硕士、博士研究生参与。语言系俄方主任列杰涅夫、中方主任周兴武、副主任达尼利娜和部分任课教师出席本次论坛。',
    date: "2025-04-25",
    img: "https://www.smbu.edu.cn/__local/A/FF/C4/66BCA4AF6FA59D2B7BB5B32B324_69FF911E_12ABD.jpeg",
    link: "https://www.smbu.edu.cn/info/1031/109711.htm",
  },
  {
    title: 'SMBU国奖风采丨钟奇山：用模型和代码书写人文关怀的"六边形战士"',
    content:
      '深圳北理莫斯科大学始终坚持"立德为本、文化为魂、学术为基、实践为源"的人才培养理念，建立"文化润育、科学教育、创新实践"三位一体的高层次人才培养体系，构建中俄协同育人共同体，强化全过程质量保障。',
    date: "2025-04-23",
    img: "https://www.smbu.edu.cn/__local/6/F1/1E/A0D95248C2F96DEA80442D5CAA8_D6A96F83_5E68E.jpg",
    link: "https://www.smbu.edu.cn/info/1031/109561.htm",
  },
  {
    title: "深圳北理莫斯科大学成功举办2025国际中文日系列活动",
    content:
      '4月14-20日，谷雨时节之际，为迎接第16届联合国国际中文日，深圳北理莫斯科大学汉语中心、校语委办围绕"中文：穿越时空的礼物"这一主题精心策划了涵盖文化互动、谷雨雅集与中文才艺展演等多元形式的活动，充分展示了中文的独特魅力，为全校师生呈现了一场精彩绝伦的中华文化盛宴。',
    date: "2025-04-23",
    img: "https://www.smbu.edu.cn/__local/B/37/9B/ADCA91AE9751530572C0083DA29_913ABC7B_56FBB.jpg",
    link: "https://www.smbu.edu.cn/info/1031/109451.htm",
  },
];

const notices = [
  {
    date: "2024-11-05",
    title: "第三届BIT–SMBU机器人智能研究生论坛在深圳北理莫斯科大学举行",
    important: false,
  },
  {
    date: "2024-11-05",
    title: "第三届MSU–BIT–SMBU创新科技青年论坛在深圳北理莫斯科大学举行",
    important: false,
  },
  {
    date: "2024-11-03",
    title: "北京语言大学郑艳群教授应邀到深北莫开展专题讲座",
    important: true,
  },
];

const role = localStorage.getItem("role");
const welcomeMessage = computed(() => {
  return role === "teacher"
    ? "您可以在这里管理课程、成绩和学生信息"
    : "您可以在这里进行选课、查看成绩等操作";
});
</script>

<style scoped>
.home-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.welcome-title {
  font-size: 36px;
  color: #1890ff;
  margin-bottom: 8px;
}

.welcome-subtitle {
  font-size: 18px;
  color: rgba(0, 0, 0, 0.45);
}

.nav-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.quick-links {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.link-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-top: 20px;
}

.link-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
  text-decoration: none;
  color: #333;
  transition: all 0.3s;
}

.link-item:hover {
  background: #e6f7ff;
  transform: translateY(-2px);
}

.link-item i {
  font-size: 24px;
  margin-bottom: 8px;
  color: #1890ff;
}

.news-section,
.notice-section {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.news-list,
.notice-list {
  margin-top: 20px;
}

.news-item {
  display: flex;
  align-items: flex-start;
  padding: 24px 0;
  border-bottom: 1px solid #eee;
}

.news-item:last-child {
  border-bottom: none;
}

.news-img {
  width: 90px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
  margin-right: 20px;
  flex-shrink: 0;
}

.news-main {
  flex: 1;
}

.news-title-link {
  font-size: 17px;
  color: #1765d5;
  font-weight: 600;
  text-decoration: none;
  transition: color 0.2s;
}

.news-title-link:hover {
  color: #2a4fa1;
  text-decoration: underline;
}

.news-content {
  color: #666;
  margin: 8px 0 6px 0;
  font-size: 14px;
  line-height: 1.6;
}

.news-date {
  color: #999;
  font-size: 12px;
}

.notice-item {
  display: flex;
  align-items: center;
  padding: 24px 0;
  border-bottom: 1px solid #eee;
}

.notice-item:last-child {
  border-bottom: none;
}

.notice-date-circle {
  min-width: 80px;
  min-height: 80px;
  border-radius: 50%;
  border: 2px dashed #8cb6f7;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-right: 32px;
  color: #4686e6;
  font-weight: bold;
  background: #f7faff;
}

.notice-date-circle.important {
  border: 2px solid #2a4fa1;
  background: #2a4fa1;
  color: #fff;
}

.notice-date-day {
  font-size: 20px;
  line-height: 1.2;
}

.notice-date-year {
  font-size: 14px;
  line-height: 1.2;
}

.notice-content {
  flex: 1;
}

.notice-title {
  font-size: 18px;
  color: #222;
  font-weight: 500;
}

h2 {
  color: #333;
  font-size: 20px;
  margin: 0 0 20px 0;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}
</style>
