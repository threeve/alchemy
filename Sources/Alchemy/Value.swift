// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/**
 A representation of a JSON value as defined in [RFC 8259].

 [RFC 8259]: https://tools.ietf.org/html/rfc8259
 */
public enum Value {
    case object([String: Value])
    case array([Value])
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
}

extension Value: Equatable {}
