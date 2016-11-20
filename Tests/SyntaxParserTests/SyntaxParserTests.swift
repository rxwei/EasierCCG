import XCTest
@testable import SyntaxParser

class SyntaxParserTests: XCTestCase {

    func testInitHeap() {
        let elems = [10,5,3,6,4]
        var mh = PriorityQueue(elements: elems)
        var out: [Int] = []
        while !mh.isEmpty {
            out.append(mh.removeMin())
        }
        XCTAssertEqual(out, [3,4,5,6,10])
    }

    func testInitHeap2() {
        let elems = [10,5,3,6,4,42]
        var mh = PriorityQueue(elements: elems)
        var out: [Int] = []
        while !mh.isEmpty {
            out.append(mh.removeMin())
        }
        XCTAssertEqual(out, [3,4,5,6,10,42])
    }

    static var allTests : [(String, (SyntaxParserTests) -> () throws -> Void)] {
        return [
            
        ]
    }
}
