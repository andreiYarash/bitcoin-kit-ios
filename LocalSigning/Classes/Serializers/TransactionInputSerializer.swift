import Foundation

class TransactionInputSerializer_Local_Usage {

    static func serialize(input: Input_Local_Usage) -> Data {
        var data = Data()
        data += input.previousOutputTxHash
        data += UInt32(input.previousOutputIndex)

        let scriptLength = VarInt_Local_Usage(input.signatureScript.count)
        data += scriptLength.serialized()
        data += input.signatureScript
        data += UInt32(input.sequence)

        return data
    }

    static func serializedOutPoint(input: InputToSign_Local_Usage) throws -> Data {
        var data = Data()
        let output = input.previousOutput

        data += output.transactionHash
        data += UInt32(output.index)

        return data
    }

    static func serializedForSignature(inputToSign: InputToSign_Local_Usage, forCurrentInputSignature: Bool) throws -> Data {
        var data = Data()
        let output = inputToSign.previousOutput

        data += output.transactionHash
        data += UInt32(output.index)

        if forCurrentInputSignature {
            let script: Data
            switch inputToSign.previousOutput.scriptType {
            case .p2sh:
                guard let redeemScript = inputToSign.previousOutput.redeemScript else {
                    throw SerializationError_Local_Usage.noPreviousOutputScript
                }
                script = redeemScript
            default:
                script = output.lockingScript
            }

            let scriptLength = VarInt_Local_Usage(script.count)
            data += scriptLength.serialized()
            data += script
        } else {
            data += VarInt_Local_Usage(0).serialized()
        }

        data += UInt32(inputToSign.input.sequence)

        return data
    }

    static func deserialize(byteStream: ByteStream_Local_Usage) -> Input_Local_Usage {
        let previousOutputTxHash = byteStream.read(Data.self, count: 32)
        let previousOutputIndex = Int(byteStream.read(UInt32.self))
        let scriptLength: VarInt_Local_Usage = byteStream.read(VarInt_Local_Usage.self)
        let signatureScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))
        let sequence = Int(byteStream.read(UInt32.self))

        return Input_Local_Usage(
                withPreviousOutputTxHash: previousOutputTxHash, previousOutputIndex: previousOutputIndex,
                script: signatureScript, sequence: sequence
        )
    }

}
