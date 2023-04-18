class UnspentOutputSelectorChain_Local_Usage: IUnspentOutputSelector_Local_Usage {
    var concreteSelectors = [IUnspentOutputSelector_Local_Usage]()

    func select(value: Int, feeRate: Int, outputScriptType: ScriptType_Local_Usage, changeType: ScriptType_Local_Usage, senderPay: Bool, pluginDataOutputSize: Int, feeCalculation: Bool) throws -> SelectedUnspentOutputInfo_Local_Usage {
        var lastError: Error = BitcoinCoreErrors_Local_Usage.Unexpected.unkown

        for selector in concreteSelectors {
            do {
                return try selector.select(value: value, feeRate: feeRate, outputScriptType: outputScriptType, changeType: changeType, senderPay: senderPay, pluginDataOutputSize: pluginDataOutputSize, feeCalculation: feeCalculation)
            } catch {
                lastError = error
            }
        }

        throw lastError
    }

    func prepend(unspentOutputSelector: IUnspentOutputSelector_Local_Usage) {
        concreteSelectors.insert(unspentOutputSelector, at: 0)
    }

}
