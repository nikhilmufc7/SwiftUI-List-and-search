import XCTest
import Combine
@testable import EmployerSearch

final class SearchEmployersUseCaseTests: XCTestCase {
    var sut: SearchEmployersUseCase!
    var mockRepository: MockEmployerRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockEmployerRepository()
        sut = SearchEmployersUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Sorting Tests

    func testSortByNameAscending() {
        let expectation = expectation(description: "Sort by name ascending")

        sut.execute(query: "", sortBy: .nameAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertEqual(employers.first?.name, "ABC Company")
                XCTAssertEqual(employers.last?.name, "Zebra Corp")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByNameDescending() {
        let expectation = expectation(description: "Sort by name descending")

        sut.execute(query: "", sortBy: .nameDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertEqual(employers.first?.name, "Zebra Corp")
                XCTAssertEqual(employers.last?.name, "ABC Company")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByDiscountDescending() {
        let expectation = expectation(description: "Sort by discount descending")

        sut.execute(query: "", sortBy: .discountDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertGreaterThanOrEqual(employers.first!.discountPercentage,
                                           employers.last!.discountPercentage)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByLocationAscending() {
        let expectation = expectation(description: "Sort by location ascending")

        sut.execute(query: "", sortBy: .locationAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                for i in 0..<employers.count-1 {
                    XCTAssertLessThanOrEqual(employers[i].place, employers[i+1].place)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Filtering Tests

    func testFilterByMinDiscount() {
        let expectation = expectation(description: "Filter by minimum discount")

        sut.execute(query: "", minDiscount: 15)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 15)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testFilterByMinDiscountReturnsEmpty() {
        let expectation = expectation(description: "Filter returns empty for high threshold")

        sut.execute(query: "", minDiscount: 100)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertTrue(employers.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testFilterWithZeroDiscount() {
        let expectation = expectation(description: "Filter with zero discount")

        sut.execute(query: "", minDiscount: 0)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertFalse(employers.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Combined Tests

    func testFilterAndSort() {
        let expectation = expectation(description: "Filter and sort combined")

        sut.execute(query: "", minDiscount: 10, sortBy: .discountDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                // All should have 10%+
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 10)
                }
                // Should be sorted descending
                for i in 0..<employers.count-1 {
                    XCTAssertGreaterThanOrEqual(employers[i].discountPercentage,
                                               employers[i+1].discountPercentage)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSearchWithFilterAndSort() {
        let expectation = expectation(description: "Search with filter and sort")

        sut.execute(query: "Amsterdam", minDiscount: 5, sortBy: .nameAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                // All should match query
                for employer in employers {
                    XCTAssertTrue(employer.matches(query: "Amsterdam"))
                }
                // All should have 5%+
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 5)
                }
                // Should be sorted by name
                for i in 0..<employers.count-1 {
                    XCTAssertLessThanOrEqual(employers[i].name, employers[i+1].name)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }
}
