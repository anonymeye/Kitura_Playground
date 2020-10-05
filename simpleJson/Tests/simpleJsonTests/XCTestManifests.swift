import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(simpleJsonTests.allTests),
    ]
}
#endif
