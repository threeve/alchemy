// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable nesting

import XCTest
@testable import Alchemy

final class ValueDecoderTests: XCTestCase {
    func testKeyedContainerFromNonObjectThrows() throws {
        struct Foo: Decodable {
            enum CodingKeys: String, CodingKey {
                case phony
            }

            init(from decoder: Decoder) throws {
                _ = try decoder.container(keyedBy: CodingKeys.self)
            }
        }
        let value: Value = [1, 2, 3]
        XCTAssertThrowsError(
            try ValueDecoder().decode(Foo.self, from: value)
        )
    }

    func testUnkeyedContainerFromNonArrayThrows() throws {
        struct Foo: Decodable {
            init(from decoder: Decoder) throws {
                _ = try decoder.unkeyedContainer()
            }
        }
        let value: Value = ["key": "value"]
        XCTAssertThrowsError(
            try ValueDecoder().decode(Foo.self, from: value)
        )
    }

    func testDecodeBoolFromNullThrows() throws {
        let value: Value = nil
        XCTAssertThrowsError(
            try ValueDecoder().decode(Bool.self, from: value)
        )
    }

    func testDecodeStringFromWrongTypeThrows() throws {
        let value: Value = false
        XCTAssertThrowsError(
            try ValueDecoder().decode(String.self, from: value)
        )
    }

    func testDecodeIntFromWrongTypeThrows() throws {
        let value: Value = false
        XCTAssertThrowsError(
            try ValueDecoder().decode(Int.self, from: value)
        )
    }

    func testDecodeDoubleFromWrongTypeThrows() throws {
        let value: Value = false
        XCTAssertThrowsError(
            try ValueDecoder().decode(Double.self, from: value)
        )
    }

    func testDecodeOutOfRangeIntegerThrows() throws {
        let value: Value = 128
        XCTAssertThrowsError(
            try ValueDecoder().decode(Int8.self, from: value)
        )
    }

    func testDecodePastEndOfUnkeyedContainerThrows() throws {
        struct Foo: Decodable {
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                _ = try container.decode(Bool.self)
                _ = try container.decode(Bool.self)
                _ = try container.decode(Bool.self)
            }
        }
        let value: Value = [true, false]
        XCTAssertThrowsError(
            try ValueDecoder().decode(Foo.self, from: value)
        )
    }

    func testDecodeNilFromUnkeyedContainer() throws {
        struct Foo: Decodable {
            let nils: Int
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var nils = 0
                if try container.decodeNil() { nils += 1 }
                if try container.decodeNil() { nils += 1 }
                self.nils = nils
            }
        }
        let value: Value = [nil, false]
        let foo = try ValueDecoder().decode(Foo.self, from: value)
        XCTAssertEqual(foo.nils, 1)
    }

    func testDecodeKeyedContainerNestedInUnkeyedContainer() throws {
        struct Foo: Decodable {
            enum CodingKeys: String, CodingKey {
                case foo
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                _ = try container.nestedContainer(keyedBy: CodingKeys.self)
            }
        }
        XCTAssertThrowsError(
            try ValueDecoder().decode(Foo.self, from: [1, 2, 3])
        )
        XCTAssertNoThrow(
            try ValueDecoder().decode(Foo.self, from: [["foo": "bar"]])
        )
    }

    func testDecodeUnkeyedContainerNestedInUnkeyedContainer() throws {
        struct Foo: Decodable {
            enum CodingKeys: String, CodingKey {
                case foo
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                _ = try container.nestedUnkeyedContainer()
            }
        }
        XCTAssertThrowsError(
            try ValueDecoder().decode(Foo.self, from: [1, 2, 3])
        )
        XCTAssertNoThrow(
            try ValueDecoder().decode(Foo.self, from: [["foo", "bar"]])
        )
    }

    func testDecodeSuperFromUnkeyedContainer() throws {
        struct Foo: Decodable {
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                _ = try container.superDecoder()
            }
        }
        XCTAssertNoThrow(
            try ValueDecoder().decode(Foo.self, from: [[:]])
        )
    }

    func testDecodeSuperFromKeyedContainer() throws {
        struct Foo: Decodable {
            enum CodingKeys: String, CodingKey {
                case foo
                case foosuper
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                _ = try container.superDecoder()
                _ = try container.superDecoder(forKey: .foosuper)
            }
        }

        XCTAssertNoThrow(
            try ValueDecoder().decode(Foo.self, from: ["super": [:]])
        )
        XCTAssertNoThrow(
            // returns a super container wrapping .null
            try ValueDecoder().decode(Foo.self, from: ["notsuper": [:]])
        )
    }

    func testKeyedContainerAllKeys() throws {
        struct Foo: Decodable {
            var keys: [CodingKeys]
            enum CodingKeys: String, CodingKey {
                case one
                case two
                case three
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                keys = container.allKeys
            }
        }

        let foo1 = try ValueDecoder().decode(Foo.self, from: ["one": nil])
        XCTAssertEqual(foo1.keys.map { $0.stringValue }, ["one"])

        let foo2 = try ValueDecoder().decode(Foo.self, from: [
            "one": nil,
            "two": nil,
            "three": nil,
            "four": nil,
        ])
        XCTAssertEqual(
            foo2.keys.map { $0.stringValue }.sorted(),
            ["one", "three", "two"]
        )
    }

    func testDecodeComplexObject() throws {
        struct Foo: Decodable, Equatable {
            var boolField: Bool
            var numberField: Double
            var stringField: String
            var arrayField: [String]
        }

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

    func testDecodeEnumArray() throws {
        enum Phony: String, Codable, Equatable {
            case foo
            case bar
            case baz
        }
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
