// 06_enums_and_pattern_matching.rs - Rust枚举和模式匹配详解

// 基本枚举定义
enum IpAddrKind {
    V4,
    V6,
}

// 关联数据的枚举
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

// 带有多种不同类型关联数据的枚举
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

// 为枚举实现方法
impl Message {
    fn call(&self) {
        // 方法体可以根据枚举的不同变体执行不同的操作
        match self {
            Message::Quit => println!("Quit message received"),
            Message::Move { x, y } => println!("Move to coordinates x={}, y={}", x, y),
            Message::Write(text) => println!("Write message: {}", text),
            Message::ChangeColor(r, g, b) => println!("Change color to RGB({}, {}, {})", r, g, b),
        }
    }
}

// Option枚举（Rust标准库提供）
// enum Option<T> {
//     None,
//     Some(T),
// }

// 定义一个更复杂的枚举用于演示
#[derive(Debug)] // 允许打印调试信息
enum UsState {
    Alabama,
    Alaska,
    // ... 其他州
}

#[derive(Debug)] // 允许打印调试信息
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn main() {
    // 枚举值
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;
    
    route(four);
    route(six);
    
    // 使用带有关联数据的枚举
    let home = IpAddr::V4(127, 0, 0, 1);
    let loopback = IpAddr::V6(String::from("::1"));
    
    // 使用Message枚举
    let m1 = Message::Quit;
    let m2 = Message::Move { x: 10, y: 20 };
    let m3 = Message::Write(String::from("Hello"));
    let m4 = Message::ChangeColor(255, 0, 0);
    
    // 调用枚举方法
    m1.call();
    m2.call();
    m3.call();
    m4.call();
    
    // Option<T>枚举
    let some_number = Some(5);
    let some_string = Some("a string");
    let absent_number: Option<i32> = None;
    
    // 在Option<T>上使用match表达式
    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
    
    // 模式匹配 - match表达式
    let coin = Coin::Penny;
    let value = value_in_cents(coin);
    println!("The value of the coin is {} cents.", value);
    
    let quarter = Coin::Quarter(UsState::Alaska);
    let quarter_value = value_in_cents(quarter);
    println!("The value of the quarter is {} cents.", quarter_value);
    
    // 匹配Option<i32>
    let x = Some(5);
    let y: Option<i32> = None;
    
    println!("Plus one to x: {:?}", plus_one(x));
    println!("Plus one to y: {:?}", plus_one(y));
    
    // 通配符模式和_占位符
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other), // other是一个变量名，可以是任何未匹配的值
    }
    
    // 使用_占位符忽略未使用的值
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        _ => (), // 不做任何事
    }
    
    // if let 简洁控制流
    let config_max = Some(3u8);
    if let Some(max) = config_max {
        println!("The maximum is configured to be {}", max);
    }
    
    // if let与else结合
    let coin = Coin::Penny;
    let mut count = 0;
    
    if let Coin::Quarter(state) = coin {
        println!("State quarter from {:?}!");
    } else {
        count += 1;
    }
    
    println!("Count is {}", count);
    
    // 更复杂的模式匹配示例
    let pair = (2, -2);
    
    match pair {
        (x, y) if x == y => println!("These are twins: {}, {}", x, y),
        (x, y) if x + y == 0 => println!("These are opposites: {}, {}", x, y),
        (x, _) if x % 2 == 1 => println!("The first is odd: {}", x),
        _ => println!("No special case for {:?}", pair),
    }
    
    // 解构结构体进行匹配
    let rect = Rectangle { width: 30, height: 50 };
    
    match rect {
        Rectangle { width, height: 50 } => println!("Rectangle with width {} and height 50", width),
        Rectangle { width: 30, height } => println!("Rectangle with width 30 and height {}", height),
        Rectangle { width, height } => println!("Rectangle with width {} and height {}", width, height),
    }
}

// 接受枚举值作为参数的函数
fn route(ip_kind: IpAddrKind) {
    println!("Routing IP address of type: {:?}", ip_kind);
}

// 在Option<T>上使用模式匹配的函数
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

// 使用模式匹配计算硬币价值
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!");
            25
        },
    }
}

// 用于模式匹配示例的函数
fn add_fancy_hat() {
    println!("Adding a fancy hat!");
}

fn remove_fancy_hat() {
    println!("Removing the fancy hat!");
}

fn move_player(num_spaces: u8) {
    println!("Moving player {} spaces!");
}

// 用于演示解构结构体匹配的结构体
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}