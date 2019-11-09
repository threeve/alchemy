// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Alchemy

final class ValueExpressibleByLiteralTests: XCTestCase {
    func testLiteralNull() {
        let value: Value = nil
        XCTAssertEqual(value, .null)
    }

    func testLiteralBool() {
        let trueValue: Value = true
        XCTAssertEqual(trueValue, Value.boolean(true))
        let falseValue: Value = false
        XCTAssertEqual(falseValue, .boolean(false))
    }

    func testLiteralInteger() {
        let value: Value = 1
        XCTAssertEqual(value, .number(1))
    }

    func testLiteralDouble() {
        let value: Value = 1.5
        XCTAssertEqual(value, .number(1.5))
    }

    func testLiteralString() {
        let value: Value = "hello"
        XCTAssertEqual(value, .string("hello"))
    }

    func testLiteralArray() {
        let value: Value = ["foo", 10, true]
        XCTAssertEqual(value, .array([.string("foo"), .number(10), .boolean(true)]))
    }

    func testLiteralDictionary() {
        let value: Value = [
            "boolean": true,
            "null": nil,
            "number": 13,
            "string": "howdy",
            "array": [nil, false, 0, "no"],
            "object": [
                "nested": true,
            ],
        ]
        let expected: Value = .object([
            "boolean": .boolean(true),
            "null": .null,
            "number": .number(13),
            "string": .string("howdy"),
            "array": .array([.null, .boolean(false), .number(0), .string("no")]),
            "object": .object([
                "nested": .boolean(true),
            ]),
        ])
        XCTAssertEqual(value, expected)
    }

    static var allTests = [
        ("testLiteralNull", testLiteralNull),
        ("testLiteralBool", testLiteralBool),
        ("testLiteralInteger", testLiteralInteger),
        ("testLiteralDouble", testLiteralDouble),
        ("testLiteralString", testLiteralString),
        ("testLiteralArray", testLiteralArray),
        ("testLiteralDictionary", testLiteralDictionary),
    ]
}
