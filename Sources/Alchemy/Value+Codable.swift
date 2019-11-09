// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

struct ValueObjectKey: CodingKey {
    init?(intValue: Int) {
        return nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?
    var stringValue: String
}

extension Value: Decodable {
    struct DecodingError: Error {}

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: ValueObjectKey.self) {
            let properties = try container.allKeys.map {
                ($0.stringValue, try container.decode(Value.self, forKey: $0))
            }
            self = .object(Dictionary(uniqueKeysWithValues: properties))
        } else if var container = try? decoder.unkeyedContainer() {
            var values: [Value] = []
            while !container.isAtEnd {
                let value = try container.decode(Value.self)
                values.append(value)
            }
            self = .array(values)
        } else {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Bool.self) {
                self = .boolean(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else if let value = try? container.decode(Double.self) {
                self = .number(value)
            } else if container.decodeNil() {
                self = .null
            } else {
                throw DecodingError()
            }
        }
    }
}
