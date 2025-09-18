// 05_structs.rs - Rust结构体详解

// 定义一个结构体
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

// 定义一个元组结构体
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

// 定义一个没有字段的类单元结构体（通常用于实现trait）
struct AlwaysEqual;

// 定义一个包含方法的结构体
#[derive(Debug)] // 允许打印调试信息
struct Rectangle {
    width: u32,
    height: u32,
}

// 为Rectangle结构体实现方法
impl Rectangle {
    // 方法 - 第一个参数是&self（不可变引用）
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    // 带有参数的方法
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
    
    // 关联函数 - 不接受self参数
    // 通常用作构造函数
    fn square(size: u32) -> Rectangle {
        Rectangle {
            width: size,
            height: size,
        }
    }
}

// 多个impl块
impl Rectangle {
    // 另一个方法
    fn perimeter(&self) -> u32 {
        2 * (self.width + self.height)
    }
}

// 定义一个包含引用的结构体
// 需要生命周期注解
struct ImportantExcerpt<'a> {
    part: &'a str,
}

// 为包含引用的结构体实现方法
impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
    
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Attention please: {}", announcement);
        self.part
    }
}

fn main() {
    // 创建结构体实例
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    println!("User: {}, Email: {}", user1.username, user1.email);
    
    // 可变结构体实例
    let mut user2 = User {
        email: String::from("another@example.com"),
        username: String::from("anotherusername567"),
        active: true,
        sign_in_count: 1,
    };
    
    // 修改可变结构体的字段
    user2.email = String::from("updated@example.com");
    println!("Updated email: {}", user2.email);
    
    // 使用结构体更新语法创建新实例
    let user3 = User {
        email: String::from("third@example.com"),
        username: String::from("thirdusername"),
        ..user1 // 其余字段从user1复制
    };
    
    println!("User3: {}, Active: {}, Sign-ins: {}", 
             user3.username, user3.active, user3.sign_in_count);
    
    // 创建元组结构体实例
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
    
    // 访问元组结构体的字段
    println!("Black color: {}, {}, {}", black.0, black.1, black.2);
    println!("Origin point: {}, {}, {}", origin.0, origin.1, origin.2);
    
    // 创建类单元结构体实例
    let subject = AlwaysEqual;
    
    // 使用带有方法的结构体
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    
    // 调用方法
    println!("The area of the rectangle is {} square pixels.", 
             rect1.area());
    println!("The perimeter of the rectangle is {} pixels.", 
             rect1.perimeter());
    
    // 调用带参数的方法
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };
    
    println!("Can rect1 hold rect2? {}", rect1.can_hold(&rect2));
    println!("Can rect1 hold rect3? {}", rect1.can_hold(&rect3));
    
    // 调用关联函数（使用::语法）
    let sq = Rectangle::square(30);
    println!("Square: width={}, height={}", sq.width, sq.height);
    println!("Square area: {}", sq.area());
    
    // 使用Debug格式化打印结构体
    println!("Rectangle: {:#?}", rect1); // :#? 提供更易读的格式
    
    // 使用包含引用的结构体
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("Excerpt level: {}", i.level());
    println!("Announced part: {}", i.announce_and_return_part("New excerpt!"));
    
    // 结构体示例：实现一个简单的计算器
    let calculator = Calculator {
        current: 0,
    };
    
    let result = calculator.add(5).multiply(2).subtract(3).value();
    println!("Calculator result: {}", result);
}

// 定义一个计算器结构体（演示方法链式调用）
struct Calculator {
    current: i32,
}

impl Calculator {
    fn new() -> Calculator {
        Calculator { current: 0 }
    }
    
    fn add(&mut self, value: i32) -> &mut Calculator {
        self.current += value;
        self
    }
    
    fn subtract(&mut self, value: i32) -> &mut Calculator {
        self.current -= value;
        self
    }
    
    fn multiply(&mut self, value: i32) -> &mut Calculator {
        self.current *= value;
        self
    }
    
    fn divide(&mut self, value: i32) -> &mut Calculator {
        if value != 0 {
            self.current /= value;
        }
        self
    }
    
    fn value(&self) -> i32 {
        self.current
    }
}