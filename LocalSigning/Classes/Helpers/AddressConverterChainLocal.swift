public class AddressConverterChain_Local_Usage: IAddressConverter_Local_Usage {
    private var concreteConverters = [IAddressConverter_Local_Usage]()

    func prepend(addressConverter: IAddressConverter_Local_Usage) {
        concreteConverters.insert(addressConverter, at: 0)
    }

    public func convert(address: String) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(address: address)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors_Local_Usage.AddressConversionErrors(errors: errors)
    }

    public func convert(keyHash: Data, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(keyHash: keyHash, type: type)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors_Local_Usage.AddressConversionErrors(errors: errors)
    }

    public func convert(publicKey: PublicKey_Local_Usage, type: ScriptType_Local_Usage) throws -> Address_Local_Usage {
        var errors = [Error]()

        for converter in concreteConverters {
            do {
                let converted = try converter.convert(publicKey: publicKey, type: type)
                return converted
            } catch {
                errors.append(error)
            }
        }

        throw BitcoinCoreErrors_Local_Usage.AddressConversionErrors(errors: errors)
    }

}
