# Lookup

An amazing tool for working with JSON data in Swift.

🔥 Cross-level fetching via `@dynamicMemberLookup` ~

🔥 Can be initialized not only with `Dictionarie`s, but also with arbitrary `struct`s and `classe`s (internally converted to `Dictionary` by `Mirror` getting the attribute name)

Preface: some of the ideas and type judgments are learned and borrowed from the [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON),


## Platforms

* .iOS(.v9)

* .tvOS(.v9)

* .watchOS(.v6)

* .macOS(.v10_10)

* .Vapor(4.0)


## Features

* （🔥🔥🔥）Support for chained
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

* （🔥🔥🔥）Support for fuzzy type conversion

For example, 1 can be converted to "1" without using `as`, just `lookup.value.string`. 

```swift
lookup.result.list.0.age.string // -> "1"
lookup.result.list.0.age.int // -> 1
lookup.result.list.0.age.double // -> 1.0
```

* Handling errors or non-existent fields

```swift
// Got the value of "message".
lookup.message.isSome 
 
// The value fetched is nil, or the "message" field was not found.
lookup.message.isNone

guard lookup.message.isSome,
    let message = lookup.message.string 
else {
    // throw an error
    return
}

// If you only need to determine if the key exists, you can use `hasKey(_ keyName: String)`.
lookup.hasKey("message") // Determine if the data contains a "message" field.
lookup.hasKey("message.fromID")  // Determine if the "message" in the data contains the "fromID" field. 
```

* Add or modify data
```swift

var lookup = Lookup([
    "name": "Lookap",
    "version": "2.3.1"
])
lookup.name = "Lookup"
lookup.version = "2.4.0"

// Add new content
lookup += ["url": "https://github.com/iWECon/Lookup"]

// Combine Other Lookup, Dictionary or String
let newLookup = [
    "highlights": "@dynamicMemberLookup"
]
lookup += newLookup

// or jsonString
let newLookup = """
{
    "highlights2": "@dynamicMemberLookup"
}
"""
lookup += newLookup
```

* Support `struct`s and `classe`s

Can be initialized directly using `struct` or `class` instances

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

* Support `Codable`

* Support [Vapor](https://github.com/vapor/vapor)

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

*setNull & Compact Map Values*
```swift
let json = """
{
    "name": "Lookup",
    "age": 3,
    "versions": [
        "2.4.0", "2.0.0", "1.0.0" 
    ],
    "birth": "202"
}
let lookup = Lookup(json)
print(lookup.versions.0.string) // -> "2.4.0"
lookup["versions.0"] = "2.4.1"
print(lookup.versions.0.string) // -> "2.4.1"

// setNull
let newLookup = lookup.setNull(keys: ["birth"])
newLookup.hasKey("birth") // -> true, but value is null(nil)

let compactLookup = newLookup.compactMapValues()
newLookup.hasKey("birth") // -> false, no key no value
"""
```

More usage references `LookupTests.swift`: [LookupTests.swift](https://github.com/iWECon/Lookup/blob/main/Tests/LookupTests/LookupTests.swift)


## Installation

### Cocoapods

`pod 'Lookup', :git => "https://github.com/iWECon/Lookup", :tag => "2.4.0"`


### Swift Package Manager
```swift
// for swift-tools-version: 5.3
// swift 5.0 +
.package(url: "https://github.com/iWECon/Lookup", from: "2.4.0")
```
