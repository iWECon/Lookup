import XCTest
@testable import Lookup
import Foundation
#if os(iOS)
import UIKit
#endif

enum AnimalType {
    case dog, cat
}

enum AnimalIntType: Int, LookupEnum {
    case dog = 0, cat
    
    var lookupRawValue: Any {
        self.rawValue
    }
}

struct Animal {
    let name: String
    let age: Int
    let type: AnimalType
    let intType: AnimalIntType
}

open class AnimalClass {
    let name: String = "Dog"
    let age: Int = 4
    let type: AnimalType = .dog
    let intType: AnimalIntType = .dog
}

final class Species: AnimalClass {
    let start: Date = Date()
}

final class LookupTests: XCTestCase {
    
    func tests() throws {
        
        func testDataStringInitialization() {
            let str = "Its a string..."
            let data = str.data(using: .utf8)!
            let lookup = Lookup(data)
            XCTAssertEqual(lookup.string, str)
        }
        testDataStringInitialization()
        
        func testJsonStringInitialization() {
            let jsonString = "{\"name\": \"lookup\"}"
            let lookup = Lookup(jsonString)
            XCTAssertEqual(lookup.name.string, "lookup")
        }
        testJsonStringInitialization()
        
        func jsonDataInitialization() {
            let jsonString = "{\"name\": \"lookup\"}"
            let data = jsonString.data(using: .utf8)
            XCTAssertFalse(data == nil)
            
            let lookup = Lookup(data!)
            XCTAssertEqual(lookup.name.string, "lookup")
        }
        jsonDataInitialization()
        
        func arrayInitialization() {
            let array: [Any] = [1, 2.0, "3", 4.5, -5, -6.0]
            let lookup = Lookup(array)
            XCTAssertEqual(lookup.0.int, 1)
            XCTAssertEqual(lookup.1.double, 2.0)
            XCTAssertEqual(lookup.2.string, "3")
            XCTAssertEqual(lookup.3.double, 4.5)
            XCTAssertEqual(lookup.4.int, -5)
            XCTAssertEqual(lookup.5.double, -6.0)
        }
        arrayInitialization()
        
        func structureInitialization() {
            let animal = Animal(name: "Cat", age: 3, type: .cat, intType: .cat)
            let lookup = Lookup(animal)
            XCTAssertEqual(lookup.name.string, "Cat")
            XCTAssertEqual(lookup.age.int, 3)
            XCTAssertEqual(lookup.type.string, "cat")
            XCTAssertEqual(lookup.intType.int, 1)
        }
        structureInitialization()
        
        func classInitialization() {
            let animal = AnimalClass()
            let lookup = Lookup(animal)
            XCTAssertEqual(lookup.name.string, "Dog")
            XCTAssertEqual(lookup.age.int, 4)
            XCTAssertEqual(lookup.type.string, "dog")
            XCTAssertEqual(lookup.intType.int, 0)
        }
        classInitialization()
        
        func hasSuperClassInitialization() {
            let species = Species()
            let lookup = Lookup(species)
            XCTAssertEqual(lookup.name.string, "Dog")
            XCTAssertEqual(lookup.age.int, 4)
            XCTAssertEqual(lookup.type.string, "dog")
            XCTAssertEqual(lookup.intType.int, 0)
            XCTAssertNotNil(lookup.start.double)
        }
        hasSuperClassInitialization()
        
        func chainValue() {
            let dict: [String: Any] = [
                "data": [
                    "list": ["value0", nil, "value2"]
                ]
            ]
            let lookup = Lookup(dict)
            XCTAssertEqual(lookup.data.list.0.string, "value0")
            XCTAssertEqual(lookup.data.list.1.isNone, true)
            XCTAssertEqual(lookup.data.list.2.string, "value2")
        }
        chainValue()
        
        func chainValue2() {
            let dict: [String: Any] = [
                "data": [
                    ["list": ["value0", nil, "value2"]],
                    ["list": ["value3", nil, 4]]
                ]
            ]
            let lookup = Lookup(dict)
            XCTAssertEqual(lookup.data.0.list.0.string, "value0")
            XCTAssertNil(lookup.data.0.list.1.string)
            XCTAssertEqual(lookup.data.0.list.2.string, "value2")
            XCTAssertEqual(lookup.data.1.list.0.string, "value3")
            XCTAssertNil(lookup.data.1.list.1.string)
            XCTAssertEqual(lookup.data.1.list.2.int, 4)
            
            XCTAssertEqual(lookup["data.0.list.0"].string, "value0")
            XCTAssertNil(lookup["data.1.list.1"].string)
            XCTAssertEqual(lookup["data.1.list.2"].int, 4)
        }
        chainValue2()
        
        func arrayNilValue() {
            let array: [Any?] = [1, 2, "3", nil, 5]
            let lookup = Lookup(array)
            XCTAssertTrue(lookup.3.isNone)
        }
        arrayNilValue()
        
        func dictionaryNilValue() {
            let dict: [String: Any?] = ["nil": nil]
            let lookup = Lookup(dict)
            XCTAssertTrue(lookup.nil.isNone)
        }
        dictionaryNilValue()
        
        func numberConvert() {
            let dict = ["number": 1]
            let lookup = Lookup(dict)
            XCTAssertEqual(lookup.number.int, 1)
            XCTAssertEqual(lookup.number.string, "1")
            XCTAssertEqual(lookup.number.int16, 1)
            XCTAssertEqual(lookup.number.int32, 1)
            XCTAssertEqual(lookup.number.int64, 1)
            XCTAssertEqual(lookup.number.uInt, 1)
            XCTAssertEqual(lookup.number.uInt16, 1)
            XCTAssertEqual(lookup.number.uInt32, 1)
            XCTAssertEqual(lookup.number.uInt64, 1)
            XCTAssertEqual(lookup.number.float, 1.0)
            XCTAssertEqual(lookup.number.double, 1.0)
            XCTAssertEqual(lookup.number.bool, true)
        }
        numberConvert()
        
        func stringNumberConvert() {
            let dict = ["number": "1"]
            let lookup = Lookup(dict)
            XCTAssertEqual(lookup.number.int, 1)
            XCTAssertEqual(lookup.number.string, "1")
            XCTAssertEqual(lookup.number.int16, 1)
            XCTAssertEqual(lookup.number.int32, 1)
            XCTAssertEqual(lookup.number.int64, 1)
            XCTAssertEqual(lookup.number.uInt, 1)
            XCTAssertEqual(lookup.number.uInt16, 1)
            XCTAssertEqual(lookup.number.uInt32, 1)
            XCTAssertEqual(lookup.number.uInt64, 1)
            XCTAssertEqual(lookup.number.float, 1.0)
            XCTAssertEqual(lookup.number.double, 1.0)
            XCTAssertEqual(lookup.number.bool, true)
        }
        stringNumberConvert()
        
        func mergeDictionaryLookups() {
            let lookup1 = Lookup(["name": "Lookup", "age": 3])
            let lookup2 = Lookup(["age": 1])
            let merged = lookup1 + lookup2
            XCTAssertEqual(merged.name.string, "Lookup")
            XCTAssertEqual(merged.age.int, 1)

            var lookup3 = Lookup(["name": "Lookup", "brief": "A data handle tools."])
            let lookup4 = Lookup(["age": 1])
            lookup3 += lookup4
            XCTAssertEqual(lookup3.age.int, 1)
            XCTAssertEqual(lookup3.name.string, "Lookup")
            XCTAssertEqual(lookup3.brief.string, "A data handle tools.")

            let lookup5 = lookup3 + ["brief": "json handle tools"]
            XCTAssertEqual(lookup5.brief.string, "json handle tools")

            let lookup6 = Lookup([1, 2, 3, 4, 5])
            let lookup7 = lookup6 + [4, 5, 6, 7, 8]
            XCTAssertEqual(lookup7.arrayValue.count, 10)
            
            let lookup8 = Lookup([
                "userID": 00001,
                "nickname": "Lookup"
            ])
            XCTAssertEqual(lookup8.userID.string, "1")
        }
        mergeDictionaryLookups()
        
        func codable() throws {
            let jsonString = "{\"name\": \"Lookup\", \"age\": 1, \"list\": \"[1,2,3]\"}"
            var lookup = try JSONDecoder().decode(Lookup.self, from: jsonString.data(using: .utf8)!)
            XCTAssertEqual(lookup.name.string, "Lookup")
            XCTAssertEqual(lookup.age.int, 1)
            XCTAssertEqual(lookup.list.0.int, 1)
            XCTAssertEqual(lookup.list.1.int, 2)
            XCTAssertEqual(lookup.list.2.int, 3)
            XCTAssertEqual(lookup.list.0.intValue, 1)

            lookup["list"] = ["a", "b", "c"]
            XCTAssertEqual(lookup.list.0.string, "a")
            XCTAssertEqual(lookup.list.1.string, "b")
            XCTAssertEqual(lookup.list.2.string, "c")
            XCTAssertEqual(lookup.list.3.string, nil)
            
            lookup["address"] = "in Hangzhou"
            XCTAssertEqual(lookup.address.string, "in Hangzhou")

            // TODO: dynamicMember change
            lookup["list.0"] = "d"
            XCTAssertNotEqual(lookup.list.0.string, "d")

            let jsonData = try JSONEncoder().encode(lookup)
            let _jsonString = String(data: jsonData, encoding: .utf8)
            XCTAssertNotNil(_jsonString)
            let rLookup = Lookup(_jsonString!)
            XCTAssertEqual(rLookup.name.string, "Lookup")
            XCTAssertEqual(rLookup.age.int, 1)

            lookup["age"] = "8"
            XCTAssertEqual(lookup.age.int, 8)
        }
        try codable()
        
        func setValue() throws {
            let jsonString = "{\"name\": \"lookup\"}"
            let data = jsonString.data(using: .utf8)
            XCTAssertFalse(data == nil)
            
            var lookup = Lookup(data!)
            lookup.name = "Lookup YYDS"
            XCTAssertEqual(lookup.name.string, "Lookup YYDS")
            
            lookup.name = 1.0
            XCTAssertEqual(lookup.name.double, 1.0)
            
            lookup.name = nil
            XCTAssertEqual(lookup.name.isNone, true)
        }
        try setValue()
        
        func changeValue() throws {
            let jsonString = """
{
    "name": "Lookap",
    "version": "2.3.1",
    "age": 2.5
}
"""
            var lookup = Lookup(jsonString)
            lookup.name = "Lookup"
            
            let newVersion = "2.4.0"
            lookup.version = "\(newVersion)"
            lookup.age = 3
            
            let newProperty = Lookup(["birthday": "2023/2/3", "info": 1])
            lookup += newProperty
            
            lookup += ["describe": "a magic json handle package", "info": 2, "url": nil]
            XCTAssertEqual(lookup.name.string, "Lookup")
            XCTAssertEqual(lookup.version.string, "2.4.0")
            XCTAssertEqual(lookup.age.double, 3)
            XCTAssertEqual(lookup.birthday.string, "2023/2/3")
            XCTAssertEqual(lookup.describe.string, "a magic json handle package")
            XCTAssertEqual(lookup.abc.string, nil)
            XCTAssertEqual(lookup.info.int, 2)
            XCTAssertEqual(lookup.abc.isNone, true)
            
            lookup["url"] = 2
            XCTAssertEqual(lookup.url.int, 2)
            
            lookup["url"] = "https://github.com/iwecon"
            lookup.url += "/lookup"
            XCTAssertEqual(lookup.url.string, "https://github.com/iwecon/lookup")
            
            XCTAssertEqual(lookup.hasKey("package"), false)
            
            XCTAssertEqual(lookup.hasKey("package.info.type"), false)
            lookup += ["package": ["info": ["type": 1]]]
            XCTAssertEqual(lookup.hasKey("package.info.type"), true)
            XCTAssertEqual(lookup["package.info.type"].int, 1)
            
            XCTAssertEqual(lookup.hasKey("package.info.wow"), false)
            
            lookup += """
{
    "highlights": "@dynamicMemberLookup"
}
"""
            XCTAssertEqual(lookup.highlights.string, "@dynamicMemberLookup")
        }
        try changeValue()
        
        #if os(iOS)
        func uiView() throws {
            let view = UIView()
            let lookup = Lookup(["view": view])
            XCTAssertEqual(lookup.description, """
{
  "view" : "\(view)"
}
""")
        }
        try uiView()
        #endif
    }
}
