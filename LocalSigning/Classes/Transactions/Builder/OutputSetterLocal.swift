class OutputSetter_Local_Usage {
    private let outputSorterFactory: ITransactionDataSorterFactory_Local_Usage
    private let factory: IFactory_Local_Usage

    init(outputSorterFactory: ITransactionDataSorterFactory_Local_Usage, factory: IFactory_Local_Usage) {
        self.outputSorterFactory = outputSorterFactory
        self.factory = factory
    }

}

extension OutputSetter_Local_Usage: IOutputSetter_Local_Usage {

    func setOutputs(to transaction: MutableTransaction_Local_Usage, sortType: TransactionDataSortType_Local_Usage) {
        var outputs = [Output_Local_Usage]()

        if let address = transaction.recipientAddress {
            outputs.append(factory.output(withIndex: 0, address: address, value: transaction.recipientValue, publicKey: nil))
        }

        if let address = transaction.changeAddress {
            outputs.append(factory.output(withIndex: 0, address: address, value: transaction.changeValue, publicKey: nil))
        }

        if !transaction.pluginData.isEmpty {
            var data = Data([OpCode_Local_Usage.op_return])

            transaction.pluginData.forEach { key, value in
                data += Data([key]) + value
            }

            outputs.append(factory.nullDataOutput(data: data))
        }

        let sorted = outputSorterFactory.sorter(for: sortType).sort(outputs: outputs)
        sorted.enumerated().forEach { index, transactionOutput in
            transactionOutput.index = index
        }

        transaction.outputs = sorted
    }

}
