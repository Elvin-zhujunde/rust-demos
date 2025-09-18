// 03_control_flow.rs - Rust流程控制详解

fn main() {
    // if 表达式
    let number = 3;
    
    if number < 5 {
        println!("condition was true");
    } else {
        println!("condition was false");
    }
    
    // 在let语句中使用if表达式（因为if是表达式，会返回值）
    let condition = true;
    let number = if condition {
        5
    } else {
        6
    };
    
    println!("The value of number is: {}", number);
    
    // 多个else if分支
    let n = 6;
    
    if n % 4 == 0 {
        println!("n is divisible by 4");
    } else if n % 3 == 0 {
        println!("n is divisible by 3");
    } else if n % 2 == 0 {
        println!("n is divisible by 2");
    } else {
        println!("n is not divisible by 4, 3, or 2");
    }
    
    // loop循环（无限循环）
    let mut counter = 0;
    
    let result = loop {
        counter += 1;
        
        if counter == 10 {
            break counter * 2; // 从循环中返回值
        }
    };
    
    println!("The result is: {}", result);
    
    // while循环
    let mut number = 3;
    
    while number != 0 {
        println!("{}", number);
        number -= 1;
    }
    
    println!("LIFTOFF!");
    
    // for循环遍历集合
    let a = [10, 20, 30, 40, 50];
    
    for element in a.iter() {
        println!("the value is: {}", element);
    }
    
    // for循环遍历范围
    for number in (1..4).rev() { // rev()反转范围
        println!("{}", number);
    }
    
    println!("LIFTOFF!");
    
    // 使用标签跳出嵌套循环
    let mut count = 0;
    'outer: loop {
        let mut inner = 0;
        
        loop {
            inner += 1;
            count += 1;
            
            if inner == 3 {
                continue 'outer; // 继续外层循环的下一次迭代
            }
            
            if count == 10 {
                break 'outer; // 跳出外层循环
            }
        }
    }
    
    println!("count is {}", count);
    
    // match表达式（类似switch，但更强大）
    let coin = Coin::Quarter(UsState::Alaska);
    let value = value_in_cents(coin);
    println!("The value is {} cents", value);
    
    // match匹配Option<T>
    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
    
    // if let简洁控制流（处理只关心一种匹配的情况）
    let some_u8_value = Some(0u8);
    if let Some(3) = some_u8_value {
        println!("three");
    }
    
    // if let与else结合
    let mut count = 0;
    let coin = Coin::Penny;
    
    if let Coin::Quarter(state) = coin {
        println!("State quarter from {:?}!", state);
    } else {
        count += 1;
    }
    
    println!("Count is {}", count);
    
    // while let循环
    let mut stack = Vec::new();
    
    stack.push(1);
    stack.push(2);
    stack.push(3);
    
    while let Some(top) = stack.pop() {
        println!("{}: ", top);
    }
}

// 为了演示match表达式，定义一个枚举
#[derive(Debug)] // 这样可以打印枚举值
enum UsState {
    Alabama,
    Alaska,
    Arizona,
    // ... 其他州
}

#[derive(Debug)] // 这样可以打印枚举值
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState), // 关联数据
}

// 使用match表达式计算硬币价值
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        },
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        },
    }
}

// 使用match处理Option<T>
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}