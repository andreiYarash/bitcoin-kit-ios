class TransactionSigner_Local_Usage {
    enum SignError: Error {
        case notSupportedScriptType
        case noRedeemScript
    }

    private let inputSigner: IInputSigner_Local_Usage

    init(inputSigner: IInputSigner_Local_Usage) {
        self.inputSigner = inputSigner
    }

    private func signatureScript(from sigScriptData: [Data]) -> Data {
        sigScriptData.reduce(Data()) {
            $0 + OpCode_Local_Usage.push($1)
        }
    }

}

extension TransactionSigner_Local_Usage: ITransactionSigner_Local_Usage {
    func sign(mutableTransaction: MutableTransaction_Local_Usage, signatures: [Data]) throws {
        for (index, inputToSign) in mutableTransaction.inputsToSign.enumerated() {
            let previousOutput = inputToSign.previousOutput
            let publicKey = inputToSign.previousOutputPublicKey

            var sigScriptData = try inputSigner.sigScriptData(
                    transaction: mutableTransaction.transaction,
                    inputsToSign: mutableTransaction.inputsToSign,
                    outputs: mutableTransaction.outputs,
                    index: index,
                    inputSignature: signatures[index]
            )

            switch previousOutput.scriptType {
            case .p2pkh:
                inputToSign.input.signatureScript = signatureScript(from: sigScriptData)
            case .p2wpkh, .p2wsh:
                mutableTransaction.transaction.segWit = true
				if previousOutput.scriptType == .p2wsh {
					guard let redeemScript = previousOutput.redeemScript else {
						throw SignError.noRedeemScript
					}
					inputToSign.input.witnessData = [Data(), sigScriptData[0], redeemScript]
				} else {
					inputToSign.input.witnessData = sigScriptData
//                    var sigScript = sigScriptData.map { dataValue -> Data in
//                        var data = Data()
//                        data += OpCode_Local_Usage.dup
//                        data += OpCode_Local_Usage.hash160
//                        data += inputToSign.input.keyHash ?? Data()
//                        data += OpCode_Local_Usage.equalVerify
//                       //
//                        data += OpCode_Local_Usage.checkSigVerify
//                        data += OpCode_Local_Usage.push(1)
//                        return data
//                    }
    
                    print("Final Signuture is: \(signatures[index].hex)")
                   // inputToSign.input.signatureScript = signatureScript(from: sigScriptData)
                    
                    //inputToSign.input.keyHash = publicKey.keyHash
                    
				}
            case .p2wpkhSh:
                mutableTransaction.transaction.segWit = true
                inputToSign.input.witnessData = sigScriptData
                inputToSign.input.signatureScript = OpCode_Local_Usage.push(OpCode_Local_Usage.scriptWPKH(publicKey.keyHash))
			case .p2sh:
                guard let redeemScript = previousOutput.redeemScript else {
                    throw SignError.noRedeemScript
                }

                if let signatureScriptFunction = previousOutput.signatureScriptFunction {
                    // non-standard P2SH signature script
                    inputToSign.input.signatureScript = signatureScriptFunction(sigScriptData)
                } else {
                    // standard (signature, publicKey, redeemScript) signature script
                    sigScriptData.append(redeemScript)
					inputToSign.input.signatureScript = Data([0x00]) + signatureScript(from: sigScriptData)
                }
            default: throw SignError.notSupportedScriptType
            }
        }
    }

    func hashesToSign(mutableTransaction: MutableTransaction_Local_Usage) throws -> [Data] {
        var hashes = [Data]()
        for index in mutableTransaction.inputsToSign.indices {
            let hash = try inputSigner.sigScriptHashToSign (
                transaction: mutableTransaction.transaction,
                inputsToSign: mutableTransaction.inputsToSign,
                outputs: mutableTransaction.outputs,
                index: index
            )
            hashes.append(hash)
        }
        return hashes
    }
}
