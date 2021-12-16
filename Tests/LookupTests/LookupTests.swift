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
        XCTAssertTrue(lookup["values.[0].name"].string == "你好")
        XCTAssertTrue(lookup["values.[1].name"].string == "世界")
        XCTAssertTrue(lookup["values.[10].name"].isNil)
        
        XCTAssertTrue(Lookup(lookup["values"].rawValue as Any)["[0].name"].isNil == false)
        
        XCTAssertTrue(lookup.code.intValue == 200)
        XCTAssertTrue(lookup.success.boolValue == true)

        XCTAssertTrue(lookup["result.pageNumber"].int == 1)
        XCTAssertTrue(lookup["result.hasMore"].boolValue == false)
        
        XCTAssertTrue(!lookup["result.messages"].isNil)
        XCTAssertTrue(lookup.callback.isNil)
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
    
    static var allTests = [
        ("testExample", testExample),
        ("testStruct", testStruct),
        ("testClass", testClass)
    ]
}
