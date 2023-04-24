class RestoreKeyConverterChain_Local_Usage : IRestoreKeyConverter_Local_Usage {

    var converters = [IRestoreKeyConverter_Local_Usage]()

    func add(converter: IRestoreKeyConverter_Local_Usage) {
        converters.append(converter)
    }

    func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        var keys = [String]()
        for converter in converters {
            keys.append(contentsOf: converter.keysForApiRestore(publicKey: publicKey))
        }

        return keys.unique_Local_Usage
    }

    func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        var keys = [Data]()
        for converter in converters {
            keys.append(contentsOf: converter.bloomFilterElements(publicKey: publicKey))
        }

        return keys.unique_Local_Usage
    }

}

public class Bip44RestoreKeyConverter_Local_Usage {

    let addressConverter: IAddressConverter_Local_Usage

    public init(addressConverter: IAddressConverter_Local_Usage) {
        self.addressConverter = addressConverter
    }

}

extension Bip44RestoreKeyConverter_Local_Usage : IRestoreKeyConverter_Local_Usage {

    public func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        let legacyAddress = try? addressConverter.convert(publicKey: publicKey, type: .p2pkh).stringValue

        return [legacyAddress].compactMap { $0 }
    }

    public func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        [publicKey.keyHash, publicKey.raw]
    }

}

public class Bip49RestoreKeyConverter_Local_Usage {

    let addressConverter: IAddressConverter_Local_Usage

    public init(addressConverter: IAddressConverter_Local_Usage) {
        self.addressConverter = addressConverter
    }

}

extension Bip49RestoreKeyConverter_Local_Usage : IRestoreKeyConverter_Local_Usage {

    public func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        let wpkhShAddress = try? addressConverter.convert(publicKey: publicKey, type: .p2wpkhSh).stringValue

        return [wpkhShAddress].compactMap { $0 }
    }

    public func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        [publicKey.scriptHashForP2WPKH]
    }

}

public class Bip84RestoreKeyConverter_Local_Usage {

    let addressConverter: IAddressConverter_Local_Usage

    public init(addressConverter: IAddressConverter_Local_Usage) {
        self.addressConverter = addressConverter
    }

}

extension Bip84RestoreKeyConverter_Local_Usage : IRestoreKeyConverter_Local_Usage {

    public func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        let segwitAddress = try? addressConverter.convert(publicKey: publicKey, type: .p2wpkh).stringValue

        return [segwitAddress].compactMap { $0 }
    }

    public func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        [publicKey.keyHash]
    }

}

public class KeyHashRestoreKeyConverter_Local_Usage : IRestoreKeyConverter_Local_Usage {

    public init() {}

    public func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        [publicKey.keyHash.hex]
    }

    public func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        [publicKey.keyHash]
    }

}
