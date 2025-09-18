// 04_ownership.rs - Rust所有权系统详解

fn main() {
    // 所有权规则：
    // 1. Rust中的每个值都有一个所有者
    // 2. 同一时间只能有一个所有者
    // 3. 当所有者离开作用域时，值会被丢弃
    
    // 变量作用域示例
    {
        let s = "hello"; // s 进入作用域
        println!("{} inside scope", s);
    } // s 离开作用域，其值被丢弃
    
    // String类型与&str的区别
    let s1 = String::from("hello"); // String类型，在堆上分配
    let s2 = "hello"; // 字符串字面量，在二进制中
    
    // 移动语义 (Move)
    let s3 = s1; // s1的所有权移动到s3，s1不再可用
    println!("s3: {}", s3);
    // 下面这行会导致编译错误：println!("s1: {}", s1);
    
    // 克隆 (Clone) - 深拷贝
    let s4 = String::from("hello");
    let s5 = s4.clone(); // 克隆s4的值，s4仍然可用
    println!("s4: {}, s5: {}", s4, s5);
    
    // 栈上数据的复制
    let x = 5; // 整型是Copy类型
    let y = x; // x被复制，而不是移动，x仍然可用
    println!("x: {}, y: {}", x, y);
    
    // 函数参数和返回值的所有权转移
    let s6 = String::from("hello");
    take_ownership(s6); // s6的所有权转移到函数中，s6不再可用
    
    let z = 5;
    makes_copy(z); // z是Copy类型，函数获取的是一个副本，z仍然可用
    println!("z is still available: {}", z);
    
    // 从函数返回值获取所有权
    let s7 = gives_ownership(); // gives_ownership返回的String所有权转移给s7
    println!("s7: {}", s7);
    
    let s8 = String::from("hello");
    let s9 = takes_and_gives_back(s8); // s8所有权转移到函数，然后转移到s9
    println!("s9: {}", s9);
    
    // 引用和借用
    let s10 = String::from("hello");
    let len = calculate_length(&s10); // &s10创建一个引用，不获取所有权
    println!("The length of '{}' is {}.", s10, len);
    
    // 可变引用
    let mut s11 = String::from("hello");
    change(&mut s11); // 需要可变引用
    println!("After change: {}", s11);
    
    // 可变引用的限制：同一时间只能有一个可变引用
    let mut s12 = String::from("hello");
    let r1 = &mut s12;
    // 下面这行会导致编译错误：let r2 = &mut s12;
    println!("r1: {}", r1);
    
    // 解决可变引用限制的方法：创建新的作用域
    let mut s13 = String::from("hello");
    {
        let r1 = &mut s13;
        println!("r1: {}", r1);
    } // r1离开作用域，释放可变引用
    let r2 = &mut s13;
    println!("r2: {}", r2);
    
    // 不能同时有可变引用和不可变引用
    let mut s14 = String::from("hello");
    let r1 = &s14; // 不可变引用
    let r2 = &s14; // 可以有多个不可变引用
    println!("r1: {}, r2: {}", r1, r2);
    // 下面这行会导致编译错误：let r3 = &mut s14;
    
    // 当不可变引用离开作用域后，可以创建可变引用
    let mut s15 = String::from("hello");
    {
        let r1 = &s15;
        let r2 = &s15;
        println!("r1: {}, r2: {}", r1, r2);
    } // r1和r2离开作用域
    let r3 = &mut s15;
    println!("r3: {}", r3);
    
    // 悬垂引用
    // 在Rust中，下面的代码会导致编译错误
    // let reference_to_nothing = dangle();
    
    // 正确的方式：返回值而不是引用
    let reference_to_something = no_dangle();
    println!("reference_to_something: {}", reference_to_something);
    
    // 切片 (Slices)
    let s16 = String::from("hello world");
    let hello = &s16[0..5]; // 字符串切片
    let world = &s16[6..11];
    println!("hello: {}, world: {}", hello, world);
    
    // 切片的简化语法
    let slice1 = &s16[..2]; // 等同于 [0..2]
    let slice2 = &s16[3..]; // 等同于 [3..s16.len()]
    let slice3 = &s16[..]; // 等同于 [0..s16.len()]
    println!("slice1: {}, slice2: {}, slice3: {}", slice1, slice2, slice3);
    
    // 字符串字面量就是切片
    let literal = "hello world";
    // literal的类型是 &str
    
    // 其他类型的切片
    let a = [1, 2, 3, 4, 5];
    let slice = &a[1..3]; // 数组切片，类型是 &[i32]
    println!("array slice: {:?}", slice);
    
    // 使用切片作为函数参数
    let s17 = String::from("hello world");
    let first_word = first_word(&s17);
    println!("First word: {}", first_word);
    
    // 也可以直接传递字符串字面量
    let literal = "hello world";
    let first_word = first_word(literal);
    println!("First word of literal: {}", first_word);
}

// 函数获取所有权
fn take_ownership(some_string: String) {
    println!("{} in take_ownership", some_string);
} // some_string离开作用域，调用drop方法

// 函数获取Copy类型的值
fn makes_copy(some_integer: i32) {
    println!("{} in makes_copy", some_integer);
} // some_integer离开作用域，但不会有特殊操作

// 函数返回所有权
fn gives_ownership() -> String {
    let some_string = String::from("hello");
    some_string // 返回并转移所有权
} // some_string离开作用域，但所有权已转移，不会调用drop

// 函数接收并返回所有权
fn takes_and_gives_back(a_string: String) -> String {
    a_string // 返回并转移所有权
} // a_string离开作用域，但所有权已转移，不会调用drop

// 函数使用引用（借用）
fn calculate_length(s: &String) -> usize {
    s.len()
} // s离开作用域，但不拥有引用的值，所以不会发生任何事情

// 函数使用可变引用
fn change(some_string: &mut String) {
    some_string.push_str(", world");
} // some_string离开作用域，但不拥有引用的值，所以不会发生任何事情

// 悬垂引用的错误示例（不会编译）
// fn dangle() -> &String {
//     let s = String::from("hello");
//     &s // 返回s的引用，但s会在函数结束时被释放
// } // s离开作用域，被释放，返回的引用将指向无效内存

// 正确的做法：返回值而不是引用
fn no_dangle() -> String {
    let s = String::from("hello");
    s // 返回s的所有权
} // s离开作用域，但所有权已转移，不会调用drop

// 查找字符串中的第一个单词
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();
    
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    
    &s[..] // 如果没有空格，返回整个字符串
}