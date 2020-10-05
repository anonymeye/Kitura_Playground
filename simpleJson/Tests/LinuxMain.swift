import XCTest

import simpleJsonTests

var tests = [XCTestCaseEntry]()
tests += simpleJsonTests.allTests()
XCTMain(tests)
