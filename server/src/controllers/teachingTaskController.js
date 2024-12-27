const pool = require('../config/database')
const multer = require('multer')
const path = require('path')
const fs = require('fs')

// 确保上传目录存在
const uploadDir = path.join(__dirname, '../../public/uploads')
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

// 配置文件存储
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir)
  },
  filename: function (req, file, cb) {
    // 生成文件名: 时间戳-原始文件名
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
    const ext = path.extname(file.originalname)
    const filename = uniqueSuffix + ext
    cb(null, filename)
  }
})

// 文件上传中间件
const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 限制5MB
  }
}).single('file')

// 处理文件上传
const uploadFile = async (ctx) => {
  return new Promise((resolve, reject) => {
    upload(ctx.req, ctx.res, function (err) {
      if (err instanceof multer.MulterError) {
        // 处理 multer 错误
        reject(new Error('文件上传错��: ' + err.message))
      } else if (err) {
        // 处理其他错误
        reject(err)
      }
      
      if (!ctx.req.file) {
        reject(new Error('没有上传文件'))
        return
      }

      const filename = ctx.req.file.filename
      const filePath = `/uploads/${filename}`
      console.log('文件已上传:', {
        filename,
        filePath,
        originalname: ctx.req.file.originalname,
        size: ctx.req.file.size,
        fullPath: path.join(uploadDir, filename)
      })

      // 返回文件信息
      resolve({
        filename,
        filePath,
        originalname: ctx.req.file.originalname,
        mimetype: ctx.req.file.mimetype,
        size: ctx.req.file.size
      })
    })
  })
}

// 格式化日期时间为MySQL格式
const formatDateTime = (dateTimeStr) => {
  const date = new Date(dateTimeStr)
  return date.toISOString().slice(0, 19).replace('T', ' ')
}

// 获取课程的教学任务列表
const getTasksByCourse = async (ctx) => {
  try {
    const courseId = ctx.params.course_id
    const [tasks] = await pool.execute(`
      SELECT 
        t.task_id,
        t.title,
        t.description,
        t.weight,
        t.start_time,
        t.end_time,
        t.status,
        t.attachment_url,
        t.created_at,
        t.updated_at,
        s.subject_name,
        COUNT(ts.submission_id) as submission_count
      FROM TeachingTask t
      LEFT JOIN Course c ON t.course_id = c.course_id
      LEFT JOIN Subject s ON c.subject_id = s.subject_id
      LEFT JOIN TaskSubmission ts ON t.task_id = ts.task_id
      WHERE t.course_id = ?
      GROUP BY t.task_id
      ORDER BY t.start_time DESC
    `, [courseId])

    ctx.body = {
      success: true,
      data: tasks
    }
  } catch (error) {
    console.error('获取教学任务列表失败:', error)
    ctx.body = {
      success: false,
      message: '获取教学任务列表失败'
    }
  }
}

// 获取单个任务详情
const getTaskDetail = async (ctx) => {
  try {
    const taskId = ctx.params.task_id
    const [tasks] = await pool.execute(`
      SELECT 
        t.*,
        s.subject_name,
        COUNT(ts.submission_id) as submission_count
      FROM TeachingTask t
      LEFT JOIN Course c ON t.course_id = c.course_id
      LEFT JOIN Subject s ON c.subject_id = s.subject_id
      LEFT JOIN TaskSubmission ts ON t.task_id = ts.task_id
      WHERE t.task_id = ?
      GROUP BY t.task_id
    `, [taskId])

    if (tasks.length === 0) {
      ctx.body = {
        success: false,
        message: '任务不存在'
      }
      return
    }

    ctx.body = {
      success: true,
      data: tasks[0]
    }
  } catch (error) {
    console.error('获取任务详情失败:', error)
    ctx.body = {
      success: false,
      message: '获取任务详情失败'
    }
  }
}

// 创建新任务
const createTask = async (ctx) => {
  try {
    const {
      course_id,
      title,
      description,
      weight,
      start_time,
      end_time,
      attachment_url,
      status = 'active'
    } = ctx.request.body

    const [result] = await pool.execute(`
      INSERT INTO TeachingTask (
        course_id,
        title,
        description,
        weight,
        start_time,
        end_time,
        attachment_url,
        status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      course_id,
      title,
      description,
      weight,
      formatDateTime(start_time),
      formatDateTime(end_time),
      attachment_url,
      status
    ])

    ctx.body = {
      success: true,
      data: {
        task_id: result.insertId
      }
    }
  } catch (error) {
    console.error('创建教学任务失败:', error)
    ctx.body = {
      success: false,
      message: '创建教学任务失败'
    }
  }
}

// 更新任务
const updateTask = async (ctx) => {
  try {
    const taskId = ctx.params.task_id
    const {
      title,
      description,
      weight,
      start_time,
      end_time,
      attachment_url,
      status
    } = ctx.request.body

    await pool.execute(`
      UPDATE TeachingTask
      SET 
        title = ?,
        description = ?,
        weight = ?,
        start_time = ?,
        end_time = ?,
        attachment_url = ?,
        status = ?
      WHERE task_id = ?
    `, [
      title,
      description,
      weight,
      formatDateTime(start_time),
      formatDateTime(end_time),
      attachment_url,
      status,
      taskId
    ])

    ctx.body = {
      success: true
    }
  } catch (error) {
    console.error('更新教学任务失败:', error)
    ctx.body = {
      success: false,
      message: '更新教学任务失败'
    }
  }
}

// 删除任务
const deleteTask = async (ctx) => {
  try {
    const taskId = ctx.params.task_id

    // 首先删除相关的提交记录
    await pool.execute('DELETE FROM TaskSubmission WHERE task_id = ?', [taskId])
    
    // 然后删除任务
    await pool.execute('DELETE FROM TeachingTask WHERE task_id = ?', [taskId])

    ctx.body = {
      success: true
    }
  } catch (error) {
    console.error('删除教学任务失败:', error)
    ctx.body = {
      success: false,
      message: '删除教学任务失败'
    }
  }
}

// 获取任务的所有提交记录
const getTaskSubmissions = async (ctx) => {
  try {
    const taskId = ctx.params.task_id
    const [submissions] = await pool.execute(`
      SELECT 
        ts.*,
        s.name as student_name
      FROM TaskSubmission ts
      JOIN Student s ON ts.student_id = s.student_id
      WHERE ts.task_id = ?
      ORDER BY ts.submitted_at DESC
    `, [taskId])

    ctx.body = {
      success: true,
      data: submissions
    }
  } catch (error) {
    console.error('获取提交记录失败:', error)
    ctx.body = {
      success: false,
      message: '获取提交记录失败'
    }
  }
}

// 获取学生的提交记录
const getMySubmission = async (ctx) => {
  try {
    const taskId = ctx.params.task_id
    const studentId = ctx.request.headers['x-student-id'] // 从请求头获取学生ID

    if (!studentId) {
      ctx.body = {
        success: false,
        message: '未登录或无权限'
      }
      return
    }

    const [submissions] = await pool.execute(`
      SELECT * FROM TaskSubmission
      WHERE task_id = ? AND student_id = ?
    `, [taskId, studentId])

    ctx.body = {
      success: true,
      data: submissions[0] || null
    }
  } catch (error) {
    console.error('获取提交记录失败:', error)
    ctx.body = {
      success: false,
      message: '获取提交记录失败'
    }
  }
}

// 提交���业
const submitAssignment = async (ctx) => {
  try {
    let attachment_url = null;
    
    // 获取上传的文件
    const file = ctx.request.files?.file;
    if (file) {
      attachment_url = `/uploads/${file.newFilename}`;
      console.log('文件已上传:', {
        originalName: file.originalFilename,
        newName: file.newFilename,
        url: attachment_url
      });
    }

    // 从请求体中获取表单数据
    const task_id = ctx.request.body?.task_id;
    const submission_content = ctx.request.body?.submission_content || '';
    const studentId = ctx.request.headers['x-student-id'];

    console.log('提交作业参数:', {
      task_id,
      studentId,
      submission_content,
      attachment_url,
      body: ctx.request.body
    });

    // 验证必要参数
    if (!task_id) {
      ctx.body = {
        success: false,
        message: '缺少任务ID'
      };
      return;
    }

    if (!studentId) {
      ctx.body = {
        success: false,
        message: '未登录或无权限'
      };
      return;
    }

    // 先删除已有的提交记录
    const [oldSubmissions] = await pool.execute(
      'SELECT attachment_url FROM TaskSubmission WHERE task_id = ? AND student_id = ?',
      [task_id, studentId]
    );

    // 如果存在旧的附件，删除它
    if (oldSubmissions && oldSubmissions.length > 0 && oldSubmissions[0].attachment_url) {
      const oldFilePath = path.join(uploadDir, path.basename(oldSubmissions[0].attachment_url));
      if (fs.existsSync(oldFilePath)) {
        try {
          fs.unlinkSync(oldFilePath);
          console.log('已删除旧文件:', oldFilePath);
        } catch (err) {
          console.error('删除旧文件失败:', err);
        }
      }
    }

    // 删除旧的提交记录
    await pool.execute(
      'DELETE FROM TaskSubmission WHERE task_id = ? AND student_id = ?',
      [task_id, studentId]
    );

    // 创建新的提交记录
    console.log('准备插入新记录:', {
      task_id,
      studentId,
      submission_content,
      attachment_url
    });

    const [result] = await pool.execute(`
      INSERT INTO TaskSubmission (
        task_id,
        student_id,
        submission_content,
        attachment_url,
        submitted_at
      ) VALUES (?, ?, ?, ?, NOW())
    `, [task_id, studentId, submission_content || '', attachment_url]);

    console.log('插入结果:', result);

    ctx.body = {
      success: true,
      data: {
        submission_id: result.insertId,
        attachment_url: attachment_url
      }
    };
  } catch (error) {
    console.error('提交作业失败:', error);
    ctx.body = {
      success: false,
      message: error.message || '提交作业失败'
    };
  }
};

// 教师评分
const gradeSubmission = async (ctx) => {
  try {
    const submissionId = ctx.params.submission_id
    const { score, feedback } = ctx.request.body

    await pool.execute(`
      UPDATE TaskSubmission
      SET 
        score = ?,
        feedback = ?,
        updated_at = NOW()
      WHERE submission_id = ?
    `, [score, feedback, submissionId])

    ctx.body = {
      success: true
    }
  } catch (error) {
    console.error('评分失败:', error)
    ctx.body = {
      success: false,
      message: '评分失败'
    }
  }
}

// 教师发布任务的文件上传
const uploadTaskFile = async (ctx) => {
  try {
    const file = ctx.request.files?.file;
    if (!file) {
      throw new Error('没有上传文件');
    }

    ctx.body = {
      success: true,
      data: {
        url: `/uploads/${file.newFilename}`,
        name: file.originalFilename
      }
    };
  } catch (error) {
    console.error('文件上传失败:', error);
    ctx.body = {
      success: false,
      message: error.message || '文件上传失败'
    };
  }
};

module.exports = {
  getTasksByCourse,
  getTaskDetail,
  createTask,
  updateTask,
  deleteTask,
  getTaskSubmissions,
  getMySubmission,
  submitAssignment,
  gradeSubmission,
  uploadTaskFile
}