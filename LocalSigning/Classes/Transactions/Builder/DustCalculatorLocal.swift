public class DustCalculator_Local_Usage {

    private let minFeeRate: Int
    private let sizeCalculator: ITransactionSizeCalculator_Local_Usage

    public init(dustRelayTxFee: Int, sizeCalculator: ITransactionSizeCalculator_Local_Usage) {
        // https://github.com/bitcoin/bitcoin/blob/master/src/policy/feerate.cpp#L26
        minFeeRate = dustRelayTxFee / 1000

        self.sizeCalculator = sizeCalculator
    }

}

extension DustCalculator_Local_Usage: IDustCalculator_Local_Usage {

    public func dust(type: ScriptType_Local_Usage) -> Int {
        // https://github.com/bitcoin/bitcoin/blob/master/src/policy/policy.cpp#L14

        var size = sizeCalculator.outputSize(type: type)

        if type.nativeSegwit {
            size += sizeCalculator.inputSize(type: .p2wpkh) + sizeCalculator.witnessSize(type: .p2wpkh) / 4
        } else {
            size += sizeCalculator.inputSize(type: .p2pkh)
        }

        return size * minFeeRate
    }

}
