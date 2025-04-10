const pool = require('../config/database')

const studentCourseController = {
  // 获取学生的课程列表
  async getStudentCourses(ctx) {
    try {
      const { student_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.credits,
          s.class_hours,
          t.teacher_id,
          t.name as teacher_name,
          t.title as teacher_title,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          c.section_count,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
          CAST(cs.status AS SIGNED) as status,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
            WHEN '6' THEN '周六'
            WHEN '7' THEN '周日'
          END as week_day_text,
          CASE c.start_section
            WHEN 1 THEN '08:00-09:30'
            WHEN 2 THEN '09:40-11:10'
            WHEN 3 THEN '14:00-15:30'
            WHEN 4 THEN '15:40-17:10'
            WHEN 5 THEN '18:00-19:30'
            WHEN 6 THEN '19:40-21:10'
          END as time_text
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE cs.student_id = ?
        ORDER BY c.week_day, c.start_section
      `, [student_id])

      // 处理教室显示格式
      const formattedRows = rows.map(row => ({
        ...row,
        classroom_display: row.classroom_id ? 
          `${row.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${row.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` : 
          '待定',
        course_time: `${row.week_day_text} ${row.time_text}`
      }))

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取学生课程列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 添加选课方法
  async enrollCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已经选过这门课
      const [existing] = await pool.execute(
        'SELECT * FROM CourseSelection WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      )

      if (existing.length > 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '已经选过这门课程'
        }
        return
      }

      // 检查课程是否存在且未满
      const [courses] = await pool.execute(`
        SELECT student_count, max_students 
        FROM Course 
        WHERE course_id = ?
      `, [course_id])

      if (courses.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '课程不存在'
        }
        return
      }

      const course = courses[0]
      if (course.student_count >= course.max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '课程已满'
        }
        return
      }

      // 添加选课记录
      await pool.execute(
        'INSERT INTO CourseSelection (student_id, course_id, status) VALUES (?, ?, 0)',
        [student_id, course_id]
      )

      // 更新课程人数
      await pool.execute(
        'UPDATE Course SET student_count = student_count + 1 WHERE course_id = ?',
        [course_id]
      )

      ctx.body = {
        success: true,
        message: '选课成功'
      }
    } catch (error) {
      console.error('选课错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 添加课程评价方法
  async evaluateCourse(ctx) {
    try {
      const { student_id, course_id, teacher_id, rating, content } = ctx.request.body;

      // 检查课程状态
      const [courseStatus] = await pool.execute(
        'SELECT status FROM CourseSelection WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      );

      if (courseStatus.length === 0) {
        ctx.status = 404;
        ctx.body = {
          success: false,
          message: '未找到该选课记录'
        };
        return;
      }

      if (courseStatus[0].status === 0) {
        ctx.status = 400;
        ctx.body = {
          success: false,
          message: '课程尚未结束，不能评价'
        };
        return;
      }

      if (courseStatus[0].status === 2) {
        ctx.status = 400;
        ctx.body = {
          success: false,
          message: '已经评价过该课程'
        };
        return;
      }

      // 开启事务
      const connection = await pool.getConnection();
      await connection.beginTransaction();

      try {
        // 插入评价
        await connection.execute(
          'INSERT INTO CourseEvaluation (student_id, course_id, teacher_id, rating, content) VALUES (?, ?, ?, ?, ?)',
          [student_id, course_id, teacher_id, rating, content]
        );

        // 更新选课状态为已评价
        await connection.execute(
          'UPDATE CourseSelection SET status = 2 WHERE student_id = ? AND course_id = ?',
          [student_id, course_id]
        );

        await connection.commit();

        ctx.body = {
          success: true,
          message: '评价提交成功'
        };
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error('提交课程评价错误:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '服务器错误'
      };
    }
  },

  // 获取推荐课程
  async getRecommendedCourses(ctx) {
    try {
      const { student_id } = ctx.params;

      // 1. 获取学生已选课程的学科类型分布
      const [studentSubjects] = await pool.execute(`
        SELECT DISTINCT s.subject_id, s.subject_name
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        WHERE cs.student_id = ?
      `, [student_id]);

      // 2. 获取学生所在班级的热门课程
      const [classCourses] = await pool.execute(`
        SELECT c.course_id, COUNT(*) as selection_count
        FROM Student s1
        JOIN Student s2 ON s1.class_id = s2.class_id
        JOIN CourseSelection cs ON s2.student_id = cs.student_id
        JOIN Course c ON cs.course_id = c.course_id
        WHERE s1.student_id = ?
        GROUP BY c.course_id
        ORDER BY selection_count DESC
        LIMIT 5
      `, [student_id]);

      // 3. 获取可选课程，排除已选的课程
      const [availableCourses] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.credits,
          t.name as teacher_name,
          t.title as teacher_title,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          CONCAT(cl.building, cl.room_number) as classroom_name,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
          END as week_day_text,
          CASE c.start_section
            WHEN 1 THEN '08:00-09:30'
            WHEN 2 THEN '09:40-11:10'
            WHEN 3 THEN '14:00-15:30'
            WHEN 4 THEN '15:40-17:10'
            WHEN 5 THEN '18:00-19:30'
            WHEN 6 THEN '19:40-21:10'
          END as time_text
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE c.course_id NOT IN (
          SELECT course_id FROM CourseSelection WHERE student_id = ?
        )
        AND c.student_count < c.max_students
      `, [student_id]);

      // 4. 根据以下规则推荐课程：
      // - 优先推荐同班同学选择较多的课程
      // - 保持学科多样性
      // - 加入一定随机性
      const recommendedCourses = [];
      const popularCourseIds = new Set(classCourses.map(c => c.course_id));
      
      // 添加热门课程
      availableCourses.forEach(course => {
        if (popularCourseIds.has(course.course_id)) {
          course.recommendation_reason = '同班同学热选课程';
          recommendedCourses.push(course);
        }
      });

      // 添加一些随机课程，确保推荐课程的多样性
      const remainingCourses = availableCourses.filter(
        course => !popularCourseIds.has(course.course_id)
      );
      
      // 随机选择3门课程
      for (let i = 0; i < 3 && remainingCourses.length > 0; i++) {
        const randomIndex = Math.floor(Math.random() * remainingCourses.length);
        const course = remainingCourses.splice(randomIndex, 1)[0];
        course.recommendation_reason = '智能推荐';
        recommendedCourses.push(course);
      }

      // 处理教室显示格式
      const formattedCourses = recommendedCourses.map(course => ({
        ...course,
        classroom_display: course.classroom_name || '待定',
        course_time: `${course.week_day_text} ${course.time_text}`
      }));

      ctx.body = {
        success: true,
        data: formattedCourses
      };
    } catch (error) {
      console.error('获取推荐课程错误:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '服务器错误'
      };
    }
  }
}

module.exports = studentCourseController 