// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/**
 An object that decodes instances of a data type from JSON values.
 */
public struct ValueDecoder {
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public func decode<T: Decodable>(_ type: T.Type = T.self, from value: Value) throws -> T {
        let decoder = ValueContainer(value: value, userInfo: userInfo)
        return try decoder.decode(type)
    }
}

struct ValueContainer {
    var value: Value
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
}

extension ValueContainer: Decoder {
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        guard case let .object(members) = value else {
            throw DecodingError.typeMismatch(
                [String: Value].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "fail"
                )
            )
        }
        return KeyedDecodingContainer(
            ObjectValueContainer(
                members: members,
                codingPath: codingPath,
                userInfo: userInfo
            )
        )
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard case let .array(items) = value else {
            throw DecodingError.typeMismatch(
                [Value].self,
                DecodingError.Context(codingPath: codingPath, debugDescription: "fail")
            )
        }
        return ArrayValueContainer(items: items, codingPath: codingPath, userInfo: userInfo)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        self
    }
}

extension ValueContainer: SingleValueDecodingContainer {
    public func decodeNil() -> Bool {
        value == .null
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        guard case let .boolean(result) = value else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }

        return result
    }

    public func decode(_ type: String.Type) throws -> String {
        guard case let .string(result) = value else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        return result
    }

    public func decode<T>(_ type: T.Type) throws -> T
        where T: Decodable & BinaryFloatingPoint {
        guard case let .number(double) = value else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        return T(double)
    }

    public func decode<T>(_ type: T.Type) throws -> T
        where T: Decodable & BinaryInteger {
        guard case let .number(double) = value else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        guard let result = T(exactly: double) else {
            throw DecodingError.typeMismatch(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Unable to represent \(double) as \(type)"
                )
            )
        }
        return result
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try type.init(from: self)
    }
}

struct ArrayValueContainer {
    let items: [Value]
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    var currentIndex: Int = 0
}

extension ArrayValueContainer: UnkeyedDecodingContainer {
    var count: Int? {
        return items.count
    }

    var isAtEnd: Bool {
        return currentIndex == count
    }

    @inlinable
    func guardNotAtEnd<T>(_ type: T.Type) throws {
        if isAtEnd {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath + [ValueKey(intValue: currentIndex)],
                    debugDescription: "End of unkeyed container reached"
                )
            )
        }
    }

    mutating func decodeNil() throws -> Bool {
        try guardNotAtEnd(Value.self)
        if case .null = items[currentIndex] {
            self.currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try guardNotAtEnd(type)
        let decoder = ValueContainer(
            value: items[currentIndex],
            codingPath: codingPath + [ValueKey(intValue: currentIndex)]
        )
        let value = try decoder.decode(type)
        currentIndex += 1
        return value
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try guardNotAtEnd(KeyedDecodingContainer<NestedKey>.self)
        let value = items[self.currentIndex]
        guard case let .object(members) = value else {
            throw
                DecodingError.valueNotFound(
                    KeyedDecodingContainer<NestedKey>.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Cannot get keyed decoding container -- found null value instead."
                    )
                )
        }
        currentIndex += 1
        return KeyedDecodingContainer(
            ObjectValueContainer(
                members: members,
                codingPath: codingPath + [ValueKey(intValue: currentIndex)],
                userInfo: userInfo
            )
        )
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try guardNotAtEnd(UnkeyedDecodingContainer.self)
        let value = items[self.currentIndex]
        guard case let .array(items) = value else {
            throw
                DecodingError.valueNotFound(
                    UnkeyedDecodingContainer.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Cannot get unkeyed decoding container -- found null value instead."
                    )
                )
        }
        currentIndex += 1
        return ArrayValueContainer(
            items: items,
            codingPath: codingPath + [ValueKey(intValue: currentIndex)],
            userInfo: userInfo
        )
    }

    mutating func superDecoder() throws -> Decoder {
        try guardNotAtEnd(Decoder.self)
        let value = items[self.currentIndex]
        currentIndex += 1
        return ValueContainer(value: value, codingPath: codingPath + [ValueKey(intValue: currentIndex)])
    }
}

struct ObjectValueContainer<K: CodingKey> {
    let members: [String: Value]
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
}

extension ObjectValueContainer: KeyedDecodingContainerProtocol {
    typealias Key = K

    var allKeys: [K] {
        members.keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: K) -> Bool {
        members[key.stringValue] != nil
    }

    func guardNil(forKey key: K) throws -> Value {
        guard let value = self.members[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "No value associated with key \(key.stringValue)."
                )
            )
        }

        return value
    }

    func decodeNil(forKey key: K) throws -> Bool {
        let value = try guardNil(forKey: key)
        return value == .null
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let value = try guardNil(forKey: key)
        return try ValueContainer(
            value: value,
            codingPath: codingPath + [key]
        ).decode(type)
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        guard let value = members[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key.stringValue)"
                )
            )
        }
        guard case let .object(members) = value else {
            throw DecodingError.typeMismatch(
                [String: Value].self,
                DecodingError.Context(
                    codingPath: codingPath + [key],
                    debugDescription: "Expected an object, found \(type(of: value))"
                )
            )
        }
        return KeyedDecodingContainer(
            ObjectValueContainer<NestedKey>(
                members: members,
                codingPath: codingPath + [key],
                userInfo: userInfo
            )
        )
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        guard let value = members[key.stringValue] else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key.stringValue)"
                )
            )
        }
        guard case let .array(items) = value else {
            throw DecodingError.typeMismatch(
                [Any].self,
                DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Expected an array, found \(type(of: value))")
            )
        }
        return ArrayValueContainer(
            items: items,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }

    func superDecoder() throws -> Decoder {
        let value: Value = members[ValueKey.super.stringValue] ?? .null
        return ValueContainer(
            value: value,
            codingPath: codingPath + [ValueKey.super]
        )
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        let value: Value = members[key.stringValue] ?? .null
        return ValueContainer(
            value: value,
            codingPath: codingPath + [ValueKey(stringValue: key.stringValue)]
        )
    }
}

private struct ValueKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    fileprivate static let `super` = ValueKey(stringValue: "super")
}
