import XCTest
@testable import DmcKit

final class DmcKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DmcKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
