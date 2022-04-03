import XCTest
@testable import Lookup

final class LookupTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

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
        print(lookup)

        XCTAssertTrue(lookup["values.0.name"].string == "你好")
        XCTAssertTrue(lookup["values.1.name"].string == "世界")
        XCTAssertTrue(lookup["values.10.name"].string == nil)

        XCTAssertTrue(lookup.values.0.name.isNone == false)

        XCTAssertTrue(lookup.code.intValue == 200)
        XCTAssertTrue(lookup.success.boolValue == true)

        XCTAssertTrue(lookup["result.pageNumber"].int == 1)
        XCTAssertTrue(lookup["result.hasMore"].boolValue == false)

        XCTAssertTrue(lookup["result.messages"].isNone)
        XCTAssertTrue(lookup.callback.isNone)
        XCTAssertTrue(lookup["result.point"].doubleValue == 3.1415926)
    }

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
        let a = Animal()
        let lookup = Lookup(a)
        print(lookup)

        XCTAssertTrue(lookup.name.string == "Tiger")
        XCTAssertTrue(lookup["eat.name"].string == "Meat")
        XCTAssertTrue(lookup.age.intValue == 4)
    }

    func testMerging() {
        let a: [String: Any?] = ["name": "kevin", "age": 14]
        let b: [String: Any?] = ["name": "kevins", "city": "hangzhou"]

        let merged = [Lookup(a), Lookup(b)].merging(uniquingKeysWith: { $1 })
        print(merged)
        XCTAssertTrue(merged.dict!.keys.sorted(by: { $0 < $1 }) == ["age", "city", "name"])
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testStruct", testStruct),
        ("testClass", testClass),
        ("testLookups", testLookups)
    ]
    
    func testLookups() throws {
        let dict = [
            "user": "kevin",
            "age": 24,
            "brief": "life is better~~",
            "favorite": nil,
            "friends": [
                [
                    "name": "big wang",
                    "age": 26
                ], [
                    "name": "tiger",
                    "age": 22
                ]
            ],
            "jsonstring": "[{\"a\": 1, \"b\": 2, \"c\": 3}, {\"d\": 4, \"e\": 5, \"f\": 6}]"
        ] as [String : Any?]
        
        let lookup = Lookup(dict)
        print(lookup)
        
        print(lookup["friends"][1].age)
        
        XCTAssertTrue(lookup["friends"][0]["name"].string == "big wang")
        XCTAssertTrue(lookup["friends"][0]["brief"].string == nil)

        XCTAssertTrue(lookup["friends"][1].name.string == "tiger")
        XCTAssertTrue(lookup["friends"][1].age.string == "22")
        XCTAssertTrue(lookup["friends"][1].age.intValue == 22)
        XCTAssertTrue(lookup.friends.1.age.intValue == 22)
        
        XCTAssertTrue(lookup.friends.1.age.rawValue as? Int == 22)
        XCTAssertTrue(lookup.friends.1.age.rawValue as? String == nil)
        XCTAssertTrue(lookup.friends.1.age.string == "22")
        XCTAssertTrue(lookup.age.floatValue == 24.0)
        XCTAssertTrue(lookup.age.doubleValue == 24.0)
        XCTAssertTrue(lookup.age.stringValue == "24")
        
        XCTAssertTrue(lookup["favorite"].isNone)
        XCTAssertTrue(lookup.favorite.isNone)

        XCTAssertTrue(!lookup.favorite.isSome)
        XCTAssertTrue(lookup.jsonstring.arrayValue.count == 2)
        XCTAssertTrue(lookup.jsonstring.0.a.intValue == 1)
        XCTAssertTrue(lookup.jsonstring.1.e.string == "5")
        XCTAssertTrue(lookup.jsonstring.10.a.isNone)
    }
    
    func testCodable() throws {
        
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
        
        let data = try JSONSerialization.data(withJSONObject: dict)
        let lookup = try JSONDecoder().decode(Lookup.self, from: data)
        XCTAssertTrue(lookup.code.int == 200)
        XCTAssertTrue(lookup.success.int == 1)
        XCTAssertTrue(lookup.success.string == "1")
        XCTAssertTrue(lookup.result.pageNumber.int == 1)
        XCTAssertTrue(lookup.values.0.name.string == "你好")
        XCTAssertTrue(lookup.values.1.name.string == "世界")
    }
    
    func testEncodable() throws {
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
        ] as [String : Any]
        
        let data = try JSONSerialization.data(withJSONObject: dict)
        let lookup = try JSONDecoder().decode(Lookup.self, from: data)
        
        let encodeData = try JSONEncoder().encode(lookup)
        let encoderDict = try! JSONSerialization.jsonObject(with: encodeData, options: []) as! [String: Any]
        XCTAssertTrue(encoderDict["code"] as! NSNumber == 200)
        
        let r = encoderDict["values"] as? [[String: String]]
        let r1 = r?[0]
        let r1Name = r1?["name"]
        XCTAssertTrue(r1Name == "你好")
        
        let rr = encoderDict["result"] as? [String: Any]
        let messages = rr?["messages"]
        print(lookup)
        XCTAssertTrue(messages is NSNull)
        
        let arr = [
            1, 2, 3, "4", 5, "6"
        ] as [Any]
        print(Lookup(arr))
        
        
        let dictt: [String: Any] = [
            "name": "iww",
            "age": 26
        ]
        let dataa = try JSONSerialization.data(withJSONObject: dictt)
        let t = try JSONDecoder().decode(Test.self, from: dataa)
        XCTAssertTrue(t.name == "iww")
    }
    
    struct Test: Codable {
        var name: String
        var age: Int
    }
}
