// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Alchemy

final class ValueTests: XCTestCase {
    func testEquatableNull() {
        XCTAssertEqual(Value.null, .null)
    }

    func testEquatableBool() {
        XCTAssertEqual(Value.boolean(true), .boolean(true))
        XCTAssertEqual(Value.boolean(false), .boolean(false))
    }

    func testEquatableNumber() {
        XCTAssertEqual(Value.number(0), .number(0))
        XCTAssertEqual(Value.number(-9999), .number(-9999))
        XCTAssertEqual(Value.number(42.3576), .number(42.3576))
        XCTAssertEqual(Value.number(Double.greatestFiniteMagnitude), .number(Double.greatestFiniteMagnitude))
    }

    func testEquatableString() {
        XCTAssertEqual(Value.string(""), .string(""))
        XCTAssertEqual(Value.string("a"), .string("a"))
        XCTAssertEqual(
            Value.string(String(repeating: "hello", count: 999)),
            .string(String(repeating: "hello", count: 999))
        )
    }

    func testEquatableArray() {
        let left = Value.array([.string("hi"), .number(99), .null, .boolean(true)])
        let right = Value.array([.string("hi"), .number(99), .null, .boolean(true)])
        XCTAssertEqual(left, right)
    }

    func testEquatableObject() {
        let left = Value.object([
            "string": .string("hi"),
            "number": .number(99),
            "null": .null,
            "bool": .boolean(true),
            "array": .array([.null]),
        ])
        let right = Value.object([
            "string": .string("hi"),
            "number": .number(99),
            "null": .null,
            "bool": .boolean(true),
            "array": .array([.null]),
        ])
        XCTAssertEqual(left, right)
    }

    static var allTests = [
        ("testEquatableNull", testEquatableNull),
        ("testEquatableBool", testEquatableBool),
        ("testEquatableNumber", testEquatableNumber),
        ("testEquatableString", testEquatableString),
        ("testEquatableArray", testEquatableArray),
        ("testEquatableObject", testEquatableObject),
    ]
}
