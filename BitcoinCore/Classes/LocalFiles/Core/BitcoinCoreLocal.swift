import Foundation

public class BCBitcoinCore {
    private let publicKeyManager: IPublicKeyManager_Local_Usage
    private let addressConverter: AddressConverterChain_Local_Usage
    private let restoreKeyConverterChain: RestoreKeyConverterChain_Local_Usage
    private let unspentOutputSelector: UnspentOutputSelectorChain_Local_Usage

    private let transactionCreator: ITransactionCreator_Local_Usage
    private let transactionFeeCalculator: ITransactionFeeCalculator_Local_Usage
    private let dustCalculator: IDustCalculator_Local_Usage
    private let paymentAddressParser: IPaymentAddressParser_Local_Usage

    private let pluginManager: IPluginManager_Local_Usage

    private let bip: Bip_Local_Usage


    private let unspentOutputsSetter: IUnspentOutputsSetter_Local_Usage
    private let transactionSizeCalculator: ITransactionSizeCalculator_Local_Usage
    // START: Extending

    public func add(restoreKeyConverter: IRestoreKeyConverter_Local_Usage) {
        restoreKeyConverterChain.add(converter: restoreKeyConverter)
    }


    public func add(plugin: IPlugin_Local_Usage) {
        pluginManager.add(plugin: plugin)
    }

    func publicKey(byPath path: String) throws -> PublicKey_Local_Usage {
        try publicKeyManager.publicKey(byPath: path)
    }

    public func prepend(addressConverter: IAddressConverter_Local_Usage) {
        self.addressConverter.prepend(addressConverter: addressConverter)
    }

    public func prepend(unspentOutputSelector: IUnspentOutputSelector_Local_Usage) {
        self.unspentOutputSelector.prepend(unspentOutputSelector: unspentOutputSelector)
    }

    // END: Extending

    public var delegateQueue = DispatchQueue(label: "io.horizontalsystems.bitcoin-core.bitcoin-core-delegate-queue")

    init( publicKeyManager: IPublicKeyManager_Local_Usage, addressConverter: AddressConverterChain_Local_Usage, restoreKeyConverterChain: RestoreKeyConverterChain_Local_Usage,
         unspentOutputSelector: UnspentOutputSelectorChain_Local_Usage,
         transactionCreator: ITransactionCreator_Local_Usage, transactionFeeCalculator: ITransactionFeeCalculator_Local_Usage, dustCalculator: IDustCalculator_Local_Usage,
         paymentAddressParser: IPaymentAddressParser_Local_Usage,
        pluginManager: IPluginManager_Local_Usage, bip: Bip_Local_Usage, unspentOutputsSetter: IUnspentOutputsSetter_Local_Usage, transactionSizeCalculator: ITransactionSizeCalculator_Local_Usage) {
      
        self.publicKeyManager = publicKeyManager
        self.addressConverter = addressConverter
        self.restoreKeyConverterChain = restoreKeyConverterChain
        self.unspentOutputSelector = unspentOutputSelector
        self.transactionCreator = transactionCreator
        self.transactionFeeCalculator = transactionFeeCalculator
        self.dustCalculator = dustCalculator
        self.paymentAddressParser = paymentAddressParser

       // self.syncManager = syncManager
        self.pluginManager = pluginManager
        self.bip = bip
        
        self.unspentOutputsSetter = unspentOutputsSetter
        self.transactionSizeCalculator = transactionSizeCalculator
    }

}

extension BCBitcoinCore {
    public func createRawTransaction(to address: String, value: Int, feeRate: Int, sortType: TransactionDataSortType_Local_Usage, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws -> Data {
        try transactionCreator.createRawTransaction(to: address, value: value, feeRate: feeRate, senderPay: true, sortType: sortType, signatures: signatures, changeScript: changeScript, sequence: sequence, pluginData: pluginData)
    }
    
    public func createRawHashesToSign(to address: String, value: Int, feeRate: Int, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws -> [Data] {
        try transactionCreator.createRawHashesToSign(to: address, value: value, feeRate: feeRate, senderPay: true, sortType: sortType, changeScript: changeScript, sequence: sequence, pluginData: pluginData)
    }

    public func validate(address: String, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws {
        try pluginManager.validate(address: try addressConverter.convert(address: address), pluginData: pluginData)
    }

    public func parse(paymentAddress: String) -> BitcoinPaymentData_Local_Usage {
        paymentAddressParser.parse(paymentAddress: paymentAddress)
    }

    public func fee(for value: Int, toAddress: String? = nil, feeRate: Int, senderPay: Bool, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws -> Int {
        try transactionFeeCalculator.fee(for: value, feeRate: feeRate, senderPay: senderPay, toAddress: toAddress, changeScript: changeScript, sequence: sequence, pluginData: pluginData)
    }
    
    public func setUnspents(_ unspents: [UnspentOutput_Local_Usage]) {
        unspentOutputsSetter.setSpendableUtxos(unspents)
    }
    
//    public func maxSpendableValue(toAddress: String? = nil, feeRate: Int, changeScript: Data?, pluginData: [UInt8: IPluginData] = [:]) throws -> Int {
//        let sendAllFee = try transactionFeeCalculator.fee(for: balance.spendable, feeRate: feeRate, senderPay: false, toAddress: toAddress, changeScript: changeScript, pluginData: pluginData)
//        return max(0, balance.spendable - sendAllFee)
//    }

    public func minSpendableValue(toAddress: String? = nil) -> Int {
        var scriptType = ScriptType_Local_Usage.p2pkh
        if let addressStr = toAddress, let address = try? addressConverter.convert(address: addressStr) {
            scriptType = address.scriptType
        }

        return dustCalculator.dust(type: scriptType)
    }

    public func maxSpendLimit(pluginData: [UInt8: IPluginData_Local_Usage]) throws -> Int? {
        try pluginManager.maxSpendLimit(pluginData: pluginData)
    }

    public func receiveAddress() -> String {
        guard let publicKey = try? publicKeyManager.receivePublicKey(),
              let address = try? addressConverter.convert(publicKey: publicKey, type: bip.scriptType) else {
            return ""
        }

        return address.stringValue
    }
    
    public func receiveAddress(for scriptType: ScriptType_Local_Usage) -> String {
        guard let publicKey = try? publicKeyManager.receivePublicKey(),
              let address = try? addressConverter.convert(publicKey: publicKey, type: scriptType) else {
            return ""
        }

        return address.stringValue
    }

    public func changePublicKey() throws -> PublicKey_Local_Usage {
        try publicKeyManager.changePublicKey()
    }

    public func receivePublicKey() throws -> PublicKey_Local_Usage {
        try publicKeyManager.receivePublicKey()
    }


}


extension BCBitcoinCore {
    public enum TransactionFilter {
        case p2shOutput(scriptHash: Data)
        case outpoint(transactionHash: Data, outputIndex: Int)
    }

}
