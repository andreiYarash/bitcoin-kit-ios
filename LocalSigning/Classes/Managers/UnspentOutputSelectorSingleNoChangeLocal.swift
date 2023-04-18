import Foundation

public class UnspentOutputSelectorSingleNoChange_Local_Usage {

    private let calculator: ITransactionSizeCalculator_Local_Usage
    private let provider: IUnspentOutputProvider_Local_Usage
    private let dustCalculator: IDustCalculator_Local_Usage

    public init(calculator: ITransactionSizeCalculator_Local_Usage, provider: IUnspentOutputProvider_Local_Usage, dustCalculator: IDustCalculator_Local_Usage) {
        self.calculator = calculator
        self.provider = provider
        self.dustCalculator = dustCalculator
    }

}

extension UnspentOutputSelectorSingleNoChange_Local_Usage: IUnspentOutputSelector_Local_Usage {

    public func select(value: Int, feeRate: Int, outputScriptType: ScriptType_Local_Usage = .p2pkh, changeType: ScriptType_Local_Usage = .p2pkh, senderPay: Bool, pluginDataOutputSize: Int, feeCalculation: Bool) throws -> SelectedUnspentOutputInfo_Local_Usage {
        let unspentOutputs = provider.spendableUtxo
        let recipientOutputDust = dustCalculator.dust(type: outputScriptType)
        let changeOutputDust = dustCalculator.dust(type: changeType)

        if !feeCalculation {
            guard  value >= recipientOutputDust else {
                throw BitcoinCoreErrors_Local_Usage.SendValueErrors.dust
            }
        }
        
        guard !unspentOutputs.isEmpty else {
            throw BitcoinCoreErrors_Local_Usage.SendValueErrors.emptyOutputs
        }
        // try to find 1 unspent output with exactly matching value
        for unspentOutput in unspentOutputs {
            let output = unspentOutput.output
            let fee = calculator.transactionSize(previousOutputs: [output], outputScriptTypes: [outputScriptType], pluginDataOutputSize: pluginDataOutputSize) * feeRate

            let recipientValue = senderPay ? value : value - fee
            let sentValue = senderPay ? value + fee : value

            if (sentValue <= output.value) &&                                // output.value is enough
                       (recipientValue >= recipientOutputDust) &&            // receivedValue won't be dust
                       (output.value - sentValue < changeOutputDust) {       // no need to add change output
                return SelectedUnspentOutputInfo_Local_Usage(unspentOutputs: [unspentOutput], recipientValue: recipientValue, changeValue: nil)
            }
        }

        throw BitcoinCoreErrors_Local_Usage.SendValueErrors.singleNoChangeOutputNotFound
    }

}
