// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Alchemy

final class ValueCodableTests: XCTestCase {
    func testValueObjectKey() {
        XCTAssertNil(ValueObjectKey(intValue: 0))
    }

    func testDecode() throws {
        let json = """
        {
            "null": null,
            "bool": true,
            "number": 13,
            "string": "hi",
            "array": [null, true, 13, "hi"]
        }
        """
        let expected: Value = [
            "null": nil,
            "bool": true,
            "number": 13,
            "string": "hi",
            "array": [nil, true, 13, "hi"],
        ]
        let jsonData = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Value.self, from: jsonData)
        XCTAssertEqual(decoded, expected)
    }

    static var allTests = [
        ("testValueObjectKey", testValueObjectKey),
        ("testDecode", testDecode),
    ]
}
