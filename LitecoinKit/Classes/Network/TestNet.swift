import BitcoinCore

public class TestNet: INetwork {
    public let bundleName = "LitecoinKit"

    public let pubKeyHash: UInt8 = 0x6f
    public let privateKey: UInt8 = 0xef
    public let scriptHash: UInt8 = 0x3a
    public let bech32PrefixPattern: String = "tltc"
    public let xPubKey: UInt32 = 0x043587cf
    public let xPrivKey: UInt32 = 0x04358394
    public let magic: UInt32 = 0xfdd2c8f1
    public let port = 19335
    public let coinType: UInt32 = 1
    public let sigHash: SigHashType = .bitcoinAll
    public var syncableFromApi: Bool = false

    public let dnsSeeds = [
        "testnet-seed.ltc.xurious.com",
        "seed-b.litecoin.loshan.co.uk",
        "dnsseed-testnet.thrasher.io",
    ]

    public let dustRelayTxFee = 3000 // https://github.com/bitcoin/bitcoin/blob/c536dfbcb00fb15963bf5d507b7017c241718bf6/src/policy/policy.h#L50

    public init() {}
}
