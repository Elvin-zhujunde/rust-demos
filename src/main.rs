// 01_variables_and_types.rs - Rust变量和数据类型详解

fn main() {
    // 基础变量声明和不可变性
    let x = 5; // 默认是不可变的
    println!("The value of x is: {}", x);
    
    // 可变变量声明
    let mut y = 5; // 使用mut关键字使其可变
    println!("The value of y is: {}", y);
    y = 6; // 可以修改值
    println!("The value of y is: {}", y);
    
    // 显式类型注解
    let z: i32 = 5; // 明确指定变量类型
    let pi: f64 = 3.14159;
    let is_rust_fun: bool = true;
    let c: char = 'R';
    
    // 整数类型
    let a: i8 = 127; // 有符号8位整数
    let b: u8 = 255; // 无符号8位整数
    let c: i16 = 32767;
    let d: u16 = 65535;
    let e: i32 = 2147483647; // 最常用的整数类型
    let f: u32 = 4294967295;
    let g: i64 = 9223372036854775807;
    let h: u64 = 18446744073709551615;
    let i: isize = 123; // 指针大小的有符号整数
    let j: usize = 456; // 指针大小的无符号整数，用于索引
    
    // 浮点数类型
    let k: f32 = 3.14; // 单精度浮点数
    let l: f64 = 3.1415926535; // 双精度浮点数，是Rust的默认浮点类型
    
    // 布尔类型
    let m: bool = true;
    let n: bool = false;
    
    // 字符类型 (Unicode标量值)
    let o: char = 'a';
    let p: char = '中';
    let q: char = '🦀'; // emoji字符
    
    // 元组类型
    let tuple: (i32, f64, bool, char) = (500, 6.4, true, 'z');
    
    // 从元组中解构值
    let (x1, y1, z1, a1) = tuple;
    println!("The value of y1 is: {}", y1);
    
    // 也可以通过索引访问元组元素
    println!("The first element of the tuple is: {}", tuple.0);
    println!("The second element of the tuple is: {}", tuple.1);
    
    // 数组类型 (固定长度)
    let array1: [i32; 5] = [1, 2, 3, 4, 5]; // 显式类型和长度
    let array2 = [3; 5]; // 初始化为5个值为3的元素
    
    // 访问数组元素
    println!("The first element of array1 is: {}", array1[0]);
    println!("The third element of array2 is: {}", array2[2]);
    
    // 数组长度
    let array_length = array1.len();
    println!("The length of array1 is: {}", array_length);
    
    // 常量 (编译时已知的值)
    const MAX_POINTS: u32 = 100_000;
    println!("The maximum points are: {}", MAX_POINTS);
    
    // 隐藏 (Shadowing) - 允许使用相同名称重新声明变量
    let shadowed = 5;
    println!("The value of shadowed is: {}", shadowed);
    
    let shadowed = shadowed + 1; // 重新声明并使用之前的值
    println!("Now the value of shadowed is: {}", shadowed);
    
    let shadowed = "Now I'm a string!";
    println!("Now the value of shadowed is: {}", shadowed);
    
    // 变量作用域
    {
        let scope_var = "I'm inside a scope";
        println!("Inside scope: {}", scope_var);
    }
    // 无法在这个作用域访问scope_var
    
    // 打印所有演示数据
    println!("\n所有演示数据的汇总:");
    println!("整数类型: {}, {}, {}, {}", a, e, i, j);
    println!("浮点类型: {}, {}", k, l);
    println!("布尔类型: {}, {}", m, n);
    println!("字符类型: {}, {}, {}", o, p, q);
}