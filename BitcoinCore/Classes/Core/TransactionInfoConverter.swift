open class TransactionInfoConverter: ITransactionInfoConverter {
    public var baseTransactionInfoConverter: IBaseTransactionInfoConverter!

    public init() {}

    public func transactionInfo(fromTransaction transactionForInfo: FullTransactionForInfo) -> BitTransactionInfo {
        baseTransactionInfoConverter.transactionInfo(fromTransaction: transactionForInfo)
    }

}
