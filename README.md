# Lookup

一个神奇的工具库。

## 神奇 🤗️

🔥 通过 `@dynamicMemberLookup` 实现跨层级取值 ~

🔥 不仅可以用字典来初始化，还可以使用任意的 `struct` 和 `class` 


## 说明

2.1.0 对 2.0.0 以来的数据获取做了优化

初始化的思路以及类型判断借鉴于 (SwiftyJSON)[https://github.com/SwiftyJSON/SwiftyJSON]

现在用起来更舒服, 版本向下兼容 ~

```swift
let lookup = Lookup("{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}")
lookup.data.cat.name.stringValue // return "Kitty"
lookup.data.cat.id.intValue      // return 12345
lookup.data.cat.id.stringValue   // return "12345". 即使json 中为数字, 依然可以转为字符串
```

支持链式取值，且不用数如何 "[" 和 "]" 取值：

```swift
let dict = [
    "code": 200,
    "success": 1,
    "result": [
        "pageNumber": 1,
        "hasMore": false,
        "messages": nil,
        "point": 3.1415926
    ],
    "values": [
        ["name": "你好"],
        ["name": "世界"]
    ]
] as [String : Any?]

let lookup = Lookup(dict)

lookup.values.0.name.stringValue  // return "你好"
lookup.values.1.name.stringValue  // return "世界"
lookup.result.messages.isNone     // return true
lookup.result.hasMore.boolValue   // return false
lookup.values.10.name.isNone      // return true
lookup.result.point.doubleValue   // return 3.1315826
lookup.result.point.stringValue   // return "3.1315826"
```


Struct 或 Class 初始化:

```swift
// Use struct or class object

// STRUCT
struct User {
    var name = "Bro"
    var age = 24
    var car: Car = .init(name: "Tesla")
}

struct Car {
    var name = "Tesla"
}

func testStruct() {
    
    let u = User.init()
    
    let lookup = Lookup(u)
    print(lookup)
    
    XCTAssertTrue(lookup["car.name"].string == "Tesla")
    XCTAssertTrue(lookup.name.string == "Bro")
    XCTAssertTrue(lookup.age.intValue == 24)
}

// CLASS
class SuperAnimal {
    var name = "Tiger"
    var age = 4
}

class Animal: SuperAnimal {
    var eat: Eat = .init()
}

class Eat {
    var name = "Meat"
}
func testClass() {
    let a = Animal() // has super class
    let lookup = Lookup(a)
    print(lookup)
    
    XCTAssertTrue(lookup.name.string == "Tiger")
    XCTAssertTrue(lookup["eat.name"].string == "Meat")
    XCTAssertTrue(lookup.age.intValue == 4)
}
```

其他的用法参考 `LookupTests.swift`: [LookupTests.swift](https://github.com/iWECon/Lookup/blob/main/Tests/LookupTests/LookupTests.swift)


## 安装方式

#### Swift Package Manager
```swift
// for swift-tools-version: 5.3
// swift 5.0 +
.package(url: "https://github.com/iWECon/Lookup", from: "2.0.4")
```

