import Foundation

public struct SelectedUnspentOutputInfo_Local_Usage {
    public let unspentOutputs: [UnspentOutput_Local_Usage]
    public let recipientValue: Int              // amount to set to recipient output
    public let changeValue: Int?                // amount to set to change output. No change output if nil

    public init(unspentOutputs: [UnspentOutput_Local_Usage], recipientValue: Int, changeValue: Int?) {
        self.unspentOutputs = unspentOutputs
        self.recipientValue = recipientValue
        self.changeValue = changeValue
    }
}

public class UnspentOutputSelector_Local_Usage {

    private let calculator: ITransactionSizeCalculator_Local_Usage
    private let provider: IUnspentOutputProvider_Local_Usage
    private let dustCalculator: IDustCalculator_Local_Usage
    private let outputsLimit: Int?

    public init(calculator: ITransactionSizeCalculator_Local_Usage, provider: IUnspentOutputProvider_Local_Usage, dustCalculator: IDustCalculator_Local_Usage, outputsLimit: Int? = nil) {
        self.calculator = calculator
        self.provider = provider
        self.dustCalculator = dustCalculator
        self.outputsLimit = outputsLimit
    }

}

extension UnspentOutputSelector_Local_Usage: IUnspentOutputSelector_Local_Usage {

    public func select(value: Int, feeRate: Int, outputScriptType: ScriptType_Local_Usage = .p2pkh, changeType: ScriptType_Local_Usage = .p2pkh, senderPay: Bool, pluginDataOutputSize: Int, feeCalculation: Bool) throws -> SelectedUnspentOutputInfo_Local_Usage {
        let unspentOutputs = provider.spendableUtxo
        let recipientOutputDust = dustCalculator.dust(type: outputScriptType)
        let changeOutputDust = dustCalculator.dust(type: changeType)

        // check if value is not dust. recipientValue may be less, but not more
        if !feeCalculation {
            guard value >= recipientOutputDust else {
                throw BitcoinCoreErrors_Local_Usage.SendValueErrors.dust
            }
        }
        guard !unspentOutputs.isEmpty else {
            throw BitcoinCoreErrors_Local_Usage.SendValueErrors.emptyOutputs
        }

        let sortedOutputs = unspentOutputs.sorted(by: { lhs, rhs in lhs.output.value < rhs.output.value })

        // select unspentOutputs with least value until we get needed value
        var selectedOutputs = [UnspentOutput_Local_Usage]()
        var totalValue = 0
        var recipientValue = 0
        var sentValue = 0
        var fee = 0

        for unspentOutput in sortedOutputs {
            selectedOutputs.append(unspentOutput)
            totalValue += unspentOutput.output.value

            if let outputsLimit = outputsLimit {
                if (selectedOutputs.count > outputsLimit) {
                    guard let outputValueToExclude = selectedOutputs.first?.output.value else {
                        continue
                    }
                    selectedOutputs.remove(at: 0)
                    totalValue -= outputValueToExclude
                }
            }
            fee = calculator.transactionSize(previousOutputs: selectedOutputs.map { $0.output }, outputScriptTypes: [outputScriptType], pluginDataOutputSize: pluginDataOutputSize) * feeRate

            recipientValue = senderPay ? value : value - feeRate
            sentValue = senderPay ? value + feeRate : value

            if sentValue <= totalValue {      // totalValue is enough
                if recipientValue >= recipientOutputDust {   // receivedValue won't be dust
                    break
                } else {
                    // Here senderPay is false, because otherwise "dust" exception would throw far above.
                    // Adding more UTXOs will make fee even greater, making recipientValue even less and dust anyway
                    if !feeCalculation {
                        throw BitcoinCoreErrors_Local_Usage.SendValueErrors.dust
                    }
                }
            }
        }

        // if all unspentOutputs are selected and total value less than needed, then throw error
        if !feeCalculation && totalValue < sentValue {
            throw BitcoinCoreErrors_Local_Usage.SendValueErrors.notEnough
        }

        let changeOutputHavingTransactionFee = calculator.transactionSize(previousOutputs: selectedOutputs.map { $0.output }, outputScriptTypes: [outputScriptType, changeType], pluginDataOutputSize: pluginDataOutputSize) * feeRate
        let withChangeRecipientValue = senderPay ? value : value - changeOutputHavingTransactionFee
        let withChangeSentValue = senderPay ? value + changeOutputHavingTransactionFee : value
        // if selected UTXOs total value >= recipientValue(toOutput value) + fee(for transaction with change output) + dust(minimum changeOutput value)
        if totalValue >= withChangeRecipientValue + changeOutputHavingTransactionFee + changeOutputDust {
            // totalValue is too much, we must have change output
            if !feeCalculation {
                guard  withChangeRecipientValue >= recipientOutputDust else {
                    throw BitcoinCoreErrors_Local_Usage.SendValueErrors.dust
                }
            }
            return SelectedUnspentOutputInfo_Local_Usage(unspentOutputs: selectedOutputs, recipientValue: withChangeRecipientValue, changeValue: totalValue - withChangeSentValue)
        }

        // No change needed
        return SelectedUnspentOutputInfo_Local_Usage(unspentOutputs: selectedOutputs, recipientValue: recipientValue, changeValue: nil)
    }

}
