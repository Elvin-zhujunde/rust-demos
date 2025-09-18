// 08_packages_and_modules.rs - Rust包和模块详解

// Rust的模块系统包括：
// - 包（Packages）：一个项目，包含多个crate
// - Crate：一个编译单元，可以生成可执行文件或库
// - 模块（Modules）：组织代码，控制作用域和可见性
// - 路径（Paths）：引用模块、类型、函数等的方式

// 这里我们将创建一个示例模块结构，但由于是单个文件示例，我们只创建内联模块

// 定义一个模块
mod front_of_house {
    // 嵌套模块
    mod hosting {
        // 公共函数（使用pub关键字）
        pub fn add_to_waitlist() {
            println!("Adding to waitlist...");
        }
        
        // 私有函数（默认）
        fn seat_at_table() {
            println!("Seating at table...");
        }
    }
    
    mod serving {
        pub fn take_order() {
            println!("Taking order...");
        }
        
        pub fn serve_order() {
            println!("Serving order...");
        }
        
        pub fn take_payment() {
            println!("Taking payment...");
        }
    }
    
    // 公共结构体
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String, // 私有字段
    }
    
    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

// 另一个模块示例
mod back_of_house {
    // 从父模块导入
    use super::front_of_house::Breakfast;
    
    pub enum Appetizer {
        Soup,
        Salad,
    }
    
    pub fn fix_incorrect_order() {
        cook_order();
        super::front_of_house::serving::serve_order();
    }
    
    fn cook_order() {
        println!("Cooking order...");
    }
}

// 重新导出（将内部实现暴露给外部）
pub mod restaurant {
    // 重新导出front_of_house模块中的内容
    pub use super::front_of_house::hosting;
    pub use super::front_of_house::serving;
    pub use super::back_of_house::Appetizer;
}

// 创建一个包含多个子模块的库示例
pub mod math {
    pub mod arithmetic {
        pub fn add(a: i32, b: i32) -> i32 {
            a + b
        }
        
        pub fn subtract(a: i32, b: i32) -> i32 {
            a - b
        }
        
        pub fn multiply(a: i32, b: i32) -> i32 {
            a * b
        }
        
        pub fn divide(a: i32, b: i32) -> Option<i32> {
            if b == 0 {
                None
            } else {
                Some(a / b)
            }
        }
    }
    
    pub mod geometry {
        pub fn area_of_rectangle(width: u32, height: u32) -> u32 {
            width * height
        }
        
        pub fn area_of_circle(radius: f64) -> f64 {
            std::f64::consts::PI * radius * radius
        }
    }
}

fn main() {
    // 使用绝对路径访问函数
    crate::front_of_house::hosting::add_to_waitlist();
    
    // 使用相对路径访问函数
    front_of_house::serving::take_order();
    
    // 使用use语句简化路径
    use crate::front_of_house::serving;
    serving::serve_order();
    serving::take_payment();
    
    // 导入结构体
    use crate::front_of_house::Breakfast;
    let mut breakfast = Breakfast::summer("Wheat");
    println!("Breakfast toast: {}", breakfast.toast);
    // 无法访问私有字段: breakfast.seasonal_fruit
    breakfast.toast = String::from("Rye"); // 可以修改公共字段
    
    // 使用别名简化导入
    use crate::back_of_house::Appetizer as Starter;
    let order1 = Starter::Soup;
    let order2 = Starter::Salad;
    
    match order1 {
        Starter::Soup => println!("Soup ordered"),
        Starter::Salad => println!("Salad ordered"),
    }
    
    // 使用重新导出的模块
    use crate::restaurant::hosting;
    hosting::add_to_waitlist();
    
    use crate::restaurant::serving;
    serving::take_order();
    
    // 使用导入的枚举
    use crate::restaurant::Appetizer;
    let order = Appetizer::Salad;
    
    // 使用math模块
    use crate::math::arithmetic;
    println!("5 + 3 = {}", arithmetic::add(5, 3));
    println!("10 - 4 = {}", arithmetic::subtract(10, 4));
    println!("6 * 7 = {}", arithmetic::multiply(6, 7));
    
    match arithmetic::divide(20, 4) {
        Some(result) => println!("20 / 4 = {}", result),
        None => println!("Division by zero"),
    }
    
    match arithmetic::divide(10, 0) {
        Some(result) => println!("10 / 0 = {}", result),
        None => println!("Division by zero"),
    }
    
    // 使用geometry子模块
    use crate::math::geometry;
    println!("Area of rectangle (5x10): {}", geometry::area_of_rectangle(5, 10));
    println!("Area of circle (radius 3): {}", geometry::area_of_circle(3.0));
    
    // 包和模块最佳实践
    // 1. 从crate根开始使用绝对路径（crate::）
    // 2. 当访问同一模块树中的项时，使用相对路径
    // 3. 为常用的项创建use导入
    // 4. 重导出项以简化公共API
    // 5. 模块命名使用snake_case（全小写，下划线分隔）
    // 6. 文件结构应该反映模块结构
    
    // 注意：在实际项目中，每个模块通常会有自己的文件或目录
    // 例如：
    // src/lib.rs 或 src/main.rs - 根模块
    // src/front_of_house.rs 或 src/front_of_house/mod.rs - front_of_house模块
    // src/front_of_house/hosting.rs - hosting子模块
}

// 测试模块系统
#[cfg(test)]
mod tests {
    // 导入外部函数
    use super::math::arithmetic;
    
    #[test]
    fn test_arithmetic() {
        assert_eq!(arithmetic::add(2, 3), 5);
        assert_eq!(arithmetic::subtract(5, 2), 3);
        assert_eq!(arithmetic::multiply(3, 4), 12);
        assert_eq!(arithmetic::divide(10, 2), Some(5));
        assert_eq!(arithmetic::divide(10, 0), None);
    }
}