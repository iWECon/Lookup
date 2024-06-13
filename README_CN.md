# Lookup

一个神奇的用来处理 Swift 中 JSON 数据的工具。

🔥 通过 `@dynamicMemberLookup` 实现跨层级取值 ~

🔥 不仅可以用字典来初始化，还可以使用任意的 `struct` 和 `class` 来初始化（内部通过 `Mirror` 获取属性名转换成 `Dictionary`） 

前要说明：部分思路以及类型判断学习和借鉴自 [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON),


## Platforms

* .iOS(.v9)

* .tvOS(.v9)

* .watchOS(.v6)

* .macOS(.v10_10)

* .Vapor(4.0)


## Features

* （🔥🔥🔥）支持链式取值
```swift
let dict: [String: Any] = {
    "result": [
        "list": [
            [
                "name": "hello lookup",
                "age": 1
            ]
         ]
    ]
}

let lookup = Lookup(dict)
lookup.result.list.array // -> [["name": "hello lookup"]]
lookup.result.list.0.name.string // -> "hello lookup"
```

* （🔥🔥🔥）支持模糊类型转换 

比如 1 可转换为 "1", 不需要使用 `as`, 直接 `lookup.value.string` 即可 

```swift
lookup.result.list.0.age.string // -> "1"
lookup.result.list.0.age.int // -> 1
lookup.result.list.0.age.double // -> 1.0
```

* 处理错误或字段不存在的情况

```swift
// 取到了 “message” 的值
lookup.message.isSome 
 
// 取到的值为 nil，或者没有找到这个 “message” 字段
lookup.message.isNone

guard lookup.message.isSome,
    let message = lookup.message.string 
else {
    // throw an error
    return
}

// 如果只需要判断是否存在该 key 时，可以使用 `hasKey(_ keyName: String)`
lookup.hasKey("message") // 判断数据中是否包含 “message” 字段
lookup.hasKey("message.fromID")  // 判断数据中的 “message” 里是否包含 “fromID” 字段 
```

* 添加或修改数据
```swift

var lookup = Lookup([
    "name": "Lookap",
    "version": "2.3.1"
])
lookup.name = "Lookup"
lookup.version = "2.4.0"

// 添加新的内容
lookup += ["url": "https://github.com/iWECon/Lookup"]

// 组合其他 Lookup / Dictionary / String
let newLookup = [
    "highlights": "@dynamicMemberLookup"
]
lookup += newLookup

// 或者 jsonString
let newLookup = """
{
    "highlights2": "@dynamicMemberLookup"
}
"""
lookup += newLookup
```

* 支持 Struct 和 Class

可直接使用 struct 或 class 实例进行初始化

```swift
struct Person {
    var name: String
    var age: Int
}

let person = Person(name: "lookup", age: 1)

let lookup = Lookup(person)
lookup.name.string  // -> "lookup"
lookup.age.int  // -> 1
```

* 支持 Codable

* 支持 [Vapor](https://github.com/vapor/vapor)

Decode
```swift
let lookup = try req.content.decode(Lookup.self)
```

Encode
```swift
let params = Lookup([
    "userId": 1,
    "nickname": "lookup"
])
try await req.client.post(uri, headers: headers) { inoutReq in 
    try inoutReq.content.encode(params)
}
```

更多用法参考 `LookupTests.swift`: [LookupTests.swift](https://github.com/iWECon/Lookup/blob/main/Tests/LookupTests/LookupTests.swift)


## Installation

### Cocoapods

`pod 'Lookup', :git => "https://github.com/iWECon/Lookup", :tag => "2.4.0"`


### Swift Package Manager
```swift
// for swift-tools-version: 5.3
// swift 5.0 +
.package(url: "https://github.com/iWECon/Lookup", from: "2.4.0")
```
