import Foundation

public class BitcoinCoreBuilder_Local_Usage {
    public enum BuildError: Error { case peerSizeLessThanRequired, noSeedData, noWalletId, noNetwork, noPaymentAddressParser, noAddressSelector, noStorage, noInitialSyncApi }

    // chains
    public let addressConverter = AddressConverterChain_Local_Usage()

    // required parameters

    private var pubKey: Data?
    private var bip: Bip_Local_Usage = .bip44
    private var network: INetwork_Local_Usage?
    private var paymentAddressParser: IPaymentAddressParser_Local_Usage?
    private var plugins = [IPlugin_Local_Usage]()

    public func set(pubKey: Data) -> BitcoinCoreBuilder_Local_Usage {
        self.pubKey = pubKey
        return self
    }
    
    public func set(bip: Bip_Local_Usage) -> BitcoinCoreBuilder_Local_Usage {
        self.bip = bip
        return self
    }

    public func set(network: INetwork_Local_Usage) -> BitcoinCoreBuilder_Local_Usage {
        self.network = network
        return self
    }

    public func set(paymentAddressParser: PaymentAddressParser_Local_Usage) -> BitcoinCoreBuilder_Local_Usage {
        self.paymentAddressParser = paymentAddressParser
        return self
    }

    public func add(plugin: IPlugin_Local_Usage) -> BitcoinCoreBuilder_Local_Usage {
        plugins.append(plugin)
        return self
    }

    public func build() throws -> BCBitcoinCore {
        let pubKey = self.pubKey ?? Data()
        
        guard let network = self.network else {
            throw BuildError.noNetwork
        }
        guard let paymentAddressParser = self.paymentAddressParser else {
            throw BuildError.noPaymentAddressParser
        }

        let scriptConverter = ScriptConverter_Local_Usage()
        let restoreKeyConverterChain = RestoreKeyConverterChain_Local_Usage()
        let pluginManager = PluginManager_Local_Usage(scriptConverter: scriptConverter)

        plugins.forEach { pluginManager.add(plugin: $0) }
        restoreKeyConverterChain.add(converter: pluginManager)

        let unspentOutputProvider = SimpleUnspentOutputProvider(pluginManager: pluginManager)
        let factory = Factory_Local_Usage()

        let publicKeyManager = SimplePublicKeyManager(compressedPublicKey: pubKey, restoreKeyConverter: restoreKeyConverterChain)
    
        let unspentOutputSelector = UnspentOutputSelectorChain_Local_Usage()

        let transactionDataSorterFactory = TransactionDataSorterFactory_Local_Usage()

        let inputSigner = InputSigner_Local_Usage(network: network)
        let transactionSizeCalculator = TransactionSizeCalculator_Local_Usage()
        let dustCalculator = DustCalculator_Local_Usage(dustRelayTxFee: network.dustRelayTxFee, sizeCalculator: transactionSizeCalculator)
        let recipientSetter = RecipientSetter_Local_Usage(addressConverter: addressConverter, pluginManager: pluginManager)
        let outputSetter = OutputSetter_Local_Usage(outputSorterFactory: transactionDataSorterFactory, factory: factory)
        let inputSetter = InputSetter_Local_Usage(unspentOutputSelector: unspentOutputSelector, transactionSizeCalculator: transactionSizeCalculator, addressConverter: addressConverter, publicKeyManager: publicKeyManager, factory: factory, pluginManager: pluginManager, dustCalculator: dustCalculator, changeScriptType: bip.scriptType, inputSorterFactory: transactionDataSorterFactory)
        let transactionSigner = TransactionSigner_Local_Usage(inputSigner: inputSigner)
        let transactionBuilder = TransactionBuilder_Local_Usage(recipientSetter: recipientSetter, inputSetter: inputSetter, outputSetter: outputSetter, signer: transactionSigner)
        let transactionFeeCalculator = TransactionFeeCalculator_Local_Usage(recipientSetter: recipientSetter, inputSetter: inputSetter, addressConverter: addressConverter, publicKeyManager: publicKeyManager, changeScriptType: bip.scriptType)

        let transactionCreator = TransactionCreator_Local_Usage(transactionBuilder: transactionBuilder)

        let bitcoinCore = BCBitcoinCore(
                publicKeyManager: publicKeyManager,
                addressConverter: addressConverter,
                restoreKeyConverterChain: restoreKeyConverterChain,
                unspentOutputSelector: unspentOutputSelector,
                transactionCreator: transactionCreator,
                transactionFeeCalculator: transactionFeeCalculator,
                dustCalculator: dustCalculator,
                paymentAddressParser: paymentAddressParser,
                pluginManager: pluginManager,
                bip: bip,
                unspentOutputsSetter: unspentOutputProvider,
                transactionSizeCalculator: transactionSizeCalculator)



        bitcoinCore.prepend(addressConverter: Base58AddressConverter_Local_Usage(addressVersion: network.pubKeyHash, addressScriptVersion: network.scriptHash))
        bitcoinCore.prepend(unspentOutputSelector: UnspentOutputSelector_Local_Usage(calculator: transactionSizeCalculator, provider: unspentOutputProvider, dustCalculator: dustCalculator))
        bitcoinCore.prepend(unspentOutputSelector: UnspentOutputSelectorSingleNoChange_Local_Usage(calculator: transactionSizeCalculator, provider: unspentOutputProvider, dustCalculator: dustCalculator))

        return bitcoinCore
    }
}
