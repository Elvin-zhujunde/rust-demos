## 教学管理系统数据库设计文档

### 1. 基础表设计

#### 1.1 院系表 (Department)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| department_id | VARCHAR(20) | PRIMARY KEY | 院系ID |
| department_name | VARCHAR(100) | NOT NULL | 院系名称 |

#### 1.2 专业表 (Major)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| major_id | VARCHAR(20) | PRIMARY KEY | 专业ID |
| major_name | VARCHAR(100) | NOT NULL | 专业名称 |
| department_id | VARCHAR(20) | FOREIGN KEY | 所属院系ID |

#### 1.3 班级表 (Class)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| class_id | VARCHAR(20) | PRIMARY KEY | 班级ID |
| class_name | VARCHAR(100) | NOT NULL | 班级名称 |
| major_id | VARCHAR(20) | FOREIGN KEY | 所属专业ID |

#### 1.4 学科表 (Subject)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| subject_id | VARCHAR(20) | PRIMARY KEY | 学科ID |
| subject_name | VARCHAR(100) | NOT NULL | 学科名称 |
| class_hours | INT | NOT NULL | 课时数 |
| credits | DECIMAL(3,1) | NOT NULL | 学分 |

#### 1.5 教师表 (Teacher)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| teacher_id | VARCHAR(20) | PRIMARY KEY | 教师ID |
| name | VARCHAR(50) | NOT NULL | 姓名 |
| password | VARCHAR(255) | NOT NULL | 密码 |
| gender | ENUM('男', '女') | NOT NULL | 性别 |
| email | VARCHAR(100) | NOT NULL | 邮箱 |
| address | VARCHAR(200) | NOT NULL | 地址 |
| department_id | VARCHAR(20) | FOREIGN KEY | 所属院系ID |
| title | VARCHAR(50) | NOT NULL | 职称 |
| entry_date | DATE | NOT NULL | 入职日期 |

#### 1.6 学生表 (Student)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| student_id | VARCHAR(20) | PRIMARY KEY | 学号 |
| name | VARCHAR(50) | NOT NULL | 姓名 |
| password | VARCHAR(255) | NOT NULL | 密码 |
| gender | ENUM('男', '女') | NOT NULL | 性别 |
| email | VARCHAR(100) | NOT NULL | 邮箱 |
| address | VARCHAR(200) | NOT NULL | 地址 |
| department_id | VARCHAR(20) | FOREIGN KEY | 所属院系ID |
| degree | VARCHAR(50) | NOT NULL | 学位 |
| enrollment_date | DATE | NOT NULL | 入学日期 |
| major_id | VARCHAR(20) | FOREIGN KEY | 所属专业ID |
| class_id | VARCHAR(20) | FOREIGN KEY | 所属班级ID |
| semester | INT | NOT NULL | 学期 |
| total_credits | DECIMAL(5,2) | DEFAULT 0 | 总学分 |
| gpa | DECIMAL(4,2) | DEFAULT 0 | 平均绩点 |

#### 1.7 教室表 (Classroom)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| classroom_id | VARCHAR(20) | PRIMARY KEY | 教室ID |
| building | VARCHAR(50) | NOT NULL | 教学楼 |
| room_number | VARCHAR(20) | NOT NULL | 房间号 |
| capacity | INT | NOT NULL | 容纳人数 |

#### 1.8 课程表 (Course)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| course_id | VARCHAR(20) | PRIMARY KEY | 课程ID |
| subject_id | VARCHAR(20) | FOREIGN KEY, NOT NULL | 学科ID |
| teacher_id | VARCHAR(20) | FOREIGN KEY | 教师ID |
| semester | INT | NOT NULL | 学期 |
| student_count | INT | DEFAULT 0 | 当前学生数 |
| max_students | INT | NOT NULL | 最大学生数 |
| classroom_id | VARCHAR(20) | FOREIGN KEY | 教室ID |
| class_hours | ENUM('16','32','48','64') | NOT NULL | 课时数 |
| week_day | ENUM('1'-'7') | NOT NULL | 上课星期 |
| start_section | INT | NOT NULL | 开始节次 |
| section_count | INT | DEFAULT 1 | 课程节数 |

#### 1.9 选课表 (CourseSelection)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| student_id | VARCHAR(20) | PRIMARY KEY, FOREIGN KEY | 学生ID |
| course_id | VARCHAR(20) | PRIMARY KEY, FOREIGN KEY | 课程ID |
| selection_date | DATETIME | DEFAULT CURRENT_TIMESTAMP | 选课时间 |

#### 1.10 成绩表 (Grades)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| student_id | VARCHAR(20) | PRIMARY KEY, FOREIGN KEY | 学生ID |
| course_id | VARCHAR(20) | PRIMARY KEY, FOREIGN KEY | 课程ID |
| grade | DECIMAL(5,2) | NOT NULL | 成绩 |

#### 1.11 教学任务表 (TeachingTask)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| task_id | INT | PRIMARY KEY, AUTO_INCREMENT | 任务ID |
| course_id | VARCHAR(20) | FOREIGN KEY, NOT NULL | 课程ID |
| title | VARCHAR(100) | NOT NULL | 任务标题 |
| description | TEXT | | 任务描述 |
| weight | INT | CHECK (0-100) | 任务权重 |
| attachment_url | VARCHAR(255) | | 附件URL |
| start_time | DATETIME | NOT NULL | 开始时间 |
| end_time | DATETIME | NOT NULL | 结束时间 |
| status | ENUM('active','closed') | DEFAULT 'active' | 任务状态 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 1.12 作业提交表 (TaskSubmission)
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| submission_id | INT | PRIMARY KEY, AUTO_INCREMENT | 提交ID |
| task_id | INT | FOREIGN KEY, NOT NULL | 任务ID |
| student_id | VARCHAR(20) | FOREIGN KEY, NOT NULL | 学生ID |
| submission_content | TEXT | | 提交内容 |
| attachment_url | VARCHAR(255) | | 附件URL |
| score | INT | CHECK (0-100) | 分数 |
| feedback | TEXT | | 反馈内容 |
| submitted_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 提交时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 2. 视图设计

#### 2.1 课程信息与授课教师视图 (vw_Course_Teacher)
- 包含课程基本信息、授课教师信息的综合视图
- 用于展示课程详细信息

#### 2.2 学生成绩-课程信息-授课教师视图 (vw_Student_Grades_Course_Teacher)
- 包含学生成绩、课程信息、授课教师信息的综合视图
- 用于成绩管理和查询

#### 2.3 学生选课方案视图 (vw_Student_CourseSelection)
- 包含学生选课信息、课程详情的综合视图
- 用于选课管理和查询

### 3. 触发器设计

#### 3.1 选课相关触发器
- `trg_CourseSelection_insert`: 选课时更新学生总学分
- `trg_CourseSelection_delete`: 退课时更新学生总学分
- `trg_CourseSelection_count_insert`: 选课时更新课程学生数
- `trg_CourseSelection_count_delete`: 退课时更新课程学生数

#### 3.2 成绩相关触发器
- `trg_Grades_insert`: 录入成绩时更新学生GPA

#### 3.3 作业相关触发器
- `check_submission_time`: 检查作业提交时间是否在有效期内

### 4. 用户权限设计

#### 4.1 学生用户权限
- 可查看：学生信息、课程信息、选课信息
- 可操作：选课、退课

#### 4.2 教师用户权限
- 可查看：所有表的查询权限
- 可操作：成绩录入和修改

#### 4.3 管理员用户权限
- 拥有所有表的完整操作权限
