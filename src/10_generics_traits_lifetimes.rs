// 10_generics_traits_lifetimes.rs - Rust泛型、Trait和生命周期详解

// 1. 泛型（Generics）
// 泛型允许我们编写适用于任何类型的代码

// 泛型函数
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];
    
    for &item in list {
        if item > largest {
            largest = item;
        }
    }
    
    largest
}

// 泛型结构体
struct Point<T> {
    x: T,
    y: T,
}

// 为泛型结构体实现方法
impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

// 为特定类型实现方法
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

// 多个泛型参数
struct Point3D<T, U> {
    x: T,
    y: T,
    z: U,
}

// 泛型枚举 - Option<T>是Rust标准库中的泛型枚举
// enum Option<T> {
//     Some(T),
//     None,
// }

// 泛型枚举 - Result<T, E>也是Rust标准库中的泛型枚举
// enum Result<T, E> {
//     Ok(T),
//     Err(E),
// }

// 2. Trait（特征）
// Trait定义了类型必须实现的功能，类似于接口

// 定义一个Trait
pub trait Summary {
    // 方法签名
    fn summarize(&self) -> String;
    
    // 默认实现的方法
    fn summarize_author(&self) -> String {
        String::from("Unknown")
    }
    
    // 依赖于其他方法的方法
    fn summarize_with_author(&self) -> String {
        format!("{} by {}", self.summarize(), self.summarize_author())
    }
}

// 实现Trait
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
    
    // 覆盖默认实现
    fn summarize_author(&self) -> String {
        format!("@{}", self.author)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}

// Trait作为参数
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}

// Trait约束语法（与上面等效，但更灵活）
pub fn notify_generic<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// 多个Trait约束
pub fn notify_multiple<T: Summary + std::fmt::Display>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// 使用where子句简化Trait约束
pub fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Summary + Clone,
    U: std::fmt::Display + Clone,
{
    42
}

// Trait作为返回类型
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    }
}

// 3. 生命周期（Lifetimes）
// 生命周期确保引用在使用期间保持有效

// 简单的生命周期注解
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

// 生命周期注解在结构体中
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
    
    // 第一个生命周期参数是impl块声明的
    // 第二个和第三个是方法参数特有的
    fn announce_and_return_part<'b>(&'a self, announcement: &'b str) -> &'a str {
        println!("Attention please: {}", announcement);
        self.part
    }
}

// 静态生命周期
// 'static 生命周期表示整个程序的持续时间
// 字符串字面量默认具有'static生命周期
// const S: &'static str = "I have a static lifetime";

// main函数
fn main() {
    // 泛型函数示例
    let number_list = vec![34, 50, 25, 100, 65];
    let result = largest(&number_list);
    println!("The largest number is {}", result);
    
    let char_list = vec!['y', 'm', 'a', 'q'];
    let result = largest(&char_list);
    println!("The largest char is {}", result);
    
    // 泛型结构体示例
    let integer_point = Point { x: 5, y: 10 };
    let float_point = Point { x: 1.0, y: 4.0 };
    
    println!("integer_point.x = {}", integer_point.x());
    println!("float_point.x = {}", float_point.x());
    
    // 特定类型实现的方法
    let distance_point = Point { x: 3.0, y: 4.0 };
    println!("Distance from origin: {}", distance_point.distance_from_origin());
    
    // 多个泛型参数
    let p3d = Point3D { x: 5, y: 10, z: 15.0 };
    
    // Trait使用示例
    let article = NewsArticle {
        headline: String::from("Penguins win the Stanley Cup Championship!
"),
        location: String::from("Pittsburgh, PA, USA"),
        author: String::from("Iceburgh"),
        content: String::from("The Pittsburgh Penguins once again are the best hockey team in the NHL.
"),
    };
    
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people
"),
        reply: false,
        retweet: false,
    };
    
    println!("New article available!");
    println!("{}", article.summarize());
    println!("{}", article.summarize_with_author());
    
    println!("1 new tweet:");
    println!("{}", tweet.summarize());
    println!("{}", tweet.summarize_with_author());
    
    // Trait作为参数的函数
    notify(&article);
    notify(&tweet);
    
    notify_generic(&article);
    notify_generic(&tweet);
    
    // Trait作为返回类型
    let item = returns_summarizable();
    println!("Summarizable item: {}", item.summarize());
    
    // 生命周期示例
    let string1 = String::from("abcd");
    let string2 = "xyz";
    
    let result = longest(string1.as_str(), string2);
    println!("The longest string is {}", result);
    
    // 结构体中的生命周期
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("Excerpt level: {}", i.level());
    println!("Announced part: {}", i.announce_and_return_part("New excerpt!"));
    
    // 静态生命周期
    let s: &'static str = "I have a static lifetime";
    println!("Static string: {}", s);
    
    // 泛型、Trait和生命周期结合使用
    let pair = Pair(1, 2);
    println!("Pair sum: {}", pair.cmp_display());
} 

// 泛型、Trait和生命周期结合示例
struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self {
            x,
            y,
        }
    }
}

impl<T: std::fmt::Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) -> String {
        if self.x >= self.y {
            format!("The largest member is x = {}", self.x)
        } else {
            format!("The largest member is y = {}", self.y)
        }
    }
}

// 为任何实现了Display trait的类型实现ToString trait
// 这是Rust标准库中的实际实现
// impl<T: std::fmt::Display> ToString for T {
//     // ...
// }

// 使用derive属性自动实现Trait
#[derive(Debug, PartialEq, PartialOrd)]
struct Person {
    name: String,
    age: u32,
}

// 测试泛型、Trait和生命周期
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn largest_int() {
        let numbers = vec![34, 50, 25, 100, 65];
        assert_eq!(largest(&numbers), 100);
    }
    
    #[test]
    fn largest_char() {
        let chars = vec!['y', 'm', 'a', 'q'];
        assert_eq!(largest(&chars), 'y');
    }
    
    #[test]
    fn tweet_summarizes() {
        let tweet = Tweet {
            username: String::from("horse_ebooks"),
            content: String::from("of course, as you probably already know, people
"),
            reply: false,
            retweet: false,
        };
        
        assert_eq!(tweet.summarize(), "horse_ebooks: of course, as you probably already know, people
");
    }
}