
enum ScriptError_Local_Usage: Error { case wrongScriptLength, wrongSequence, unexpectedScriptType }

public class ScriptConverter_Local_Usage {

    public init() {}

    public func encode(script: Script_Local_Usage) -> Data {
        var scriptData = Data()
        script.chunks.forEach { chunk in
            if let data = chunk.data {
                scriptData += OpCode_Local_Usage.push(data)
            } else {
                scriptData += Data([chunk.opCode])
            }
        }
        return scriptData
    }

    private func getPushRange(data: Data, it: Int) throws -> Range<Int> {
        let opCode = data[it]

        var bytesCount: Int?
        var bytesOffset = 1
        switch opCode {
			case 0x01..<OpCode_Local_Usage.pushData1: bytesCount = Int(opCode)
			case OpCode_Local_Usage.pushData1:                              // The next byte contains the number of bytes to be pushed onto the stack
                bytesOffset += 1
                guard data.count > 1 else {
                    throw ScriptError_Local_Usage.wrongScriptLength
                }
                bytesCount = Int(data[1])
			case OpCode_Local_Usage.pushData2:                              // The next two bytes contain the number of bytes to be pushed onto the stack in little endian order
                bytesOffset += 2
                guard data.count > 2 else {
                    throw ScriptError_Local_Usage.wrongScriptLength
                }
                bytesCount = Int(data[2]) << 8 + Int(data[1])
			case OpCode_Local_Usage.pushData4:                              // The next four bytes contain the number of bytes to be pushed onto the stack in little endian order
                bytesOffset += 4
                guard data.count > 5 else {
                    throw ScriptError_Local_Usage.wrongScriptLength
                }
                var index = bytesOffset
                var count = 0
                while index >= 0 {
                    count += count << 8 + Int(data[1 + index])
                    index -= 1
                }
                bytesCount = count
            default: break
        }
        guard let keyLength = bytesCount, data.count >= it + bytesOffset + keyLength else {
            throw ScriptError_Local_Usage.wrongScriptLength
        }
        return Range(uncheckedBounds: (lower: it + bytesOffset, upper: it + bytesOffset + keyLength))
    }

}

extension ScriptConverter_Local_Usage: IScriptConverter_Local_Usage {

    public func decode(data: Data) throws -> Script_Local_Usage {
        var chunks = [Chunk_Local_Usage]()
        var it = 0
        while it < data.count {
            let opCode = data[it]
            switch opCode {
			case 0x01...OpCode_Local_Usage.pushData4:
                let range = try getPushRange(data: data, it: it)
                chunks.append(Chunk_Local_Usage(scriptData: data, index: it, payloadRange: range))
                it = range.upperBound
            default:
                chunks.append(Chunk_Local_Usage(scriptData: data, index: it, payloadRange: nil))
                it += 1
            }
        }
        return Script_Local_Usage(with: data, chunks: chunks)
    }

}
