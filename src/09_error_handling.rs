// 09_error_handling.rs - Rust错误处理详解

use std::fs::File;
use std::io::{self, Read, ErrorKind};
use std::num::ParseIntError;
use std::result;

// 定义一个自定义的Result类型别名
// 在实际库中，通常会为特定的错误类型创建自定义Result
// type Result<T> = result::Result<T, MyError>;

// 自定义错误类型（通过实现std::error::Error trait）
#[derive(Debug)]
enum MyError {
    IoError(io::Error),
    ParseError(ParseIntError),
    CustomError(String),
}

// 为自定义错误类型实现From trait，用于自动转换
impl From<io::Error> for MyError {
    fn from(error: io::Error) -> Self {
        MyError::IoError(error)
    }
}

impl From<ParseIntError> for MyError {
    fn from(error: ParseIntError) -> Self {
        MyError::ParseError(error)
    }
}

// 实现Display trait以提供用户友好的错误信息
impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            MyError::IoError(err) => write!(f, "IO错误: {}", err),
            MyError::ParseError(err) => write!(f, "解析错误: {}", err),
            MyError::CustomError(msg) => write!(f, "自定义错误: {}", msg),
        }
    }
}

// 实现std::error::Error trait
impl std::error::Error for MyError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            MyError::IoError(err) => Some(err),
            MyError::ParseError(err) => Some(err),
            MyError::CustomError(_) => None,
        }
    }
}

fn main() {
    // 1. panic!宏 - 不可恢复的错误
    // 当发生panic时，程序会打印错误信息、展开并清理栈，然后退出
    // 取消下面的注释查看panic效果
    // panic!("应用程序发生错误!");
    
    // 2. Result枚举 - 可恢复的错误处理
    // Result<T, E>有两个变体：
    // - Ok(T): 操作成功，包含成功的值
    // - Err(E): 操作失败，包含错误信息
    
    let f = File::open("hello.txt");
    
    let f = match f {
        Ok(file) => file,
        Err(error) => {
            panic!("打开文件时发生错误: {:?}", error);
        }
    };
    
    // 3. 匹配特定的错误类型
    let f = File::open("hello.txt");
    
    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("创建文件时发生错误: {:?}", e),
            },
            other_error => panic!("打开文件时发生错误: {:?}", other_error),
        },
    };
    
    // 4. unwrap和expect方法 - 简化错误处理
    // unwrap: 如果Result是Ok，返回Ok中的值；如果是Err，调用panic!
    // let f = File::open("hello.txt").unwrap();
    
    // expect: 类似于unwrap，但允许指定自定义的panic消息
    // let f = File::open("hello.txt").expect("无法打开hello.txt文件");
    
    // 5. 传播错误 - 使用?运算符
    // 当函数返回Result类型时，可以使用?运算符简化错误传播
    match read_username_from_file() {
        Ok(username) => println!("用户名: {}"),
        Err(e) => println!("读取用户名失败: {:?}"),
    }
    
    // 6. 使用自定义错误类型
    match read_and_parse_file() {
        Ok(result) => println!("解析结果: {}"),
        Err(e) => println!("处理失败: {}"),
    }
    
    // 7. main函数返回Result
    // main函数也可以返回Result<(), E>，当返回Err时，程序会打印错误信息并退出
    // fn main() -> Result<(), Box<dyn std::error::Error>> {
    //     let content = std::fs::read_to_string("hello.txt")?;
    //     println!("内容: {}", content);
    //     Ok(())
    // }
    
    // 8. 组合多个错误处理操作
    let result = read_file_content("hello.txt").and_then(parse_content);
    match result {
        Ok(value) => println!("最终结果: {}"),
        Err(e) => println!("操作失败: {:?}"),
    }
    
    // 9. 忽略错误
    let _ = File::open("hello.txt"); // 使用_忽略Result
}

// 使用match传播错误
fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");
    
    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };
    
    let mut s = String::new();
    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}

// 使用?运算符简化错误传播
fn read_username_from_file_short() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

// 更进一步简化
fn read_username_from_file_very_short() -> Result<String, io::Error> {
    std::fs::read_to_string("hello.txt")
}

// 使用自定义错误类型的函数
fn read_and_parse_file() -> Result<i32, MyError> {
    // 读取文件内容
    let content = std::fs::read_to_string("number.txt")?; // 自动转换为MyError::IoError
    
    // 解析内容
    let number = content.trim().parse::<i32>()?; // 自动转换为MyError::ParseError
    
    // 检查数字是否有效
    if number < 0 {
        return Err(MyError::CustomError(String::from("数字不能为负数")));
    }
    
    Ok(number)
}

// 用于组合错误处理的函数
fn read_file_content(filename: &str) -> Result<String, io::Error> {
    std::fs::read_to_string(filename)
}

fn parse_content(content: String) -> Result<i32, ParseIntError> {
    content.trim().parse::<i32>()
}

// 示例：使用Result的链式调用
fn process_data(filename: &str) -> Result<i32, Box<dyn std::error::Error>> {
    let result = read_file_content(filename)?
        .trim()
        .parse::<i32>()?
        .checked_add(10)
        .ok_or_else(|| "整数溢出")?;
    
    Ok(result)
}

// 测试错误处理
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    #[should_panic]
    fn test_panic() {
        panic!("测试panic");
    }
    
    #[test]
    fn test_result_ok() {
        let result = Ok(42);
        assert_eq!(result.unwrap(), 42);
    }
    
    // 这个测试会失败，因为我们预期它会返回错误
    // #[test]
    // fn test_result_err() {
    //     let result: Result<i32, &str> = Err("错误");
    //     result.unwrap();
    // }
}