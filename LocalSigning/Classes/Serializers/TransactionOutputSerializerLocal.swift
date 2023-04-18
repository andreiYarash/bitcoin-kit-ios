import Foundation

class TransactionOutputSerializer_Local_Usage {

     static func serialize(output: Output_Local_Usage) -> Data {
        var data = Data()

        data += output.value
        let scriptLength = VarInt_Local_Usage(output.lockingScript.count)
        data += scriptLength.serialized()
        data += output.lockingScript

        return data
    }

    static func deserialize(byteStream: ByteStream_Local_Usage) -> Output_Local_Usage {
        let value = Int(byteStream.read(Int64.self))
        let scriptLength: VarInt_Local_Usage = byteStream.read(VarInt_Local_Usage.self)
        let lockingScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))

        return Output_Local_Usage(withValue: value, index: 0, lockingScript: lockingScript)
    }

}
