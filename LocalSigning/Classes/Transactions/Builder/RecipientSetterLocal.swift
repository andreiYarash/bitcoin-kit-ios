class RecipientSetter_Local_Usage {
    private let addressConverter: IAddressConverter_Local_Usage
    private let pluginManager: IPluginManager_Local_Usage

    init(addressConverter: IAddressConverter_Local_Usage, pluginManager: IPluginManager_Local_Usage) {
        self.addressConverter = addressConverter
        self.pluginManager = pluginManager
    }

}

extension RecipientSetter_Local_Usage: IRecipientSetter_Local_Usage {

    func setRecipient(to mutableTransaction: MutableTransaction_Local_Usage, toAddress: String, value: Int, pluginData: [UInt8: IPluginData_Local_Usage], skipChecks: Bool = false) throws {
        mutableTransaction.recipientAddress = try addressConverter.convert(address: toAddress)
        mutableTransaction.recipientValue = value

        try pluginManager.processOutputs(mutableTransaction: mutableTransaction, pluginData: pluginData, skipChecks: skipChecks)
    }

}
