
class InputSigner_Local_Usage {
    enum SignError: Error {
        case noPreviousOutput
        case noPreviousOutputAddress
        case noPrivateKey
    }

    let network: INetwork_Local_Usage

    init(network: INetwork_Local_Usage) {
        self.network = network
    }

}

extension InputSigner_Local_Usage: IInputSigner_Local_Usage {
    func sigScriptData(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign_Local_Usage], outputs: [Output_Local_Usage], index: Int, inputSignature: Data) throws -> [Data] {
        let input = inputsToSign[index]
        let previousOutput = input.previousOutput
        let pubKey = input.previousOutputPublicKey
        let publicKey = pubKey.raw

		let witness = previousOutput.scriptType == .p2wpkh || previousOutput.scriptType == .p2wpkhSh || previousOutput.scriptType == .p2wsh

        var serializedTransaction = try TransactionSerializer_Local_Usage.serializedForSignature(transaction: transaction, inputsToSign: inputsToSign, outputs: outputs, inputIndex: index, forked: witness || network.sigHash.forked)
        serializedTransaction += UInt32(network.sigHash.value)
        let signature = inputSignature + Data([network.sigHash.value])

        switch previousOutput.scriptType {
		case .p2pk, .p2wsh, .p2sh: return [signature]
        default: return [signature, publicKey]
        }
    }
    
    func sigScriptHashToSign(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign_Local_Usage], outputs: [Output_Local_Usage], index: Int) throws -> Data {
        let input = inputsToSign[index]
        let previousOutput = input.previousOutput
		let witness = previousOutput.scriptType == .p2wpkh || previousOutput.scriptType == .p2wpkhSh || previousOutput.scriptType == .p2wsh

        var serializedTransaction = try TransactionSerializer_Local_Usage.serializedForSignature(transaction: transaction, inputsToSign: inputsToSign, outputs: outputs, inputIndex: index, forked: witness || network.sigHash.forked)
        serializedTransaction += UInt32(network.sigHash.value)
        let signatureHash = serializedTransaction.doubleSha256()
        return signatureHash
    }

}
