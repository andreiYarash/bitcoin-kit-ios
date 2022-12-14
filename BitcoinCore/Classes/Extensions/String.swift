import Foundation
// import UIExtensions

extension String {

    public var reversedData: Data? {
        return Data(bithex: self).map { Data($0.reversed()) }
    }

    public func stripHexPrefix() -> String {
        let prefix = "0x"

        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }

        return self
    }

}

extension Data {

    public init?(bithex: String) {
        let hex = bithex.stripHexPrefix()

        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    public var bithex: String {
        reduce("") { $0 + String(format: "%02x", $1) }
    }

    public var reversedHex: String {
        Data(self.reversed()).bithex
    }

}
