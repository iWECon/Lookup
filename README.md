# Lookup

一个神奇的工具库。

## 神奇 🤗️

通过 `@dynamicMemberLookup` 实现跨层级取值 ~

不仅可以用字典来初始化，还可以使用任意的 `struct` 和 `class`

#### Lookup 2.0.0 +

```swift
let lookup = Lookup("{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}")
lookup["data.cat.name"].string      // return Kitty,
lookup["data.cat.age"].int          // return nil, bcz the key is not exists
lookup["data.cat"].dict             // return the cat's dict

// and, you can write code like this
lookup.code.int         // return Optional(200)
lookup.code.intValue    // return 200
```

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
class Animal {
    var name = "Tiger"
    var age = 4
    var eat: Eat = .init()
}

class Eat {
    var name = "Meat"
}

func testClass() {
    let a = Animal()
    let lookup = Lookup(a)
    print(lookup)
    
    XCTAssertTrue(lookup.name.string == "Tiger")
    XCTAssertTrue(lookup["eat.name"].string == "Meat")
    XCTAssertTrue(lookup.age.intValue == 4)
}
```


#### Lookup 1.0.0 +
当你有一段 JSON 时，你可以这样用：
```swift
// support json string to initialize
if let lookup = Lookup("{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}") {
    lookup["data.cat.name"].string      // return Kitty,
    lookup["data.cat.age"].int          // return nil, bcz the key is not exists
    lookup["data.cat"].dict             // return the cat's dict
    
    // and, you can write code like this
    lookup.code.int         // return Optional(200)
    lookup.code.intValue    // return 200
}
```

或者你也可以通过 `[String: Any?]` 来初始化:
```swift
// supoort [String: Any?] to initialize
if let lookup = Lookup(["name": "iWECon", "age": 18, "height": 170, "brief": nil]) {
    // some codes...
}
```

## 安装方式

#### Swift Package Manager
```swift
.package(url: "https://github.com/iWECon/Lookup", from: "2.0.0")
```

