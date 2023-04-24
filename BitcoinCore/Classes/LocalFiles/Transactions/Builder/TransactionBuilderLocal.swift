class TransactionBuilder_Local_Usage {
    private let recipientSetter: IRecipientSetter_Local_Usage
    private let inputSetter: IInputSetter_Local_Usage
    private let outputSetter: IOutputSetter_Local_Usage
    private let signer: TransactionSigner_Local_Usage

    init(recipientSetter: IRecipientSetter_Local_Usage, inputSetter: IInputSetter_Local_Usage, outputSetter: IOutputSetter_Local_Usage, signer: TransactionSigner_Local_Usage) {
        self.recipientSetter = recipientSetter
        self.inputSetter = inputSetter
        self.outputSetter = outputSetter
        self.signer = signer
    }

}

extension TransactionBuilder_Local_Usage: ITransactionBuilder_Local_Usage {
    func buildTransaction(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> FullTransaction_Local_Usage {
        let mutableTransaction = MutableTransaction_Local_Usage()

        try recipientSetter.setRecipient(to: mutableTransaction, toAddress: toAddress, value: value, pluginData: pluginData, skipChecks: false)
        try inputSetter.setInputs(to: mutableTransaction, feeRate: feeRate, senderPay: senderPay, sortType: sortType, changeScript: changeScript, sequence: sequence, feeCalculation: false)

        outputSetter.setOutputs(to: mutableTransaction, sortType: sortType)
        try signer.sign(mutableTransaction: mutableTransaction, signatures: signatures)

        return mutableTransaction.build()
    }
    
    func buildTransactionToSign(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, pluginData: [UInt8 : IPluginData_Local_Usage]) throws -> [Data] {
        let mutableTransaction = MutableTransaction_Local_Usage()

        try recipientSetter.setRecipient(to: mutableTransaction, toAddress: toAddress, value: value, pluginData: pluginData, skipChecks: false)
        try inputSetter.setInputs(to: mutableTransaction, feeRate: feeRate, senderPay: senderPay, sortType: sortType, changeScript: changeScript, sequence: sequence, feeCalculation: false)

        outputSetter.setOutputs(to: mutableTransaction, sortType: sortType)
        let hashes = try signer.hashesToSign(mutableTransaction:mutableTransaction)
        return hashes
    }

}
