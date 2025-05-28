const pool = require('../config/database')

const courseController = {
  // 获取可选课程列表
  async getAvailableCourses(ctx) {
    try {
      const {
        student_id,
        subject_name,  // 课程名称关键字
        teacher_name,  // 教师名称关键字
        week_day,      // 上课星期
        start_section  // 上课节次
      } = ctx.query

      let sql = `
        SELECT 
          c.course_id,
          s.subject_name,
          s.class_hours,
          s.credits,
          t.name as teacher_name,
          t.title as teacher_title,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          c.section_count,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
          CASE 
            WHEN cs.student_id IS NOT NULL THEN true 
            ELSE false 
          END as is_selected,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
            WHEN '6' THEN '周六'
            WHEN '7' THEN '周日'
          END as week_day_text,
          CONCAT('第', c.start_section, '-', c.start_section + c.section_count - 1, '节') as section_text,
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
        LEFT JOIN CourseSelection cs ON c.course_id = cs.course_id AND cs.student_id = ?
        WHERE c.student_count < c.max_students
      `
      const params = [student_id]

      // 添加搜索条件
      if (subject_name) {
        sql += ` AND s.subject_name LIKE ?`
        params.push(`%${subject_name}%`)
      }

      if (teacher_name) {
        sql += ` AND t.name LIKE ?`
        params.push(`%${teacher_name}%`)
      }

      if (week_day) {
        sql += ` AND c.week_day = ?`
        params.push(week_day)
      }

      if (start_section) {
        sql += ` AND c.start_section = ?`
        params.push(start_section)
      }

      sql += ` ORDER BY c.week_day, c.start_section`

      const [rows] = await pool.execute(sql, params)

      // 处理教室显示格式
      const formattedRows = rows.map(row => ({
        ...row,
        classroom_display: row.classroom_id ?
          `${row.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${row.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` :
          '待定',
        course_time: `${row.week_day_text} ${row.time_text}`
      }));

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取可选课程列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 选课
  async selectCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已选
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

      // 检查课程容量
      const [course] = await pool.execute(
        'SELECT student_count, max_students FROM Course WHERE course_id = ?',
        [course_id]
      )

      if (course[0].student_count >= course[0].max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '课程已满'
        }
        return
      }

      // 获取要选的课程的上课时间
      const [targetCourse] = await pool.execute(`
        SELECT week_day, start_section, section_count
        FROM Course 
        WHERE course_id = ?
      `, [course_id])

      if (targetCourse.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '课程不存在'
        }
        return
      }

      // 获取学生已选课程的上课时间
      const [selectedCourses] = await pool.execute(`
        SELECT 
          c.week_day, 
          c.start_section, 
          c.section_count,
          s.subject_name
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        WHERE cs.student_id = ?
      `, [student_id])

      // 检查时间冲突
      const target = targetCourse[0]
      for (const selected of selectedCourses) {
        // 如果是同一天
        if (selected.week_day === target.week_day) {
          // 计算每门课的时间段
          const targetStart = target.start_section
          const targetEnd = target.start_section + target.section_count
          const selectedStart = selected.start_section
          const selectedEnd = selected.start_section + selected.section_count

          // 检查是否有重叠
          if (
            (targetStart >= selectedStart && targetStart < selectedEnd) || // 新课开始时间在已选课程时间段内
            (targetEnd > selectedStart && targetEnd <= selectedEnd) || // 新课结束时间在已选课程时间段内
            (targetStart <= selectedStart && targetEnd >= selectedEnd) // 新课完全包含已选课程时间段
          ) {
            ctx.status = 400
            ctx.body = {
              success: false,
              message: `与已选课程《${selected.subject_name}》时间冲突`
            }
            return
          }
        }
      }

      // 开始选课事务
      const connection = await pool.getConnection()
      await connection.beginTransaction()

      try {
        // 添加选课记录
        await connection.execute(
          'INSERT INTO CourseSelection (student_id, course_id, status) VALUES (?, ?, 0)',
          [student_id, course_id]
        )

        await connection.commit()

        ctx.body = {
          success: true,
          message: '选课成功'
        }
      } catch (err) {
        await connection.rollback()
        throw err
      } finally {
        connection.release()
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

  // 退课
  async dropCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已选这门课
      const [existing] = await pool.execute(
        'SELECT * FROM CourseSelection WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      )

      if (existing.length === 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '未选择这门课程'
        }
        return
      }

      // 开始退课事务
      const connection = await pool.getConnection()
      await connection.beginTransaction()

      try {
        // 删除选课记录
        await connection.execute(
          'DELETE FROM CourseSelection WHERE student_id = ? AND course_id = ?',
          [student_id, course_id]
        )

        await connection.commit()

        ctx.body = {
          success: true,
          message: '退课成功'
        }
      } catch (err) {
        await connection.rollback()
        throw err
      } finally {
        connection.release()
      }
    } catch (error) {
      console.error('退课错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取课程表数据
  async getSchedule(ctx) {
    try {
      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          t.name as teacher_name,
          c.week_day,
          c.start_section,
          c.section_count,
          c.class_hours
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        ORDER BY c.week_day, c.start_section
      `)

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取课程表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取教师课表数据
  async getTeacherSchedule(ctx) {
    try {
      const { teacher_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          t.name as teacher_name,
          c.week_day,
          c.start_section,
          c.section_count,
          c.class_hours,
          c.student_count,
          c.max_students,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
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
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE c.teacher_id = ?
        ORDER BY c.week_day, c.start_section
      `, [teacher_id])

      // 处理教室显示格式
      const formattedRows = rows.map(row => ({
        ...row,
        classroom_display: row.classroom_id ?
          `${row.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${row.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` :
          '待定',
        course_time: `${row.week_day_text} ${row.time_text}`
      }));

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取教师课表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取学生课表数据
  async getStudentSchedule(ctx) {
    try {
      const { student_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          t.name as teacher_name,
          c.week_day,
          c.start_section,
          c.section_count,
          c.class_hours,
          c.student_count,
          c.max_students,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
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
      }));

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取学生课表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取单个课程详情
  async getCourseDetail(ctx) {
    try {
      const { course_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.class_hours,
          s.credits,
          c.semester,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          c.section_count,
          t.name as teacher_name,
          t.title as teacher_title,
          CONCAT(cl.building, cl.room_number) as classroom_name,
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
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE c.course_id = ?
      `, [course_id])

      if (rows.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '课程不存在'
        }
        return
      }

      ctx.body = {
        success: true,
        data: rows[0]
      }
    } catch (error) {
      console.error('获取课程详情错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取学生班级的必修课程
  async getClassRequiredCourses(ctx) {
    try {
      const { student_id } = ctx.params

      // 获取学生所在班级的必修课程
      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          t.name as teacher_name,
          c.week_day,
          c.start_section,
          c.section_count,
          c.class_hours,
          c.student_count,
          c.max_students,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
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
        FROM Student stu
        JOIN CourseClass cc ON stu.class_id = cc.class_id
        JOIN Course c ON cc.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE stu.student_id = ?
        ORDER BY c.week_day, c.start_section
      `, [student_id])

      // 处理教室显示格式
      const formattedRows = rows.map(row => ({
        ...row,
        classroom_display: row.classroom_id ?
          `${row.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${row.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` :
          '待定',
        course_time: `${row.week_day_text} ${row.time_text}`
      }));

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取班级必修课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 应用班级课程表
  async applyClassCourses(ctx) {
    try {
      const { student_id } = ctx.request.body

      // 获取学生所在班级的必修课程
      const [classCourses] = await pool.execute(`
        SELECT c.* 
        FROM Student stu
        JOIN CourseClass cc ON stu.class_id = cc.class_id
        JOIN Course c ON cc.course_id = c.course_id
        WHERE stu.student_id = ?
      `, [student_id])

      // 获取学生已选课程
      const [selectedCourses] = await pool.execute(`
        SELECT 
          c.*,
          s.subject_name
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        WHERE cs.student_id = ?
      `, [student_id])

      // 检查时间冲突
      for (const classCourse of classCourses) {
        for (const selected of selectedCourses) {
          if (selected.week_day === classCourse.week_day) {
            const classStart = classCourse.start_section
            const classEnd = classCourse.start_section + classCourse.section_count
            const selectedStart = selected.start_section
            const selectedEnd = selected.start_section + selected.section_count

            if (
              (classStart >= selectedStart && classStart < selectedEnd) ||
              (classEnd > selectedStart && classEnd <= selectedEnd) ||
              (classStart <= selectedStart && classEnd >= selectedEnd)
            ) {
              ctx.status = 400
              ctx.body = {
                success: false,
                message: `班级课程与已选课程《${selected.subject_name}》时间冲突`
              }
              return
            }
          }
        }
      }

      // 开始选课事务
      const connection = await pool.getConnection()
      await connection.beginTransaction()

      try {
        // 批量插入选课记录
        for (const course of classCourses) {
          // 检查是否已选
          const [existing] = await connection.execute(
            'SELECT 1 FROM CourseSelection WHERE student_id = ? AND course_id = ?',
            [student_id, course.course_id]
          )

          if (existing.length === 0) {
            await connection.execute(
              'INSERT INTO CourseSelection (student_id, course_id, status) VALUES (?, ?, 0)',
              [student_id, course.course_id]
            )
          }
        }

        await connection.commit()

        ctx.body = {
          success: true,
          message: '班级课程应用成功'
        }
      } catch (err) {
        await connection.rollback()
        throw err
      } finally {
        connection.release()
      }
    } catch (error) {
      console.error('应用班级课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 结束课程
  async endCourse(ctx) {
    const { id } = ctx.params;
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      // 检查课程是否存在
      const [course] = await connection.query(
        'SELECT * FROM Course WHERE course_id = ?',
        [id]
      );

      if (course.length === 0) {
        ctx.status = 400;
        ctx.body = {
          success: false,
          message: '课程不存在'
        };
        return;
      }

      // 检查是否已经有学生选课
      const [selections] = await connection.query(
        'SELECT * FROM CourseSelection WHERE course_id = ?',
        [id]
      );

      if (selections.length === 0) {
        ctx.status = 400;
        ctx.body = {
          success: false,
          message: '该课程没有学生选课'
        };
        return;
      }

      // 更新所有选课记录的状态为已结束
      await connection.query(
        'UPDATE CourseSelection SET status = 1 WHERE course_id = ?',
        [id]
      );

      await connection.commit();
      ctx.body = {
        success: true,
        message: '课程已结束'
      };
    } catch (error) {
      await connection.rollback();
      console.error('结束课程失败:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '结束课程失败'
      };
    } finally {
      connection.release();
    }
  },

  // 获取课程评论
  async getCourseComments(ctx) {
    const { id } = ctx.params;

    try {
      const [comments] = await pool.query(`
        SELECT 
          e.evaluation_id as comment_id,
          e.rating,
          e.content,
          e.created_at,
          s.name as student_name
        FROM CourseEvaluation e
        JOIN Student s ON e.student_id = s.student_id
        WHERE e.course_id = ?
        ORDER BY e.created_at DESC
      `, [id]);

      ctx.body = {
        success: true,
        data: comments
      };
    } catch (error) {
      console.error('获取课程评论失败:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '获取课程评论失败'
      };
    }
  },

  // 工具：字段校验
  validateCourse(data) {
    const errors = []
    if (!data.subject_id) errors.push('课程名称必填')
    if (!data.teacher_id) errors.push('授课教师必填')
    if (!['16', '32', '48', '64'].includes(String(data.class_hours))) errors.push('学时必须为16/32/48/64')
    if (!data.credits || data.credits < 1 || data.credits > 6) errors.push('学分范围1-6')
    if (!['1', '2', '3', '4', '5', '6', '7'].includes(String(data.week_day))) errors.push('星期必须为1-7')
    if (!data.start_section || data.start_section < 1 || data.start_section > 6) errors.push('起始节1-6')
    if (!data.section_count || data.section_count < 1 || data.section_count > 3) errors.push('连续节数1-3')
    if (!data.classroom_id) errors.push('教室必填')
    if (!data.max_students || data.max_students < 1) errors.push('最大容量必填')
    return errors
  },

  // 管理员课程列表
  async adminListCourses(ctx) {
    try {
      const [rows] = await pool.query(`
        SELECT c.*, s.subject_name, t.name as teacher_name, cl.building, cl.room_number,
          CONCAT(cl.building, cl.room_number) as classroom_name
        FROM Course c
        LEFT JOIN Subject s ON c.subject_id = s.subject_id
        LEFT JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        ORDER BY c.course_id DESC
      `)
      ctx.body = { success: true, data: rows }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '获取课程失败' }
    }
  },

  // 管理员新增课程
  async adminCreateCourse(ctx) {
    const data = ctx.request.body
    try {
      // 生成主键
      const course_id = 'C' + Date.now()
      await pool.query(
        `INSERT INTO Course (course_id, subject_id, teacher_id, semester, student_count, max_students, classroom_id, class_hours, week_day, start_section, section_count)
         VALUES (?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?)`,
        [
          course_id, data.subject_id, data.teacher_id, 1, data.max_students, data.classroom_id,
          String(data.class_hours), String(data.week_day), data.start_section, data.section_count,
        ]
      )
      ctx.body = { success: true, message: '新增成功' }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '新增失败' }
    }
  },

  // 管理员编辑课程
  async adminUpdateCourse(ctx) {
    const { course_id } = ctx.params
    const data = ctx.request.body
    try {
      await pool.query(
        `UPDATE Course SET subject_id=?, teacher_id=?, max_students=?, classroom_id=?, class_hours=?, week_day=?, start_section=?, section_count=?
         WHERE course_id=?`,
        [
          data.subject_id, data.teacher_id, data.max_students, data.classroom_id,
          String(data.class_hours), String(data.week_day), data.start_section, data.section_count, course_id
        ]
      )
      ctx.body = { success: true, message: '编辑成功' }
    } catch (e) {
      console.log(e);

      ctx.status = 500
      ctx.body = { success: false, message: '编辑失败' }
    }
  },

  // 管理员删除课程
  async adminDeleteCourse(ctx) {
    const { course_id } = ctx.params
    try {
      await pool.query('DELETE FROM Course WHERE course_id=?', [course_id])
      ctx.body = { success: true, message: '删除成功' }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '删除失败' }
    }
  },

  // 获取所有课程（下拉用）
  async getAllSubjects(ctx) {
    try {
      const [rows] = await pool.query('SELECT subject_id, subject_name FROM Subject ORDER BY subject_name')
      ctx.body = { success: true, data: rows }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '获取课程列表失败' }
    }
  },

  // 获取所有教室（下拉用）
  async getAllClassrooms(ctx) {
    try {
      const [rows] = await pool.query('SELECT classroom_id, building, room_number FROM Classroom ORDER BY building, room_number')
      ctx.body = { success: true, data: rows }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '获取教室列表失败' }
    }
  }
}

module.exports = courseController 