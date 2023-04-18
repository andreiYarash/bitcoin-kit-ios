public class MutableTransaction_Local_Usage {
    var transaction = Transaction_Local_Usage(version: 1, lockTime: 0)
    var inputsToSign = [InputToSign_Local_Usage]()
    var outputs = [Output_Local_Usage]()

    public var recipientAddress: Address_Local_Usage!
    public var recipientValue = 0
    var changeAddress: Address_Local_Usage? = nil
    var changeValue = 0

    private(set) var pluginData = [UInt8: Data]()

    var pluginDataOutputSize: Int {
        pluginData.count > 0 ? 1 + pluginData.reduce(into: 0) { $0 += 1 + $1.value.count } : 0                // OP_RETURN (PLUGIN_ID PLUGIN_DATA)
    }

    public init(outgoing: Bool = true) {
        transaction.status = .new
        transaction.isMine = true
        transaction.isOutgoing = outgoing
    }

    public func add(pluginData: Data, pluginId: UInt8) {
        self.pluginData[pluginId] = pluginData
    }

    func add(inputToSign: InputToSign_Local_Usage) {
        inputsToSign.append(inputToSign)
    }

    public func build() -> FullTransaction_Local_Usage {
        FullTransaction_Local_Usage(header: transaction, inputs: inputsToSign.map { $0.input }, outputs: outputs)
    }

}
