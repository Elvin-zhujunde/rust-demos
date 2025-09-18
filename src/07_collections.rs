// 07_collections.rs - Rust常见集合详解

use std::collections::{HashMap, HashSet, BTreeMap, BTreeSet};

fn main() {
    // Vector - 可变长度的数组
    // 创建一个新的空vector
    let v: Vec<i32> = Vec::new();
    
    // 使用vec!宏创建有初始值的vector
    let v = vec![1, 2, 3, 4, 5];
    
    // 创建可变vector
    let mut v = Vec::new();
    v.push(6);
    v.push(7);
    v.push(8);
    
    // 访问vector中的元素
    // 方法1：使用索引
    let third: &i32 = &v[2];
    println!("The third element is: {}", third);
    
    // 方法2：使用get方法（返回Option<&T>）
    match v.get(2) {
        Some(third) => println!("The third element is: {}", third),
        None => println!("There is no third element.")
    }
    
    // 遍历vector
    println!("Vector elements:");
    for i in &v {
        println!("{}", i);
    }
    
    // 遍历可变vector并修改元素
    for i in &mut v {
        *i += 50; // 需要解引用
    }
    
    println!("Modified vector elements:");
    for i in &v {
        println!("{}", i);
    }
    
    // Vector的长度和容量
    println!("Vector length: {}", v.len());
    println!("Vector capacity: {}", v.capacity());
    
    // 字符串 - String和&str
    // 创建空字符串
    let mut s = String::new();
    
    // 从字符串字面量创建String
    let s = "initial contents".to_string();
    let s = String::from("initial contents");
    
    // 更新字符串
    let mut s1 = String::from("foo");
    s1.push_str("bar"); // 追加字符串切片
    s1.push('!'); // 追加单个字符
    println!("Updated string: {}", s1);
    
    // 拼接字符串
    let s2 = String::from("Hello, ");
    let s3 = String::from("world!");
    let s4 = s2 + &s3; // s2不再可用，s3仍然可用
    println!("Concatenated string: {}", s4);
    
    // 使用format!宏拼接多个字符串
    let s5 = String::from("tic");
    let s6 = String::from("tac");
    let s7 = String::from("toe");
    let s8 = format!("{}-{}-{}", s5, s6, s7); // 所有源字符串仍然可用
    println!("Formatted string: {}", s8);
    
    // 字符串索引（注意：Rust字符串不支持直接索引）
    let s = String::from("hello");
    // 下面这行会导致编译错误：let h = s[0];
    
    // 遍历字符串的字符
    println!("Characters in 'hello':");
    for c in "hello".chars() {
        println!("{}", c);
    }
    
    // 遍历字符串的字节
    println!("Bytes in 'hello':");
    for b in "hello".bytes() {
        println!("{}", b);
    }
    
    // HashMap - 键值对集合
    // 创建空HashMap
    let mut scores = HashMap::new();
    
    // 插入键值对
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
    
    // 访问值
    let team_name = String::from("Blue");
    let score = scores.get(&team_name); // 返回Option<&V>
    
    match score {
        Some(s) => println!("Score for {}: {}", team_name, s),
        None => println!("No score found for {}", team_name)
    }
    
    // 遍历HashMap
    println!("All scores:");
    for (key, value) in &scores {
        println!("{}: {}", key, value);
    }
    
    // 更新HashMap
    // 覆盖已有值
    scores.insert(String::from("Blue"), 25);
    println!("Updated score for Blue: {:?}", scores.get(&String::from("Blue")));
    
    // 只在键不存在时插入
    scores.entry(String::from("Red")).or_insert(60);
    scores.entry(String::from("Blue")).or_insert(50); // 不会覆盖已有的值
    println!("After entry operations:");
    for (key, value) in &scores {
        println!("{}: {}", key, value);
    }
    
    // 根据旧值更新新值
    let text = "hello world wonderful world";
    let mut map = HashMap::new();
    
    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        *count += 1;
    }
    
    println!("Word counts: {:?}", map);
    
    // HashSet - 存储唯一值的集合
    let mut set = HashSet::new();
    
    // 插入元素
    set.insert(1);
    set.insert(2);
    set.insert(3);
    set.insert(2); // 重复元素不会被插入
    
    // 检查元素是否存在
    println!("Contains 2: {}", set.contains(&2));
    println!("Contains 4: {}", set.contains(&4));
    
    // 删除元素
    set.remove(&2);
    println!("After removal, contains 2: {}", set.contains(&2));
    
    // 遍历HashSet
    println!("HashSet elements:");
    for i in &set {
        println!("{}", i);
    }
    
    // 集合操作
    let a: HashSet<i32> = [1, 2, 3, 4, 5].iter().cloned().collect();
    let b: HashSet<i32> = [3, 4, 5, 6, 7].iter().cloned().collect();
    
    // 交集
    let intersection: HashSet<_> = a.intersection(&b).cloned().collect();
    println!("Intersection: {:?}", intersection);
    
    // 并集
    let union: HashSet<_> = a.union(&b).cloned().collect();
    println!("Union: {:?}", union);
    
    // 差集
    let difference: HashSet<_> = a.difference(&b).cloned().collect();
    println!("Difference (a - b): {:?}", difference);
    
    // BTreeMap - 基于B树的有序键值对集合
    let mut tree_map = BTreeMap::new();
    
    tree_map.insert(3, "c");
    tree_map.insert(1, "a");
    tree_map.insert(2, "b");
    
    // BTreeMap按键自动排序
    println!("BTreeMap elements (sorted by key):");
    for (key, value) in &tree_map {
        println!("{}: {}", key, value);
    }
    
    // BTreeSet - 基于B树的有序集合
    let mut tree_set = BTreeSet::new();
    
    tree_set.insert(3);
    tree_set.insert(1);
    tree_set.insert(2);
    
    // BTreeSet自动排序
    println!("BTreeSet elements (sorted):");
    for i in &tree_set {
        println!("{}", i);
    }
    
    // 集合类型比较
    // Vector: 动态数组，随机访问快，末尾插入删除快
    // String: UTF-8编码的字符串类型
    // HashMap: 哈希表，查找、插入、删除平均O(1)，但不保证顺序
    // HashSet: 基于HashMap实现的集合，存储唯一值
    // BTreeMap: 基于B树实现的映射，按键排序，查找、插入、删除O(log n)
    // BTreeSet: 基于BTreeMap实现的有序集合
}