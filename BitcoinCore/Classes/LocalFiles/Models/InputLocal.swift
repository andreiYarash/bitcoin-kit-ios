import Foundation

public class Input_Local_Usage {

    public var previousOutputTxHash: Data
    var previousOutputIndex: Int
    public var signatureScript: Data
    var sequence: Int
    var transactionHash = Data()
    var keyHash: Data? = nil
    var address: String? = nil
    var witnessData = [Data]()

    init(withPreviousOutputTxHash previousOutputTxHash: Data, previousOutputIndex: Int, script: Data, sequence: Int) {
        self.previousOutputTxHash = previousOutputTxHash
        self.previousOutputIndex = previousOutputIndex
        self.signatureScript = script
        self.sequence = sequence
    }
}

enum SerializationError_Local_Usage: Error {
    case noPreviousOutput
    case noPreviousTransaction
    case noPreviousOutputScript
}
