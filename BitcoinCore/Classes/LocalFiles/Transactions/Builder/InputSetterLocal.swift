public enum SequenceValues: Int {
    case `default` = 0x0
    case replacedByFeeMaxValue = 0xFFFFFFFD
    case disabledReplacedByFee = 0xFFFFFFFE
}

class InputSetter_Local_Usage {
    enum UnspentOutputError: Error {
        case feeMoreThanValue
        case notSupportedScriptType
    }

    private let unspentOutputSelector: IUnspentOutputSelector_Local_Usage
    private let transactionSizeCalculator: ITransactionSizeCalculator_Local_Usage
    private let addressConverter: IAddressConverter_Local_Usage
    private let publicKeyManager: IPublicKeyManager_Local_Usage
    private let factory: IFactory_Local_Usage
    private let pluginManager: IPluginManager_Local_Usage
    private let dustCalculator: IDustCalculator_Local_Usage
    private let changeScriptType: ScriptType_Local_Usage
    private let inputSorterFactory: ITransactionDataSorterFactory_Local_Usage

    init(unspentOutputSelector: IUnspentOutputSelector_Local_Usage, transactionSizeCalculator: ITransactionSizeCalculator_Local_Usage, addressConverter: IAddressConverter_Local_Usage, publicKeyManager: IPublicKeyManager_Local_Usage,
         factory: IFactory_Local_Usage, pluginManager: IPluginManager_Local_Usage, dustCalculator: IDustCalculator_Local_Usage, changeScriptType: ScriptType_Local_Usage, inputSorterFactory: ITransactionDataSorterFactory_Local_Usage) {
        self.unspentOutputSelector = unspentOutputSelector
        self.transactionSizeCalculator = transactionSizeCalculator
        self.addressConverter = addressConverter
        self.publicKeyManager = publicKeyManager
        self.factory = factory
        self.pluginManager = pluginManager
        self.dustCalculator = dustCalculator
        self.changeScriptType = changeScriptType
        self.inputSorterFactory = inputSorterFactory
    }

    private func input(fromUnspentOutput unspentOutput: UnspentOutput_Local_Usage, sequence: Int) throws -> InputToSign_Local_Usage {
//        if unspentOutput.output.scriptType == .p2wpkh {
            // todo: refactoring version byte!
            // witness key hashes stored with program byte and push code to determine
            // version (current only 0), but for sign we need only public kee hash
//            unspentOutput.output.keyHash?.removeFirst(2)
//        }

        // Maximum nSequence value (0xFFFFFFFF) disables nLockTime.
        // According to BIP-125, any value less than 0xFFFFFFFE makes a Replace-by-Fee(RBF) opted in.
//        let sequence = 0xFFFFFFFE
        return factory.inputToSign(withPreviousOutput: unspentOutput, script: Data(), sequence: sequence)
    }

}

extension InputSetter_Local_Usage: IInputSetter_Local_Usage {

    func setInputs(to mutableTransaction: MutableTransaction_Local_Usage, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, feeCalculation: Bool) throws {
        let value = mutableTransaction.recipientValue
        let unspentOutputInfo = try unspentOutputSelector.select(
                value: value, feeRate: feeRate,
                outputScriptType: mutableTransaction.recipientAddress.scriptType, changeType: changeScriptType,
                senderPay: senderPay, pluginDataOutputSize: mutableTransaction.pluginDataOutputSize,
            feeCalculation: feeCalculation
        )
        let unspentOutputs = inputSorterFactory.sorter(for: sortType).sort(unspentOutputs: unspentOutputInfo.unspentOutputs)

        for unspentOutput in unspentOutputs {
            mutableTransaction.add(inputToSign: try input(fromUnspentOutput: unspentOutput, sequence: sequence))
        }

        mutableTransaction.recipientValue = unspentOutputInfo.recipientValue

        // Add change output if needed
        if let changeValue = unspentOutputInfo.changeValue {
            if let changeScr = changeScript, case .p2wsh = changeScriptType {
                let converter = SegWitBech32AddressConverter_Local_Usage(prefix: BitcoinNetwork.mainnet.networkParams.bech32PrefixPattern, scriptConverter: ScriptConverter_Local_Usage())
                mutableTransaction.changeAddress = try converter.convert(scriptHash: changeScr)
            } else {
                let changePubKey = try publicKeyManager.changePublicKey()
                let changeAddress = try addressConverter.convert(publicKey: changePubKey, type: changeScriptType)

                mutableTransaction.changeAddress = changeAddress
            }
            mutableTransaction.changeValue = changeValue
            
        }

        try pluginManager.processInputs(mutableTransaction: mutableTransaction)
    }

    func setInputs(to mutableTransaction: MutableTransaction_Local_Usage, fromUnspentOutput unspentOutput: UnspentOutput_Local_Usage, feeRate: Int, sequence: Int) throws {
        guard unspentOutput.output.scriptType == .p2sh else {
            throw UnspentOutputError.notSupportedScriptType
        }

        // Calculate fee
        let transactionSize = transactionSizeCalculator.transactionSize(previousOutputs: [unspentOutput.output], outputScriptTypes: [mutableTransaction.recipientAddress.scriptType], pluginDataOutputSize: 0)
        let fee = transactionSize * feeRate
        guard fee < unspentOutput.output.value else {
            throw UnspentOutputError.feeMoreThanValue
        }

        // Add to mutable transaction
        mutableTransaction.add(inputToSign: try input(fromUnspentOutput: unspentOutput, sequence: sequence))
        mutableTransaction.recipientValue = unspentOutput.output.value - fee
    }

}
