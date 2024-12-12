<template>
  <div class="course-schedule">
    <FullCalendar
      v-if="show"
      :options="calendarOptions"
      class="course-calendar"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";
import FullCalendar from "@fullcalendar/vue3";
import timeGridPlugin from "@fullcalendar/timegrid";
import zhCnLocale from "@fullcalendar/core/locales/zh-cn";

// 时间段配置
const TIME_SLOTS = {
  morning: { start: "08:00:00", end: "11:45:00" }, // 上午 1-4节
  afternoon: { start: "14:00:00", end: "17:45:00" }, // 下午 5-8节
  evening: { start: "18:30:00", end: "22:15:00" }, // 晚上 9-12节
};
const show = ref(true);
const reRender = () => {
  show.value = false;
  setTimeout(() => {
    show.value = true;
  }, 300);
};
// 将数据库中的节次转换为具体时间
const getSectionTime = (startSection) => {
  if (startSection <= 4) {
    return {
      start: addMinutes("08:00:00", (startSection - 1) * 45),
      period: "morning",
    };
  } else if (startSection <= 8) {
    return {
      start: addMinutes("14:00:00", (startSection - 5) * 45),
      period: "afternoon",
    };
  } else {
    return {
      start: addMinutes("18:30:00", (startSection - 9) * 45),
      period: "evening",
    };
  }
};

// 时间计算辅助函数
const addMinutes = (time, minutes) => {
  const [hours, mins] = time.split(":").map(Number);
  const totalMinutes = hours * 60 + mins + minutes;
  const newHours = Math.floor(totalMinutes / 60);
  const newMins = totalMinutes % 60;
  return `${String(newHours).padStart(2, "0")}:${String(newMins).padStart(
    2,
    "0"
  )}:00`;
};

// 转换课程数据日历事件
const transformCourseToEvent = (course) => {
  const { start, period } = getSectionTime(course.start_section);
  const duration = course.section_count * 45; // 每节课45分钟

  const event = {
    id: course.course_id,
    title: course.subject_name,
    startTime: start,
    endTime: addMinutes(start, duration),
    daysOfWeek: [course.week_day],
    extendedProps: {
      teacher: course.teacher_name,
      classroom: course.classroom,
      section: `第${course.start_section}-${
        course.start_section + course.section_count - 1
      }节`,
      student_count: course.student_count,
      max_students: course.max_students,
      capacity: true,
    },
  };
  return event;
};

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
    default: false
  }
})

const calendarOptions = ref({
  plugins: [timeGridPlugin],
  initialView: "timeGridWeek",
  locale: zhCnLocale,
  firstDay: 1,
  weekends: false,
  slotMinTime: TIME_SLOTS.morning.start,
  slotMaxTime: TIME_SLOTS.evening.end,
  slotDuration: "00:45:00",
  allDaySlot: false,
  headerToolbar: {
    left: "title",
    center: "",
    right: "prev,next",
  },
  slotLabelFormat: {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  },
  events: [], // 将通过API获取数据
  eventContent: (arg) => {
    const capacity = arg.event.extendedProps.capacity
      ? `(${arg.event.extendedProps.student_count}/${arg.event.extendedProps.max_students})`
      : "";

    return {
      html: `
        <div class="course-event">
          <div class="course-title">
            ${arg.event.title}
            <span class="capacity">${capacity}</span>
          </div>
          <div class="course-info">
            <span>${arg.event.extendedProps.teacher}</span>
            <span>${arg.event.extendedProps.section}</span>
          </div>
        </div>
      `,
    };
  },
});

// 获取课程数据
const fetchCourses = async () => {
  try {
    let url = "/api/courses/schedule"
    if (props.teacherId) {
      url = `/teacher-schedule/${props.teacherId}`
    } else if (props.studentId && props.classCourses) {
      url = `/class-courses/${props.studentId}`
    } else if (props.studentId) {
      url = `/student-schedule/${props.studentId}`
    }
    
    const response = await axios.get(url)
    if (response.data.success) {
      const events = response.data.data.map(transformCourseToEvent)
      calendarOptions.value.events = events
    }
  } catch (error) {
    console.error("获取课程表失败:", error)
    message.error("获取课程表失败")
  }
}

onMounted(() => {
  fetchCourses();
  nextTick(reRender);
});
</script>

<style lang="less" scoped>
.course-schedule {
  height: 800px;
  width: 100%;
  padding: 20px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);

  :deep(.fc) {
    width: 100%;
    height: 100%;
  }

  :deep(.fc-view-harness) {
    width: 100%;
    height: 100% !important;
  }

  :deep(.course-event) {
    padding: 4px;

    .course-title {
      font-weight: bold;
      margin-bottom: 4px;
    }

    .course-info {
      font-size: 12px;
      color: #666;

      span {
        margin-right: 8px;
      }
    }
  }

  :deep(.fc-timegrid-slot) {
    height: 45px !important;
  }

  :deep(.fc-timegrid-axis) {
    padding: 8px;
  }

  :deep(.capacity) {
    font-size: 12px;
    color: #666;
    margin-left: 8px;
  }
}

:deep(.fc-timegrid-slots) {
  table {
    width: 100% !important;
  }
}
:deep(.fc-timegrid-body) {
  width: 100% !important;
}
</style>
