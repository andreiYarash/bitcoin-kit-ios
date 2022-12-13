import BitcoinKit
import BitcoinCore
import OntToolKit
import RxSwift

class BitcoinAdapter: BaseAdapter {
    let bitcoinKit: Kit

    init(words: [String], bip: Bip, testMode: Bool, syncMode: BitcoinCore.SyncMode, logger: Logger) {
        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet
        let seed = Mnemonic.seed(mnemonic: words)
        bitcoinKit = try! Kit(seed: seed, bip: bip, walletId: "walletId", syncMode: syncMode, networkType: networkType, confirmationsThreshold: 1, logger: logger.scoped(with: "BitcoinKit"))

        super.init(name: "Bitcoin", coinCode: "BTC", abstractKit: bitcoinKit)
        bitcoinKit.delegate = self
    }

    class func clear() {
        try? Kit.clear()
    }
}

extension BitcoinAdapter: BitcoinCoreDelegate {

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
