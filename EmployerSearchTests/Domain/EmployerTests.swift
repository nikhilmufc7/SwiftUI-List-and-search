import XCTest
@testable import EmployerSearch

final class EmployerTests: XCTestCase {

    func testMatches_WithMatchingName_ReturnsTrue() {
        let employer = Employer(id: 1, name: "Achmea Zeist", place: "ZEIST", discountPercentage: 17)

        XCTAssertTrue(employer.matches(query: "Achmea"))
        XCTAssertTrue(employer.matches(query: "achmea"))
        XCTAssertTrue(employer.matches(query: "ZEIST"))
    }

    func testMatches_WithNonMatchingQuery_ReturnsFalse() {
        let employer = Employer(id: 1, name: "Achmea Zeist", place: "ZEIST", discountPercentage: 17)

        XCTAssertFalse(employer.matches(query: "Amsterdam"))
        XCTAssertFalse(employer.matches(query: "Rabobank"))
    }

    func testMatches_WithEmptyQuery_ReturnsTrue() {
        let employer = Employer(id: 1, name: "Achmea Zeist", place: "ZEIST", discountPercentage: 17)

        XCTAssertTrue(employer.matches(query: ""))
    }

    func testDisplayName_CombinesNameAndPlace() {
        let employer = Employer(id: 1, name: "Achmea Zeist", place: "ZEIST", discountPercentage: 17)

        XCTAssertEqual(employer.displayName, "Achmea Zeist - ZEIST")
    }
}
