class TransactionCreator_Local_Usage {
    enum CreationError: Error {
        case transactionAlreadyExists
    }
    
    private let transactionBuilder: ITransactionBuilder_Local_Usage

    init(transactionBuilder: ITransactionBuilder_Local_Usage) {
        self.transactionBuilder = transactionBuilder
    }
}

extension TransactionCreator_Local_Usage: ITransactionCreator_Local_Usage {
    func createRawTransaction(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws -> Data {
        let transaction = try transactionBuilder.buildTransaction(
            toAddress: address,
            value: value,
            feeRate: feeRate,
            senderPay: senderPay,
            sortType: sortType,
            signatures: signatures,
            changeScript: changeScript,
            sequence: sequence,
            pluginData: pluginData
        )

        return TransactionSerializer_Local_Usage.serialize(transaction: transaction)
    }
    
    func createRawHashesToSign(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, pluginData: [UInt8 : IPluginData_Local_Usage]) throws -> [Data] {
        let hashes = try transactionBuilder.buildTransactionToSign(
            toAddress: address,
            value: value,
            feeRate: feeRate,
            senderPay: senderPay,
            sortType: sortType,
            changeScript: changeScript,
            sequence: sequence,
            pluginData: pluginData
        )
        
        return hashes
    }
}


