import Quick
import Nimble
@testable import Lookup

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

final class AnimalClass {
    let name: String = "Dog"
    let age: Int = 4
    let type: AnimalType = .dog
    let intType: AnimalIntType = .dog
}

final class LookupTests: QuickSpec {
    
    override func spec() {
        describe("Lookup tests") {
            
            context("test initialization") {
                it("jsonString initialization") {
                    let jsonString = "{\"name\": \"lookup\"}"
                    let lookup = Lookup(jsonString)
                    expect(lookup.name.string) == "lookup"
                }
                
                it("json data initialization") {
                    let jsonString = "{\"name\": \"lookup\"}"
                    let data = jsonString.data(using: .utf8)
                    expect(data == nil) == false
                    
                    let lookup = Lookup(data!)
                    expect(lookup.name.string) == "lookup"
                }
                
                it("array initialization") {
                    let array: [Any] = [1, 2.0, "3", 4.5, -5, -6.0]
                    let lookup = Lookup(array)
                    expect(lookup.0.int) == 1
                    expect(lookup.1.double) == 2.0
                    expect(lookup.2.string) == "3"
                    expect(lookup.3.double) == 4.5
                    expect(lookup.4.int) == -5
                    expect(lookup.5.double) == -6.0
                }
                
                it("structure initialization") {
                    let animal = Animal(name: "Cat", age: 3, type: .cat, intType: .cat)
                    let lookup = Lookup(animal)
                    expect(lookup.name.string) == "Cat"
                    expect(lookup.age.int) == 3
                    expect(lookup.type.string) == "cat"
                    expect(lookup.intType.int) == 1
                }
                
                it("class initialization") {
                    let animal = AnimalClass()
                    let lookup = Lookup(animal)
                    expect(lookup.name.string) == "Dog"
                    expect(lookup.age.int) == 4
                    expect(lookup.type.string) == "dog"
                    expect(lookup.intType.int) == 0
                }
            }
            
            context("test chain value") {
                it("more dict") {
                    let dict: [String: Any] = [
                        "data": [
                            "list": ["value0", nil, "value2"]
                        ]
                    ]
                    
                    let lookup = Lookup(dict)
                    expect(lookup.data.list.0.string) == "value0"
                    expect(lookup.data.list.1.isNone) == true
                    expect(lookup.data.list.2.string) == "value2"
                }
                
                let dict: [String: Any] = [
                    "data": [
                        ["list": ["value0", nil, "value2"]],
                        ["list": ["value3", nil, 4]]
                    ]
                ]
                let lookup = Lookup(dict)
                it("more array") {
                    expect(lookup.data.0.list.0.string) == "value0"
                    expect(lookup.data.0.list.1.string).to(beNil())
                    expect(lookup.data.0.list.2.string) == "value2"
                    
                    expect(lookup.data.1.list.0.string) == "value3"
                    expect(lookup.data.1.list.1.string).to(beNil())
                    expect(lookup.data.1.list.2.int) == 4
                }
                
                it("index with chain") {
                    expect(lookup["data.0.list.0"].string) == "value0"
                    expect(lookup["data.1.list.1"].string).to(beNil())
                    expect(lookup["data.1.list.2"].int) == 4
                }
            }
            
            context("test nil") {
                it("array contains nil") {
                    let array: [Any?] = [1, 2, "3", nil, 5]
                    let lookup = Lookup(array)
                    expect(lookup.3.isNone).to(beTrue())
                }
                
                it("dictionary contains nil") {
                    let dict: [String: Any?] = [
                        "nil": nil
                    ]
                    let lookup = Lookup(dict)
                    expect(lookup.nil.isNone).to(beTrue())
                }
            }
            
            context("test number conver") {
                it("number") {
                    let dict = ["number": 1]
                    let lookup = Lookup(dict)
                    expect(lookup.number.int) == 1
                    expect(lookup.number.string) == "1"
                    expect(lookup.number.int16) == 1
                    expect(lookup.number.int32) == 1
                    expect(lookup.number.int64) == 1
                    expect(lookup.number.uInt) == 1
                    expect(lookup.number.uInt16) == 1
                    expect(lookup.number.uInt32) == 1
                    expect(lookup.number.uInt64) == 1
                    expect(lookup.number.float) == 1.0
                    expect(lookup.number.double) == 1.0
                    expect(lookup.number.bool) == true
                }
                
                it("string number") {
                    let dict = ["number": "1"]
                    let lookup = Lookup(dict)
                    expect(lookup.number.int) == 1
                    expect(lookup.number.string) == "1"
                    expect(lookup.number.int16) == 1
                    expect(lookup.number.int32) == 1
                    expect(lookup.number.int64) == 1
                    expect(lookup.number.uInt) == 1
                    expect(lookup.number.uInt16) == 1
                    expect(lookup.number.uInt32) == 1
                    expect(lookup.number.uInt64) == 1
                    expect(lookup.number.float) == 1.0
                    expect(lookup.number.double) == 1.0
                    expect(lookup.number.bool) == true
                }
            }
            
            // MARK: ⚠️ NOT SUPPORT NUMBER KEY NOW
            context("test dictionary with number key") {
                it("test") {
                    let dict: [Int: Any] = [
                        0: "Lookup"
                    ]
                    let lookup = Lookup(dict)
                    //expect(lookup.0.string).to(equal("Lookup"))
                    expect(lookup.0.string).to(beNil())
                }
            }
        }
    }
}
