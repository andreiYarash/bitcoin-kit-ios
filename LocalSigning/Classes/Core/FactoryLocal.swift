
class Factory_Local_Usage: IFactory_Local_Usage {
    init() {}

    func transaction(version: Int, lockTime: Int) -> Transaction_Local_Usage {
        Transaction_Local_Usage(version: version, lockTime: lockTime)
    }

    func inputToSign(withPreviousOutput previousOutput: UnspentOutput_Local_Usage, script: Data, sequence: Int) -> InputToSign_Local_Usage {
        let input = Input_Local_Usage(
                withPreviousOutputTxHash: previousOutput.output.transactionHash, previousOutputIndex: previousOutput.output.index,
                script: script, sequence: sequence
        )

        return InputToSign_Local_Usage(input: input, previousOutput: previousOutput.output, previousOutputPublicKey: previousOutput.publicKey)
    }

    func output(withIndex index: Int, address: Address_Local_Usage, value: Int, publicKey: PublicKey_Local_Usage?) -> Output_Local_Usage {
        Output_Local_Usage(withValue: value, index: index, lockingScript: address.lockingScript, type: address.scriptType, address: address.stringValue, keyHash: address.keyHash, publicKey: publicKey)
    }

    func nullDataOutput(data: Data) -> Output_Local_Usage {
        Output_Local_Usage(withValue: 0, index: 0, lockingScript: data, type: .nullData)
    }
}
