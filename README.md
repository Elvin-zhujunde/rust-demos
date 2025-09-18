# Rust 学习教程系列

这个仓库包含了一系列Rust编程语言的教程文件，旨在帮助初学者系统地学习Rust的各种语法和功能。每个文件都专注于Rust的一个特定方面，并提供了详细的代码示例和注释说明。

## 教程文件列表

1. **01_variables_and_types.rs** - 变量和数据类型
   - 变量声明、可变性、类型注解
   - 基本数据类型：整数、浮点数、布尔值、字符
   - 复合数据类型：元组、数组
   - 常量、隐藏(Shadowing)、作用域

2. **02_functions.rs** - 函数
   - 函数定义和调用
   - 参数和返回值
   - 多种参数类型
   - 递归函数
   - 函数作为参数
   - 文档注释示例

3. **03_control_flow.rs** - 流程控制
   - if表达式
   - loop循环（无限循环）
   - while循环
   - for循环
   - match表达式（模式匹配）
   - if let和while let简洁控制流
   - 标签和嵌套循环

4. **04_ownership.rs** - 所有权
   - 所有权规则
   - 变量作用域
   - 移动语义(Move)
   - 克隆(Clone)
   - 引用和借用
   - 可变引用
   - 悬垂引用
   - 切片(Slices)

5. **05_structs.rs** - 结构体
   - 结构体定义和实例化
   - 结构体更新语法
   - 元组结构体
   - 类单元结构体
   - 结构体方法
   - 关联函数
   - 多个impl块
   - 包含引用的结构体

6. **06_enums_and_pattern_matching.rs** - 枚举和模式匹配
   - 枚举定义
   - 关联数据的枚举
   - 枚举方法
   - Option枚举
   - 模式匹配
   - 通配符和占位符
   - if let和while let
   - 复杂模式匹配

7. **07_collections.rs** - 常见集合及操作
   - Vector（动态数组）
   - String（字符串）
   - HashMap（键值对集合）
   - HashSet（集合）
   - BTreeMap（有序键值对集合）
   - BTreeSet（有序集合）
   - 各集合类型的比较和适用场景

8. **08_packages_and_modules.rs** - 包和模块
   - 包、Crate和模块的概念
   - 模块定义和嵌套
   - 路径和引用
   - pub关键字（可见性控制）
   - use语句（路径导入）
   - 重新导出
   - 模块最佳实践

9. **09_error_handling.rs** - 错误处理
   - panic!宏（不可恢复的错误）
   - Result枚举（可恢复的错误）
   - unwrap和expect方法
   - ?运算符（错误传播）
   - 自定义错误类型
   - 错误组合处理

10. **10_generics_traits_lifetimes.rs** - 泛型、Trait和生命周期
    - 泛型函数和结构体
    - Trait定义和实现
    - Trait作为参数和返回类型
    - 生命周期注解
    - 结构体中的生命周期
    - 静态生命周期
    - 泛型、Trait和生命周期的结合使用

## 如何使用这些教程

1. 确保你已经安装了Rust。如果没有，请访问[Rust官网](https://www.rust-lang.org/)下载并安装。

2. 克隆或下载这个仓库到你的本地机器。

3. 进入项目目录：
   ```
   cd rust/my_project
   ```

4. 运行单个教程文件：
   ```
   cargo run --bin 01_variables_and_types
   ```
   （注意：你需要先修改Cargo.toml文件，为每个教程文件添加对应的bin条目）

   或者，你可以使用`rustc`直接编译并运行：
   ```
   rustc src/01_variables_and_types.rs
   ./01_variables_and_types
   ```

5. 阅读代码和注释，尝试修改代码并观察结果，加深理解。

## 学习建议

- 按照文件编号顺序学习，从基础开始逐步深入
- 每个概念都通过代码示例进行了演示，尝试运行这些示例并修改它们
- 不要跳过任何文件，因为后面的概念通常依赖于前面的内容
- 对于不理解的概念，可以查阅[Rust官方文档](https://doc.rust-lang.org/book/)
- 尝试自己编写代码，应用所学的知识

祝你学习Rust愉快！🦀