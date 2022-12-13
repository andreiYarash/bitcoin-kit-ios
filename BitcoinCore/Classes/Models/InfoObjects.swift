import Foundation

open class BitTransactionInfo: ITransactionInfo, Codable {
    public let uid: String
    public let transactionHash: String
    public let transactionIndex: Int
    public let inputs: [BitTransactionInputInfo]
    public let outputs: [BitTransactionOutputInfo]
    public let amount: Int
    public let type: TransactionType
    public let fee: Int?
    public let blockHeight: Int?
    public let timestamp: Int
    public let status: TransactionStatus
    public let conflictingHash: String?

    public required init(uid: String, transactionHash: String, transactionIndex: Int, inputs: [BitTransactionInputInfo], outputs: [BitTransactionOutputInfo],
                         amount: Int, type: TransactionType, fee: Int?, blockHeight: Int?, timestamp: Int, status: TransactionStatus, conflictingHash: String?) {
        self.uid = uid
        self.transactionHash = transactionHash
        self.transactionIndex = transactionIndex
        self.inputs = inputs
        self.outputs = outputs
        self.amount = amount
        self.type = type
        self.fee = fee
        self.blockHeight = blockHeight
        self.timestamp = timestamp
        self.status = status
        self.conflictingHash = conflictingHash
    }

}

public class BitTransactionInputInfo: Codable {
    public let mine: Bool
    public let address: String?
    public let value: Int?

    public init(mine: Bool, address: String?, value: Int?) {
        self.mine = mine
        self.address = address
        self.value = value
    }

}

public class BitTransactionOutputInfo: Codable {
    public let mine: Bool
    public let changeOutput: Bool
    public let value: Int
    public let address: String?
    public var pluginId: UInt8? = nil
    public var pluginData: IPluginOutputData? = nil

    var pluginDataString: String? = nil

    private enum CodingKeys: String, CodingKey {
        case mine, changeOutput, value, address, pluginId, pluginDataString
    }

    public init(mine: Bool, changeOutput: Bool, value: Int, address: String?) {
        self.mine = mine
        self.changeOutput = changeOutput
        self.value = value
        self.address = address
    }

}

public struct BitBlockInfo {
    public let headerHash: String
    public let height: Int
    public let timestamp: Int?
}

public struct BitBalanceInfo : Equatable {
    public let spendable: Int
    public let unspendable: Int

    public static func ==(lhs: BitBalanceInfo, rhs: BitBalanceInfo) -> Bool {
        lhs.spendable == rhs.spendable && lhs.unspendable == rhs.unspendable
    }
}
