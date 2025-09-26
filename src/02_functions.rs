// 02_functions.rs - Rust函数详解

// 主函数
fn main() {
    println!("Hello, world!");

    // 调用函数
    another_function();

    // 调用带参数的函数
    print_labeled_measurement(5, 'h');

    // 调用带返回值的函数
    let x = five();
    println!("The value of x is: {}", x);

    // 调用带表达式返回值的函数
    let y = plus_one(5);
    println!("The value of y is: {}", y);

    // 调用多个参数和返回值的函数
    let (result1, result2) = multiple_returns(10, 20);
    println!("Multiple returns: {}, {}", result1, result2);

    // 调用带默认参数行为的函数（通过函数重载模拟）
    say_hello();
    say_hello_to("Rustacean");

    // 调用带有多个参数类型的函数
    mixed_types(10, 3.14, "Rust");

    // 调用递归函数
    let factorial_result = factorial(5);
    println!("Factorial of 5 is: {}", factorial_result);

    // 函数作为参数
    let a = 10;
    let b = 20;
    println!(
        "Applying operation to {} and {}: {}",
        a,
        b,
        apply_operation(a, b, add)
    );
    println!(
        "Applying operation to {} and {}: {}",
        a,
        b,
        apply_operation(a, b, subtract)
    );

    // 内联函数（通过闭包模拟）
    let square = |x| x * x;
    println!("Square of 5 is: {}", square(5));
}

// 基础函数定义
fn another_function() {
    println!("Another function.");
}

// 带参数的函数
// 参数必须指定类型
fn print_labeled_measurement(value: i32, unit_label: char) {
    println!("The measurement is: {}{}", value, unit_label);
}

// 带返回值的函数
// -> 符号后跟返回类型
fn five() -> i32 {
    5 // 注意没有分号，这是一个表达式，会返回值
}

// 带参数和返回值的函数
fn plus_one(x: i32) -> i32 {
    x + 1 // 表达式返回
}

// 返回多个值（使用元组）
fn multiple_returns(a: i32, b: i32) -> (i32, i32) {
    (a + b, a * b) // 返回一个元组
}

// 没有参数的函数
fn say_hello() {
    println!("Hello!");
}

// 带一个参数的函数（模拟默认参数）
fn say_hello_to(name: &str) {
    println!("Hello, {}!", name);
}

// 不同类型的参数
fn mixed_types(x: i32, y: f64, z: &str) {
    println!("Integer: {}, Float: {}, String: {}", x, y, z);
}

// 递归函数
fn factorial(n: u64) -> u64 {
    if n <= 1 { 1 } else { n * factorial(n - 1) }
}

// 函数作为参数的示例
// 先定义两个操作函数
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn subtract(a: i32, b: i32) -> i32 {
    a - b
}

// 然后定义一个接受函数作为参数的函数
// F 是一个泛型参数，约束为Fn(i32, i32) -> i32
fn apply_operation<F>(a: i32, b: i32, operation: F) -> i32
where
    F: Fn(i32, i32) -> i32,
{
    operation(a, b)
}

// 文档注释示例
/// 计算两个数的和
///
/// # Examples
///
/// ```
/// let sum = calculate_sum(5, 10);
/// assert_eq!(sum, 15);
/// ```
fn calculate_sum(x: i32, y: i32) -> i32 {
    x + y
}
