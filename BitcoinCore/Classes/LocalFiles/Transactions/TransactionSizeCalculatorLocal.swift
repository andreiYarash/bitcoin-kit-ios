public class TransactionSizeCalculator_Local_Usage {
    static let legacyTx = 16 + 4 + 4 + 16          //40 Version + number of inputs + number of outputs + locktime
    static let legacyWitnessData = 1               //1 Only 0x00 for legacy input
    static let witnessData = 1 + signatureLength + pubKeyLength   //108 Number of stack items for input + Size of stack item 0 + Stack item 0, signature + Size of stack item 1 + Stack item 1, pubkey
    static let witnessTx = legacyTx + 1 + 1        //42 SegWit marker + SegWit flag

    static let signatureLength = 72 + 1     // signature length plus pushByte
    static let pubKeyLength = 33 + 1         // pubKey length plus pushByte
    static let uncompressedPubKeyLength = 65 + 1         // pubKey length plus pushByte
    static let p2wpkhShLength = 22 + 1          // 0014<20byte-scriptHash> plus pushByte

    public init() {}

    private func outputSize(lockingScriptSize: Int) -> Int {
        8 + 1 + lockingScriptSize            // spentValue + scriptLength + script
    }

    private func inputSize(output: Output_Local_Usage) -> Int {              // in real bytes
        // Here we calculate size for only those inputs, which we can sign later in TransactionSigner.swift
        // Any other inputs will fail to sign later, so no need to calculate size here

        let sigScriptLength: Int
        switch output.scriptType {
        case .p2pkh: sigScriptLength = TransactionSizeCalculator_Local_Usage.signatureLength + TransactionSizeCalculator_Local_Usage.uncompressedPubKeyLength
        case .p2pk: sigScriptLength = TransactionSizeCalculator_Local_Usage.signatureLength
        case .p2wpkhSh: sigScriptLength = TransactionSizeCalculator_Local_Usage.p2wpkhShLength
        case .p2sh:
            if let redeemScript = output.redeemScript {
                if let signatureScriptFunction = output.signatureScriptFunction {
                    // non-standard P2SH signature script
                    let emptySignature = Data(repeating: 0, count: TransactionSizeCalculator_Local_Usage.signatureLength)
                
                    let emptyPublicKey = Data(repeating: 0, count: TransactionSizeCalculator_Local_Usage.pubKeyLength)

                    sigScriptLength = signatureScriptFunction([emptySignature, emptyPublicKey]).count
                } else {
                    // standard (signature, publicKey, redeemScript) signature script
                    sigScriptLength = TransactionSizeCalculator_Local_Usage.signatureLength + TransactionSizeCalculator_Local_Usage.pubKeyLength + OpCode_Local_Usage.push(redeemScript).count
                }
            } else {
                sigScriptLength = 0
            }
        default: sigScriptLength = 0
        }
        let inputTxSize: Int = 32 + 4 + 1 + sigScriptLength + 4 // PreviousOutputHex + InputIndex + sigLength + sigScript + sequence
        return inputTxSize
    }
}

extension TransactionSizeCalculator_Local_Usage: ITransactionSizeCalculator_Local_Usage {

    public func transactionSize(previousOutputs: [Output_Local_Usage], outputScriptTypes: [ScriptType_Local_Usage]) -> Int {      // in real bytes upped to int
        transactionSize(previousOutputs: previousOutputs, outputScriptTypes: outputScriptTypes, pluginDataOutputSize: 0)
    }

    public func transactionSize(previousOutputs: [Output_Local_Usage], outputScriptTypes: [ScriptType_Local_Usage], pluginDataOutputSize: Int) -> Int {      // in real bytes upped to int
        var segWit = false
        var inputWeight = 0

        for previousOutput in previousOutputs {
            if previousOutput.scriptType.witness {
                segWit = true
                break
            }
        }

        previousOutputs.forEach { previousOutput in
            inputWeight += inputSize(output: previousOutput) * 4      // to vbytes
            if segWit {
                inputWeight += witnessSize(type: previousOutput.scriptType)
            }
        }

        var outputWeight: Int = outputScriptTypes.reduce(0) { $0 + outputSize(type: $1) } * 4 // in vbytes
        if pluginDataOutputSize > 0 {
            outputWeight += outputSize(lockingScriptSize: pluginDataOutputSize) * 4
        }
        let txWeight = segWit ? TransactionSizeCalculator_Local_Usage.witnessTx : TransactionSizeCalculator_Local_Usage.legacyTx

        return toBytes(fee: txWeight + inputWeight + outputWeight)
    }

    public func outputSize(type: ScriptType_Local_Usage) -> Int {              // in real bytes
        outputSize(lockingScriptSize: Int(type.size))
    }

    public func inputSize(type: ScriptType_Local_Usage) -> Int {              // in real bytes
        let sigScriptLength: Int
        switch type {
        case .p2pkh: sigScriptLength = TransactionSizeCalculator_Local_Usage.signatureLength + TransactionSizeCalculator_Local_Usage.uncompressedPubKeyLength
        case .p2pk: sigScriptLength = TransactionSizeCalculator_Local_Usage.signatureLength
        case .p2wpkhSh: sigScriptLength = TransactionSizeCalculator_Local_Usage.p2wpkhShLength
        default: sigScriptLength = 0
        }
        let inputTxSize: Int = 32 + 4 + 1 + sigScriptLength + 4 // PreviousOutputHex + InputIndex + sigLength + sigScript + sequence
        return inputTxSize
    }

    public func witnessSize(type: ScriptType_Local_Usage) -> Int {             // in vbytes
        // We assume that only P2WPKH or P2WPKH(SH) outputs can be here

        if type.witness {
            return TransactionSizeCalculator_Local_Usage.witnessData
        }
        return TransactionSizeCalculator_Local_Usage.legacyWitnessData
    }

    public func toBytes(fee: Int) -> Int {
        fee / 4 + (fee % 4 == 0 ? 0 : 1)
    }

}
