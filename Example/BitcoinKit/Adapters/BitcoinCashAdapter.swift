import BitcoinCashKit
import BitcoinCore
import OntToolKit
import RxSwift


class BitcoinCashAdapter: BaseAdapter {
    let bitcoinCashKit: Kit

    init(words: [String], testMode: Bool, syncMode: BitcoinCore.SyncMode, logger: Logger) {
        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet(coinType: .type145)
        let seed = Mnemonic.seed(mnemonic: words)
        bitcoinCashKit = try! Kit(seed: seed, walletId: "walletId", syncMode: syncMode, networkType: networkType, logger: logger.scoped(with: "BitcoinCashKit"))

        super.init(name: "Bitcoin Cash", coinCode: "BCH", abstractKit: bitcoinCashKit)
        bitcoinCashKit.delegate = self
    }

    class func clear() {
        try? Kit.clear()
    }
}

extension BitcoinCashAdapter: BitcoinCoreDelegate {

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
