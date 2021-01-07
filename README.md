# Lookup

一个神奇的工具库。

## 神奇 🤗️

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
.package(url: "https://github.com/iWECon/Lookup", from: "1.0.0")
```

