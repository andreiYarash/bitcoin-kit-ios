import Foundation

class TransactionFeeCalculator_Local_Usage {

    private let recipientSetter: IRecipientSetter_Local_Usage
    private let inputSetter: IInputSetter_Local_Usage
    private let addressConverter: IAddressConverter_Local_Usage
    private let publicKeyManager: IPublicKeyManager_Local_Usage
    private let changeScriptType: ScriptType_Local_Usage

    init(recipientSetter: IRecipientSetter_Local_Usage, inputSetter: IInputSetter_Local_Usage, addressConverter: IAddressConverter_Local_Usage, publicKeyManager: IPublicKeyManager_Local_Usage, changeScriptType: ScriptType_Local_Usage) {
        self.recipientSetter = recipientSetter
        self.inputSetter = inputSetter
        self.addressConverter = addressConverter
        self.publicKeyManager = publicKeyManager
        self.changeScriptType = changeScriptType
    }

    private func sampleAddress() throws -> String {
        try addressConverter.convert(publicKey: try publicKeyManager.changePublicKey(), type: changeScriptType).stringValue
    }
}

extension TransactionFeeCalculator_Local_Usage: ITransactionFeeCalculator_Local_Usage {

    func fee(for value: Int, feeRate: Int, senderPay: Bool, toAddress: String?, changeScript: Data?, sequence: Int, pluginData: [UInt8: IPluginData_Local_Usage] = [:]) throws -> Int {
        let mutableTransaction = MutableTransaction_Local_Usage()

        try recipientSetter.setRecipient(to: mutableTransaction, toAddress: toAddress ?? (try sampleAddress()), value: value, pluginData: pluginData, skipChecks: true)
        try inputSetter.setInputs(to: mutableTransaction, feeRate: feeRate, senderPay: senderPay, sortType: .none, changeScript: changeScript, sequence: sequence, feeCalculation: true)

        let inputsTotalValue = mutableTransaction.inputsToSign.reduce(0) { total, input in total + input.previousOutput.value }
        let outputsTotalValue = mutableTransaction.recipientValue + mutableTransaction.changeValue

        return abs(inputsTotalValue - outputsTotalValue)
    }

}
