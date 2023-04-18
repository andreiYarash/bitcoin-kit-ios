
protocol IHDWallet_Local_Usage {
    var gapLimit: Int { get }
    func publicKey(account: Int, index: Int, external: Bool) throws -> PublicKey_Local_Usage
    func publicKeys(account: Int, indices: Range<UInt32>, external: Bool) throws -> [PublicKey_Local_Usage]
    func privateKeyData(account: Int, index: Int, external: Bool) throws -> Data
}

public protocol IRestoreKeyConverter_Local_Usage {
    func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String]
    func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data]
}

public protocol IPublicKeyManager_Local_Usage {
    func changePublicKey() throws -> PublicKey_Local_Usage
    func receivePublicKey() throws -> PublicKey_Local_Usage
    func fillGap() throws
    func addKeys(keys: [PublicKey_Local_Usage])
    func gapShifts() -> Bool
    func publicKey(byPath: String) throws -> PublicKey_Local_Usage
}


public protocol IHashe_Local_Usager {
    func hash(data: Data) -> Data
}

protocol IInitialSyncerDelegate_Local_Usage: class {
    func onSyncSuccess()
    func onSyncFailed(error: Error)
}

protocol IPaymentAddressParser_Local_Usage {
    func parse(paymentAddress: String) -> BitcoinPaymentData_Local_Usage
}

public protocol IAddressConverter_Local_Usage {
    func convert(address: String) throws -> Address_Local_Usage
    func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage
    func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage
}

public protocol IScriptConverter_Local_Usage {
    func decode(data: Data) throws -> Script_Local_Usage
}

protocol IScriptExtractor_Local_Usage: class {
    var type: ScriptType_Local_Usage { get }
    func extract(from data: Data, converter: IScriptConverter_Local_Usage) throws -> Data?
}

protocol ITransactionLinker_Local_Usage {
    func handle(transaction: FullTransaction_Local_Usage)
}

protocol ITransactionPublicKeySetter_Local_Usage {
    func set(output: Output_Local_Usage) -> Bool
}

public protocol ITransactionSyncer_Local_Usage: class {
    func newTransactions() -> [FullTransaction_Local_Usage]
    func handleRelayed(transactions: [FullTransaction_Local_Usage])
    func handleInvalid(fullTransaction: FullTransaction_Local_Usage)
    func shouldRequestTransaction(hash: Data) -> Bool
}

public protocol ITransactionCreator_Local_Usage {
    func createRawTransaction(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> Data
    func createRawHashesToSign(to address: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> [Data]
}

protocol ITransactionBuilder_Local_Usage {
    func buildTransaction(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, signatures: [Data], changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> FullTransaction_Local_Usage
    
    func buildTransactionToSign(toAddress: String, value: Int, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> [Data]
}

protocol ITransactionFeeCalculator_Local_Usage {
    func fee(for value: Int, feeRate: Int, senderPay: Bool, toAddress: String?, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage]) throws -> Int
}

protocol IInputSigner_Local_Usage {
    func sigScriptData(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign_Local_Usage], outputs: [Output_Local_Usage], index: Int, inputSignature: Data) throws -> [Data]
    func sigScriptHashToSign(transaction: Transaction_Local_Usage, inputsToSign: [InputToSign_Local_Usage], outputs: [Output_Local_Usage], index: Int) throws -> Data
}

public protocol ITransactionSizeCalculator_Local_Usage {
    func transactionSize(previousOutputs: [Output_Local_Usage], outputScriptTypes: [ScriptType_Local_Usage]) -> Int
    func transactionSize(previousOutputs: [Output_Local_Usage], outputScriptTypes: [ScriptType_Local_Usage], pluginDataOutputSize: Int) -> Int
    func outputSize(type: ScriptType_Local_Usage) -> Int
    func inputSize(type: ScriptType_Local_Usage) -> Int
    func witnessSize(type: ScriptType_Local_Usage) -> Int
    func toBytes(fee: Int) -> Int
}

public protocol IDustCalculator_Local_Usage {
    func dust(type: ScriptType_Local_Usage) -> Int
}

public protocol IUnspentOutputSelector_Local_Usage {
    func select(value: Int, feeRate: Int, outputScriptType: ScriptType_Local_Usage, changeType: ScriptType_Local_Usage, senderPay: Bool, pluginDataOutputSize: Int, feeCalculation: Bool) throws -> SelectedUnspentOutputInfo_Local_Usage
}

public protocol IUnspentOutputProvider_Local_Usage {
    var spendableUtxo: [UnspentOutput_Local_Usage] { get }
}

public protocol IUnspentOutputsSetter_Local_Usage {
    func setSpendableUtxos(_ utxos: [UnspentOutput_Local_Usage])
}


public protocol INetwork_Local_Usage: class {
    var pubKeyHash: UInt8 { get }
    var privateKey: UInt8 { get }
    var scriptHash: UInt8 { get }
    var bech32PrefixPattern: String { get }
    var xPubKey: UInt32 { get }
    var xPrivKey: UInt32 { get }
    var magic: UInt32 { get }
    var port: UInt32 { get }
    var dnsSeeds: [String] { get }
    var dustRelayTxFee: Int { get }
    var coinType: UInt32 { get }
    var sigHash: SigHashType_Local_Usage { get }
}

protocol IIrregularOutputFinder_Local_Usage {
    func hasIrregularOutput(outputs: [Output_Local_Usage]) -> Bool
}

public protocol IPlugin_Local_Usage {
    var id: UInt8 { get }
    var maxSpendLimit: Int? { get }
    func validate(address: Address_Local_Usage) throws
    func processOutputs(mutableTransaction: MutableTransaction_Local_Usage, pluginData: IPluginData_Local_Usage, skipChecks: Bool) throws
    func processTransactionWithNullData(transaction: FullTransaction_Local_Usage, nullDataChunks: inout IndexingIterator<[Chunk_Local_Usage]>) throws
    func isSpendable(unspentOutput: UnspentOutput_Local_Usage) throws -> Bool
    func inputSequenceNumber(output: Output_Local_Usage) throws -> Int
    func parsePluginData(from: String, transactionTimestamp: Int) throws -> IPluginOutputData_Local_Usage
    func keysForApiRestore(publicKey: PublicKey_Local_Usage) throws -> [String]
}

public protocol IPluginManager_Local_Usage {
    func validate(address: Address_Local_Usage, pluginData: [UInt8: IPluginData_Local_Usage]) throws
    func maxSpendLimit(pluginData: [UInt8: IPluginData_Local_Usage]) throws -> Int?
    func add(plugin: IPlugin_Local_Usage)
    func processOutputs(mutableTransaction: MutableTransaction_Local_Usage, pluginData: [UInt8: IPluginData_Local_Usage], skipChecks: Bool) throws
    func processInputs(mutableTransaction: MutableTransaction_Local_Usage) throws
    func processTransactionWithNullData(transaction: FullTransaction_Local_Usage, nullDataOutput: Output_Local_Usage) throws
    func isSpendable(unspentOutput: UnspentOutput_Local_Usage) -> Bool
    func parsePluginData(fromPlugin: UInt8, pluginDataString: String, transactionTimestamp: Int) -> IPluginOutputData_Local_Usage?
}

protocol IRecipientSetter_Local_Usage {
    func setRecipient(to mutableTransaction: MutableTransaction_Local_Usage, toAddress: String, value: Int, pluginData: [UInt8: IPluginData_Local_Usage], skipChecks: Bool) throws
}

protocol IOutputSetter_Local_Usage {
    func setOutputs(to mutableTransaction: MutableTransaction_Local_Usage, sortType: TransactionDataSortType_Local_Usage)
}

protocol IInputSetter_Local_Usage {
    func setInputs(to mutableTransaction: MutableTransaction_Local_Usage, feeRate: Int, senderPay: Bool, sortType: TransactionDataSortType_Local_Usage, changeScript: Data?, sequence: Int, feeCalculation: Bool) throws
    func setInputs(to mutableTransaction: MutableTransaction_Local_Usage, fromUnspentOutput unspentOutput: UnspentOutput_Local_Usage, feeRate: Int, sequence: Int) throws
}

protocol ITransactionSigner_Local_Usage {
    func sign(mutableTransaction: MutableTransaction_Local_Usage, signatures: [Data]) throws
    func hashesToSign(mutableTransaction: MutableTransaction_Local_Usage) throws -> [Data]
}

public protocol IPluginData_Local_Usage {
}

public protocol IPluginOutputData_Local_Usage {
}

public enum TransactionDataSortType_Local_Usage { case none, shuffle, bip69 }


protocol ITransactionDataSorterFactory_Local_Usage {
    func sorter(for type: TransactionDataSortType_Local_Usage) -> ITransactionDataSorter_Local_Usage
}

protocol ITransactionDataSorter_Local_Usage {
    func sort(outputs: [Output_Local_Usage]) -> [Output_Local_Usage]
    func sort(unspentOutputs: [UnspentOutput_Local_Usage]) -> [UnspentOutput_Local_Usage]
}

protocol IFactory_Local_Usage {
    func transaction(version: Int, lockTime: Int) -> Transaction_Local_Usage
    func inputToSign(withPreviousOutput: UnspentOutput_Local_Usage, script: Data, sequence: Int) -> InputToSign_Local_Usage
    func output(withIndex index: Int, address: Address_Local_Usage, value: Int, publicKey: PublicKey_Local_Usage?) -> Output_Local_Usage
    func nullDataOutput(data: Data) -> Output_Local_Usage
}
