import XCTest
@testable import Lookup

final class LookupTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        // support json string to initialize
        if let lookup = Lookup("{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}") {
            print(lookup["data.cat.name"].stringValue)
        }
        
        // supoort dict [String: Any?] to initialize, auto clear key if the value is nil
        if let lookup = Lookup(["value": nil, "name": "Hello"]) {
            print(lookup.name.stringValue)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
