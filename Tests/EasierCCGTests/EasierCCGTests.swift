import XCTest
@testable import EasierCCG

class EasierCCGTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(EasierCCG().text, "Hello, World!")
    }


    static var allTests : [(String, (EasierCCGTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
