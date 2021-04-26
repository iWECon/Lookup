import XCTest
@testable import Lookup

final class LookupTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let dict: [String : Any] = [
            "code": 200,
            "success": 1,
            "result": [
                "pageNumber": 1,
                "hasMore": false,
            ]
        ]
        
        guard let lookup = Lookup(dict),
              let result = Lookup(lookup.result.dict)
        else {
            fatalError("lookup initialize failed.")
        }
        
        XCTAssertEqual(lookup["result.pageNumber"].int, 1, "the pageNumber is not 1")
        XCTAssertEqual(lookup["result.hasMore"].bool, false, "the hasMore is not false")
        
        XCTAssertEqual(result.pageNumber.int, 1, "the pageNumber is not 1")
        XCTAssertEqual(result.hasMore.int, 0, "the hasMore is not 0")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
