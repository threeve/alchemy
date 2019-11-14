// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Alchemy

final class ValueDecoderTests: XCTestCase {
    private struct Foo: Decodable, Equatable {
        var boolField: Bool
        var numberField: Double
        var stringField: String
        var arrayField: [String]
    }

    func testDecodeComplexObject() throws {
        let original = Foo(
            boolField: true,
            numberField: 13,
            stringField: "yo",
            arrayField: ["hello", "world"]
        )
        let value: Value = [
            "boolField": true,
            "numberField": 13,
            "stringField": "yo",
            "arrayField": ["hello", "world"],
        ]

        let decoded = try ValueDecoder().decode(
            Foo.self, from: value
        )
        XCTAssertEqual(original, decoded)
    }

    private enum Phony: String, Codable, Equatable {
        case foo
        case bar
        case baz
    }

    func testDecodeEnumArray() throws {
        let value: Value = ["bar", "baz", "foo"]
        let decoded = try ValueDecoder().decode([Phony].self, from: value)
        XCTAssertEqual(decoded, [.bar, .baz, .foo])
    }

    func testDecodeIntArray() throws {
        let value: Value = [13, 42]
        let decoded = try ValueDecoder().decode([Int].self, from: value)
        XCTAssertEqual(decoded, [13, 42])
    }

    func testDecodeStringArray() throws {
        let value: Value = ["hello", "world"]
        let decoded = try ValueDecoder().decode([String].self, from: value)
        XCTAssertEqual(decoded, ["hello", "world"])
    }

    func testDecodeString() throws {
        let original = "hello"
        let decoded = try ValueDecoder().decode(String.self, from: .string(original))
        XCTAssertEqual(original, decoded)
    }

    func testDecodeDouble() throws {
        let original: Double = 123.456
        let decoded = try ValueDecoder().decode(Double.self, from: .number(original))
        XCTAssertEqual(original, decoded)
    }

    func testDecodeFloat() throws {
        let original: Double = 123.456
        let decoded: Float = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(123.456, decoded)
    }

    func testDecodeIntMax() throws {
        let original: Double = Double(Int32.max)
        let decoded: Int = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int(Int32.max), decoded)
    }

    func testDecodeIntMin() throws {
        let original: Double = Double(Int.min)
        let decoded: Int = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int.min, decoded)
    }

    func testDecodeInt8Max() throws {
        let original: Double = Double(Int8.max)
        let decoded: Int8 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int8.max, decoded)
    }

    func testDecodeInt8Min() throws {
        let original: Double = Double(Int8.min)
        let decoded: Int8 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int8.min, decoded)
    }

    func testDecodeInt16Max() throws {
        let original: Double = Double(Int16.max)
        let decoded: Int16 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int16.max, decoded)
    }

    func testDecodeInt16Min() throws {
        let original: Double = Double(Int16.min)
        let decoded: Int16 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int16.min, decoded)
    }

    func testDecodeInt32Max() throws {
        let original: Double = Double(Int32.max)
        let decoded: Int32 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int32.max, decoded)
    }

    func testDecodeInt32Min() throws {
        let original: Double = Double(Int32.min)
        let decoded: Int32 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(Int32.min, decoded)
    }

    func testDecodeUIntMax() throws {
        let original: Double = Double(UInt32.max)
        let decoded: UInt = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt(UInt32.max), decoded)
    }

    func testDecodeUIntMin() throws {
        let original: Double = Double(UInt.min)
        let decoded: UInt = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt.min, decoded)
    }

    func testDecodeUInt8Max() throws {
        let original: Double = Double(UInt8.max)
        let decoded: UInt8 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt8.max, decoded)
    }

    func testDecodeUInt8Min() throws {
        let original: Double = Double(UInt8.min)
        let decoded: UInt8 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt8.min, decoded)
    }

    func testDecodeUInt16Max() throws {
        let original: Double = Double(UInt16.max)
        let decoded: UInt16 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt16.max, decoded)
    }

    func testDecodeUInt16Min() throws {
        let original: Double = Double(UInt16.min)
        let decoded: UInt16 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt16.min, decoded)
    }

    func testDecodeUInt32Max() throws {
        let original: Double = Double(UInt32.max)
        let decoded: UInt32 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt32.max, decoded)
    }

    func testDecodeUInt32Min() throws {
        let original: Double = Double(UInt32.min)
        let decoded: UInt32 = try ValueDecoder().decode(from: .number(original))
        XCTAssertEqual(UInt32.min, decoded)
    }

    func testDecodeBoolTrue() throws {
        let original = true
        let decoded = try ValueDecoder().decode(Bool.self, from: .boolean(original))
        XCTAssertEqual(original, decoded)
    }

    func testDecodeBoolFalse() throws {
        let original = false
        let decoded = try ValueDecoder().decode(Bool.self, from: .boolean(original))
        XCTAssertEqual(original, decoded)
    }

    func testDecodeNil() throws {
        let decoded = try ValueDecoder().decode(Bool?.self, from: .null)
        XCTAssertNil(decoded)
    }

    func testDecodeNilArray() throws {
        let decoded = try ValueDecoder().decode(
            [Int?].self,
            from: .array([.null, .null, .null])
        )
        XCTAssertEqual(
            decoded,
            [nil, nil, nil]
        )
    }

    static var allTests = [
        ("testDecodeString", testDecodeString),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeFloat", testDecodeFloat),
        ("testDecodeIntMax", testDecodeIntMax),
        ("testDecodeIntMin", testDecodeIntMin),
        ("testDecodeInt8Max", testDecodeInt8Max),
        ("testDecodeInt8Min", testDecodeInt8Min),
        ("testDecodeInt16Max", testDecodeInt16Max),
        ("testDecodeInt16Min", testDecodeInt16Min),
        ("testDecodeInt32Max", testDecodeInt32Max),
        ("testDecodeInt32Min", testDecodeInt32Min),
        ("testDecodeUIntMax", testDecodeUIntMax),
        ("testDecodeUIntMin", testDecodeUIntMin),
        ("testDecodeUInt8Max", testDecodeUInt8Max),
        ("testDecodeUInt8Min", testDecodeUInt8Min),
        ("testDecodeUInt16Max", testDecodeUInt16Max),
        ("testDecodeUInt16Min", testDecodeUInt16Min),
        ("testDecodeUInt32Max", testDecodeUInt32Max),
        ("testDecodeUInt32Min", testDecodeUInt32Min),
        ("testDecodeBoolTrue", testDecodeBoolTrue),
        ("testDecodeBoolFalse", testDecodeBoolFalse),
        ("testDecodeNil", testDecodeNil),
    ]
}
