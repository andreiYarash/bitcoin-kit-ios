//
//  BitcoinCore.swift
//  BitcoinCore
//
//  Created by Alexander Osokin on 04.12.2020.
//

import Foundation

public class BitcoinManager {
    private let kit: BCBitcoinCore
    private let coinRate: Decimal = pow(10, 8)
	private let networkParams: INetwork_Local_Usage
    private let walletPublicKey: Data
    private let compressedWalletPublicKey: Data
	private var spendingScripts: [Script_Local_Usage] = []
    
    public init(networkParams: INetwork_Local_Usage, walletPublicKey: Data, compressedWalletPublicKey: Data, bip: Bip_Local_Usage = .bip84) {
        self.walletPublicKey = walletPublicKey
        self.compressedWalletPublicKey = compressedWalletPublicKey
		self.networkParams = networkParams
        let key = bip == .bip44 ? walletPublicKey : compressedWalletPublicKey
        let paymentAddressParser = PaymentAddressParser_Local_Usage(validScheme: "bitcoin", removeScheme: true)
        let scriptConverter = ScriptConverter_Local_Usage()
        let bech32AddressConverter = SegWitBech32AddressConverter_Local_Usage(prefix: networkParams.bech32PrefixPattern, scriptConverter: scriptConverter)
        let base58AddressConverter = Base58AddressConverter_Local_Usage(addressVersion: networkParams.pubKeyHash, addressScriptVersion: networkParams.scriptHash)
        
        let bitcoinCoreBuilder = BitcoinCoreBuilder_Local_Usage()
        
        let bitcoinCore = try! bitcoinCoreBuilder
            .set(network: networkParams)
            .set(pubKey: key)
            .set(bip: bip)
            .set(paymentAddressParser: paymentAddressParser)
            .build()
    
        bitcoinCore.prepend(addressConverter: bech32AddressConverter)
        
        //bitcoinCore.prepend(addressConverter: bech32CashAddr)
        
        switch bip {
        case .bip44:
            bitcoinCore.add(restoreKeyConverter: Bip44RestoreKeyConverter_Local_Usage(addressConverter: base58AddressConverter))
            bitcoinCore.add(restoreKeyConverter: Bip49RestoreKeyConverter_Local_Usage(addressConverter: base58AddressConverter))
            bitcoinCore.add(restoreKeyConverter: Bip84RestoreKeyConverter_Local_Usage(addressConverter: bech32AddressConverter))
        case .bip49:
            bitcoinCore.add(restoreKeyConverter: Bip49RestoreKeyConverter_Local_Usage(addressConverter: base58AddressConverter))
        case .bip84:
            bitcoinCore.add(restoreKeyConverter: Bip84RestoreKeyConverter_Local_Usage(addressConverter: bech32AddressConverter))
        case .bip141:
            bitcoinCore.add(restoreKeyConverter: Bip84RestoreKeyConverter_Local_Usage(addressConverter: bech32AddressConverter))
        }
        
        kit = bitcoinCore
    }
    
	public func fillBlockchainData(unspentOutputs: [UtxoDTO], spendingScripts: [Script_Local_Usage]) {
		self.spendingScripts = spendingScripts
		let scriptConverted = ScriptConverter_Local_Usage()
        let utxos: [UnspentOutput_Local_Usage] = unspentOutputs.map { unspent in
            let output = Output_Local_Usage(withValue: unspent.value, index: unspent.index, lockingScript: unspent.script, transactionHash: unspent.hash)
            TransactionOutputExtractor_Local_Usage.processOutput(output)
            let tx = Transaction_Local_Usage()
			
            let pubKey: PublicKey_Local_Usage
            switch output.scriptType {
            case .p2pkh:
                pubKey = PublicKey_Local_Usage(withAccount: 0, index: 0, external: true, hdPublicKeyData: walletPublicKey)
			case .p2wpkh:
				if let keyHash = output.keyHash {
					// TODO: Create script builder
					let script = OpCode_Local_Usage.push(Data([OpCode_Local_Usage.dup]) + Data([OpCode_Local_Usage.hash160]) + OpCode_Local_Usage.push(keyHash) + Data([OpCode_Local_Usage.equalVerify]) + Data([OpCode_Local_Usage.checkSig]))
					output.redeemScript = script
				}
                
				pubKey = PublicKey_Local_Usage(withAccount: 0, index: 0, external: true, hdPublicKeyData: compressedWalletPublicKey)
			case .p2wsh, .p2sh:
                var scriptForChange: Data?
				if let script = try? scriptConverted.decode(data: unspent.script),
				   let redeemScript = self.findSpendingScript(for: script) {
					output.redeemScript = redeemScript.scriptData
                    scriptForChange = redeemScript.scriptData
				}
				
				pubKey = PublicKey_Local_Usage(withAccount: 0, index: 0, external: true, hdPublicKeyData: scriptForChange ?? Data())
            default:
                fatalError("Unsupported output script")
            }
            return UnspentOutput_Local_Usage(output: output, publicKey: pubKey , transaction: tx)
        }
      
        kit.setUnspents(utxos)
    }
    
    public func buildForSign(target: String, amount: Decimal, feeRate: Int, sortType: TransactionDataSortType_Local_Usage = .bip69, changeScript: Data?, sequence: Int? = nil) throws -> [Data] {
        let amount = convertToSatoshi(value: amount)
        return try kit.createRawHashesToSign(to: target, value: amount, feeRate: feeRate, sortType: sortType, changeScript: changeScript, sequence: sequence ?? 0)
    }
    
    public func buildForSend(target: String, amount: Decimal, feeRate: Int, sortType: TransactionDataSortType_Local_Usage = .bip69, derSignatures: [Data], changeScript: Data?, sequence: Int? = nil) throws -> Data {
        let amount = convertToSatoshi(value: amount)
        return try kit.createRawTransaction(to: target, value: amount, feeRate: feeRate, sortType: sortType, signatures: derSignatures, changeScript: changeScript, sequence: sequence ?? 0)
    }
    
    public func fee(for value: Decimal, address: String?, feeRate: Int, senderPay: Bool, changeScript: Data?, sequence: Int? = nil) -> Decimal {
        let amount = convertToSatoshi(value: value)
        var fee: Int = 0
        do {
            fee = try kit.fee(for: amount, toAddress: address, feeRate: feeRate, senderPay: senderPay, changeScript: changeScript, sequence: sequence ?? 0)
        } catch {
//            fee = (try? kit.fee(for: amount, toAddress: address, feeRate: feeRate, senderPay: false, changeScript: changeScript, sequence: sequence)) ?? 0
            print(error)
        }
        
        return Decimal(fee) / coinRate
    }
    
    public func receiveAddress(for scriptType: ScriptType_Local_Usage) -> String {
        kit.receiveAddress(for: scriptType)
    }
    
    private func convertToSatoshi(value: Decimal) -> Int {
        let coinValue: Decimal = value * coinRate

        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return NSDecimalNumber(decimal: coinValue).rounding(accordingToBehavior: handler).intValue
    }
	
	private func findSpendingScript(for searchingScript: Script_Local_Usage) -> Script_Local_Usage? {
		guard
			searchingScript.chunks.count > 1,
			let searchingScriptHash = searchingScript.chunks[1].data
		else { return nil }
		switch searchingScriptHash.count {
		case 20:
            return spendingScripts.first(where: { $0.scriptData.sha256Ripemd160 == searchingScriptHash })
		case 32:
            return spendingScripts.first(where: { $0.scriptData.sha256() == searchingScriptHash })
		default:
			return nil
		}
	}
}


public class SimplePublicKeyManager: IPublicKeyManager_Local_Usage {
    private let pubKey: PublicKey_Local_Usage
    private let restoreKeyConverter: IRestoreKeyConverter_Local_Usage

    public init (compressedPublicKey: Data, restoreKeyConverter: IRestoreKeyConverter_Local_Usage) {
        pubKey = PublicKey_Local_Usage(withAccount: 0, index: 0, external: true, hdPublicKeyData: compressedPublicKey)
        self.restoreKeyConverter = restoreKeyConverter
    }
    
    public func changePublicKey() throws -> PublicKey_Local_Usage {
        return pubKey
    }
    
    public func receivePublicKey() throws -> PublicKey_Local_Usage {
        return pubKey
    }
    
    public func fillGap() throws {
        fatalError("unsupported")
    }
    
    public func addKeys(keys: [PublicKey_Local_Usage]) {
        fatalError("unsupported")
    }
    
    public func gapShifts() -> Bool {
        fatalError("unsupported")
    }
    
    public func publicKey(byPath: String) throws -> PublicKey_Local_Usage {
        return pubKey
    }
}


class SimpleUnspentOutputProvider {
    let pluginManager: IPluginManager_Local_Usage

    private var confirmedUtxo: [UnspentOutput_Local_Usage] = []
    
    private var unspendableUtxo: [UnspentOutput_Local_Usage] {
        confirmedUtxo.filter { !pluginManager.isSpendable(unspentOutput: $0) }
    }

    init(pluginManager: IPluginManager_Local_Usage) {
        self.pluginManager = pluginManager
    }
}

extension SimpleUnspentOutputProvider: IUnspentOutputProvider_Local_Usage {

    var spendableUtxo: [UnspentOutput_Local_Usage] {
        confirmedUtxo.filter { pluginManager.isSpendable(unspentOutput: $0) }
    }

}

extension SimpleUnspentOutputProvider: IUnspentOutputsSetter_Local_Usage {
    func setSpendableUtxos(_ utxos: [UnspentOutput_Local_Usage]) {
        confirmedUtxo = utxos
    }
}


public struct UtxoDTO {
    public let hash: Data
    public let index: Int
    public let value: Int
    public let script: Data
    
    public init(hash: Data, index: Int, value: Int, script: Data) {
        self.hash = hash
        self.index = index
        self.value = value
        self.script = script
    }
}

public enum BitcoinNetwork {
    case mainnet
    case testnet
    
    public var networkParams: INetwork_Local_Usage {
        switch self {
        case .mainnet:
            return MainNet()
        case .testnet:
            return TestNet()
        }
    }
}
