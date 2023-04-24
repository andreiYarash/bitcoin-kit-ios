import Foundation

public extension Data {

    func to_Local_Usage<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.baseAddress!.assumingMemoryBound(to: T.self).pointee }
    }

    func to_Local_Usage(type: String.Type) -> String {
        return String(bytes: self, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }

    func to_Local_Usage(type: VarInt_Local_Usage.Type) -> VarInt_Local_Usage {
        let value: UInt64
        let length = self[0..<1].to_Local_Usage(type: UInt8.self)
        switch length {
        case 0...252:
            value = UInt64(length)
        case 0xfd:
            value = UInt64(self[1...2].to_Local_Usage(type: UInt16.self))
        case 0xfe:
            value = UInt64(self[1...4].to_Local_Usage(type: UInt32.self))
        case 0xff:
            fallthrough
        default:
            value = self[1...8].to_Local_Usage(type: UInt64.self)
        }
        return VarInt_Local_Usage(value)
    }
}
