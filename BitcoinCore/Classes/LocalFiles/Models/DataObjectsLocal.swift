
public struct FullTransaction_Local_Usage {

    public let header: Transaction_Local_Usage
    public let inputs: [Input_Local_Usage]
    public let outputs: [Output_Local_Usage]

    public init(header: Transaction_Local_Usage, inputs: [Input_Local_Usage], outputs: [Output_Local_Usage]) {
        self.header = header
        self.inputs = inputs
        self.outputs = outputs

        self.header.dataHash = TransactionSerializer_Local_Usage.serialize(transaction: self, withoutWitness: true).doubleSha256()
        for input in self.inputs {
            input.transactionHash = self.header.dataHash
        }
        for output in self.outputs {
            output.transactionHash = self.header.dataHash
        }
    }

}

public struct InputToSign_Local_Usage {

    let input: Input_Local_Usage
    let previousOutput: Output_Local_Usage
    let previousOutputPublicKey: PublicKey_Local_Usage

}

public struct OutputWithPublicKey_Local_Usage {

    let output: Output_Local_Usage
    let publicKey: PublicKey_Local_Usage
    let spendingInput: Input_Local_Usage?
    let spendingBlockHeight: Int?

}

struct InputWithPreviousOutput_Local_Usage {

    let input: Input_Local_Usage
    let previousOutput: Output_Local_Usage?

}

public struct TransactionWithBlock_Local_Usage {

    public let transaction: Transaction_Local_Usage
    let blockHeight: Int?

}

public struct UnspentOutput_Local_Usage {

    public let output: Output_Local_Usage
    public let publicKey: PublicKey_Local_Usage
    public let transaction: Transaction_Local_Usage
    public let blockHeight: Int?

    public init(output: Output_Local_Usage, publicKey: PublicKey_Local_Usage, transaction: Transaction_Local_Usage, blockHeight: Int? = nil) {
        self.output = output
        self.publicKey = publicKey
        self.transaction = transaction
        self.blockHeight = blockHeight
    }

}

public struct FullTransactionForInfo_Local_Usage {

    public let transactionWithBlock: TransactionWithBlock_Local_Usage
    let inputsWithPreviousOutputs: [InputWithPreviousOutput_Local_Usage]
    let outputs: [Output_Local_Usage]

    var rawTransaction: String {
        let fullTransaction = FullTransaction_Local_Usage(
                header: transactionWithBlock.transaction,
                inputs: inputsWithPreviousOutputs.map { $0.input },
                outputs: outputs
        )

        return TransactionSerializer_Local_Usage.serialize(transaction: fullTransaction).hex
    }

}

public struct PublicKeyWithUsedState_Local_Usage {

    let publicKey: PublicKey_Local_Usage
    let used: Bool

}
