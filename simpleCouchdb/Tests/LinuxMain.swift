import XCTest

import simpleCouchdbTests

var tests = [XCTestCaseEntry]()
tests += simpleCouchdbTests.allTests()
XCTMain(tests)
