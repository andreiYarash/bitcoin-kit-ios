import LitecoinKit
import BitcoinCore
import OpenSslKit
import OntToolKit
import RxSwift

class LitecoinAdapter: BaseAdapter {
    let litecoinKit: LitecoinKit.Kit

    init(words: [String], bip: Bip, testMode: Bool, syncMode: BitcoinCore.SyncMode, logger: Logger) {
        let networkType: LitecoinKit.Kit.NetworkType = testMode ? .testNet : .mainNet
        let seed = Mnemonic.seed(mnemonic: words)
        let hmac = OpenSslKit.Kit.hmacsha512(data: seed, key: "Bitcoin seed".data(using: .ascii)!)
        let privateKey = hmac[0..<32].bithex
        print(privateKey)
        litecoinKit = try! Kit(seed: seed, bip: bip, walletId: "walletId", syncMode: syncMode, networkType: networkType, confirmationsThreshold: 1, logger: logger.scoped(with: "LitecoinKit"))

        super.init(name: "Litecoin", coinCode: "LTC", abstractKit: litecoinKit)
        litecoinKit.delegate = self

    }

    init(privateKey: String, bip: Bip, testMode: Bool, syncMode: BitcoinCore.SyncMode, logger: Logger) {
        let networkType: LitecoinKit.Kit.NetworkType = testMode ? .testNet : .mainNet
        litecoinKit = try! Kit(privateKey: Data(bithex: privateKey), bip: bip, walletId: "walletId", syncMode: syncMode, networkType: networkType, confirmationsThreshold: 1, logger: logger.scoped(with: "LitecoinKit"))

        super.init(name: "Litecoin", coinCode: "LTC", abstractKit: litecoinKit)
        litecoinKit.delegate = self
    }

    class func clear() {
        try? Kit.clear()
    }
}

extension LitecoinAdapter: BitcoinCoreDelegate {

    func transactionsUpdated(inserted: [BitTransactionInfo], updated: [BitTransactionInfo]) {
        transactionsSignal.notify()
    }

    func transactionsDeleted(hashes: [String]) {
        transactionsSignal.notify()
    }

    func balanceUpdated(balance: BitBalanceInfo) {
        balanceSignal.notify()
    }

    func lastBlockInfoUpdated(lastBlockInfo: BitBlockInfo) {
        lastBlockSignal.notify()
    }

    public func kitStateUpdated(state: BitcoinCore.KitState) {
        syncStateSignal.notify()
    }

}
