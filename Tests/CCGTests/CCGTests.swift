import XCTest
@testable import CCG

class CCGTests: XCTestCase {

    func testForwardApply() {
        let np = Category.atom(.nounPhrase)
        let s = Category.atom(.sentence(nil))
        let s_np_np = Category.forwardFunctor(.backwardFunctor(s, np), np)
        XCTAssertNotNil(s_np_np.appliedForward(to: np))
    }

    func testBackwardApply() {
        let np = Category.atom(.nounPhrase)
        let s = Category.atom(.sentence(nil))
        let s_np_np = Category.backwardFunctor(.forwardFunctor(s, np), np)
        XCTAssertNotNil(s_np_np.appliedBackward(to: np))
    }

    static var allTests : [(String, (CCGTests) -> () throws -> Void)] {
        return [
            
        ]
    }
}
