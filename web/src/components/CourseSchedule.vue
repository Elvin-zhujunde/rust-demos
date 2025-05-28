<template>
  <div class="course-schedule">
    <div class="schedule-actions">
      <a-button type="primary" @click="exportToExcel">
        <template #icon><DownloadOutlined /></template>
        导出课表
      </a-button>
    </div>

    <div class="schedule-header">
      <div class="time-column">时间</div>
      <div v-for="day in weekDays" :key="day.value" class="day-column">
        {{ day.label }}
      </div>
    </div>

    <div class="schedule-body">
      <!-- 上午时段 -->
      <div class="time-block morning">
        <div class="time-label">
          <div class="period-title">上午</div>
          <div class="time">08:00-09:30</div>
          <div class="divider"></div>
          <div class="time">09:40-11:10</div>
        </div>
        <template v-for="day in 5" :key="day">
          <div class="course-column">
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 1)"
                :course="getCourse(day, 1)"
              />
            </div>
            <div class="cell-divider"></div>
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 2)"
                :course="getCourse(day, 2)"
              />
            </div>
          </div>
          <div v-if="day < 5" class="column-divider"></div>
        </template>
      </div>

      <!-- 时间段分隔线 -->
      <div class="period-divider"></div>

      <!-- 下午时段 -->
      <div class="time-block afternoon">
        <div class="time-label">
          <div class="period-title">下午</div>
          <div class="time">14:00-15:30</div>
          <div class="divider"></div>
          <div class="time">15:40-17:10</div>
        </div>
        <template v-for="day in 5" :key="day">
          <div class="course-column">
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 3)"
                :course="getCourse(day, 3)"
              />
            </div>
            <div class="cell-divider"></div>
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 4)"
                :course="getCourse(day, 4)"
              />
            </div>
          </div>
          <div v-if="day < 5" class="column-divider"></div>
        </template>
      </div>

      <!-- 时间段分隔线 -->
      <div class="period-divider"></div>

      <!-- 晚上时段 -->
      <div class="time-block evening">
        <div class="time-label">
          <div class="period-title">晚上</div>
          <div class="time">18:00-19:30</div>
          <div class="divider"></div>
          <div class="time">19:40-21:10</div>
        </div>
        <template v-for="day in 5" :key="day">
          <div class="course-column">
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 5)"
                :course="getCourse(day, 5)"
              />
            </div>
            <div class="cell-divider"></div>
            <div class="course-cell">
              <CourseCard
                v-if="getCourse(day, 6)"
                :course="getCourse(day, 6)"
              />
            </div>
          </div>
          <div v-if="day < 5" class="column-divider"></div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { message } from "ant-design-vue";
import { DownloadOutlined } from '@ant-design/icons-vue';
import axios from "axios";
import CourseCard from "./CourseCard.vue";
import * as XLSX from 'xlsx';
import FileSaver from 'file-saver';

const weekDays = [
  { value: "1", label: "周一" },
  { value: "2", label: "周二" },
  { value: "3", label: "周三" },
  { value: "4", label: "周四" },
  { value: "5", label: "周五" },
];

const courses = ref([]);

const props = defineProps({
  teacherId: {
    type: String,
    required: false,
  },
  studentId: {
    type: String,
    required: false,
  },
  classCourses: {
    type: Boolean,
    default: false,
  },
});

// 获取指定日期和节次的课程
const getCourse = (day, section) => {
  return courses.value.find(
    (course) =>
      course.week_day === String(day) && course.start_section === section
  );
};

// 获取课程数据
const fetchCourses = async () => {
  try {
    let url = "/courses/schedule";
    if (props.teacherId) {
      url = `/teacher-schedule/${props.teacherId}`;
    } else if (props.studentId && props.classCourses) {
      url = `/class-courses/${props.studentId}`;
    } else if (props.studentId) {
      url = `/student-schedule/${props.studentId}`;
    }

    const response = await axios.get(url);
    if (response.data.success) {
      // 处理教室显示格式（如果后端没有处理）
      courses.value = response.data.data.map(course => ({
        ...course,
        classroom_display: course.classroom_id ? 
          `${course.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${course.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` : 
          '待定',
        course_time: `${course.week_day_text || ''} ${course.time_text || ''}`
      }));
    }
  } catch (error) {
    console.error("获取课程表失败:", error);
    message.error("获取课程表失败");
  }
};

// 生成Excel数据
const generateExcelData = () => {
  const timeSlots = {
    1: '08:00-09:30',
    2: '09:40-11:10',
    3: '14:00-15:30',
    4: '15:40-17:10',
    5: '18:00-19:30',
    6: '19:40-21:10'
  };

  // 创建一个5x6的空二维数组（5天x6节课）
  const scheduleMatrix = Array(6).fill().map(() => Array(5).fill(''));
  
  // 填充课程数据
  courses.value.forEach(course => {
    const dayIndex = parseInt(course.week_day) - 1;
    const timeIndex = course.start_section - 1;
    const classroom = course.classroom_id ? 
      `${course.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${course.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` : 
      '待定';
    scheduleMatrix[timeIndex][dayIndex] = 
      `${course.subject_name}\n${course.teacher_name}\n${classroom}`;
  });

  // 准备Excel数据
  const excelData = [
    ['时间', '周一', '周二', '周三', '周四', '周五'],
  ];

  // 添加每个时间段的数据
  Object.entries(timeSlots).forEach(([section, time]) => {
    const rowIndex = parseInt(section) - 1;
    excelData.push([
      time,
      ...scheduleMatrix[rowIndex]
    ]);
  });

  return excelData;
};

// 导出Excel
const exportToExcel = () => {
  try {
    const excelData = generateExcelData();
    
    // 创建工作簿
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(excelData);

    // 设置列宽
    const colWidth = Array(6).fill({ wch: 20 });
    ws['!cols'] = colWidth;

    // 添加工作表到工作簿
    XLSX.utils.book_append_sheet(wb, ws, '课程表');

    // 生成Excel文件
    const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
    const blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    
    // 下载文件
    const fileName = `课程表_${new Date().toLocaleDateString()}.xlsx`;
    FileSaver.saveAs(blob, fileName);

    message.success('课程表导出成功');
  } catch (error) {
    console.error('导出Excel失败:', error);
    message.error('导出Excel失败');
  }
};

onMounted(() => {
  fetchCourses();
});
</script>

<style lang="less" scoped>
.course-schedule {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  padding: 20px;
}

.schedule-header {
  display: flex;
  border-bottom: 1px solid #f0f0f0;

  .time-column {
    width: 120px;
    text-align: center;
    font-weight: bold;
    padding: 12px;
  }

  .day-column {
    flex: 1;
    text-align: center;
    font-weight: bold;
    padding: 12px;
  }
}

.schedule-body {
  .time-block {
    display: flex;
    border-bottom: 1px solid #f0f0f0;
    min-height: 120px;

    &:last-child {
      border-bottom: none;
    }

    .time-label {
      width: 120px;
      padding: 12px;
      text-align: center;
      background: #fafafa;
      border-right: 1px solid #f0f0f0;

      .period-title {
        font-weight: bold;
        margin-bottom: 8px;
        color: #1890ff;
      }

      .time {
        font-size: 12px;
        height: 65px;
        color: #666;
      }

      .divider {
        height: 1px;
        background-color: #f0f0f0;
        margin: 8px -12px;
      }
    }

    .course-column {
      flex: 1;
      display: flex;
      flex-direction: column;

      .course-cell {
        flex: 1;
        padding: 8px;
        min-height: 100px;
      }

      .cell-divider {
        height: 1px;
        background-color: #f0f0f0;
        margin: 0 8px;
      }
    }

    .column-divider {
      width: 1px;
      background-color: #f0f0f0;
    }
  }

  .period-divider {
    height: 8px;
    background-color: #f5f5f5;
    border-top: 1px solid #e8e8e8;
    border-bottom: 1px solid #e8e8e8;
  }
}

.course-card {
  background: #e6f7ff;
  border: 1px solid #91d5ff;
  border-radius: 4px;
  padding: 12px;
  height: 100%;
  transition: all 0.3s;

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    transform: translateY(-1px);
  }

  .course-title {
    font-weight: bold;
    margin-bottom: 8px;
    color: #0050b3;
  }

  .course-info {
    font-size: 12px;
    color: #666;

    span {
      display: block;
      margin-bottom: 4px;
    }

    .capacity {
      color: #1890ff;
    }
  }
}

.schedule-actions {
  margin-bottom: 16px;
  text-align: right;
}

// 确保按钮图标对齐
:deep(.anticon) {
  vertical-align: middle;
}
</style>
