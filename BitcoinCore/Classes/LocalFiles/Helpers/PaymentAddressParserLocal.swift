import Foundation

public class PaymentAddressParser_Local_Usage: IPaymentAddressParser_Local_Usage {
    fileprivate static let parameterVersion = "version"
    fileprivate static let parameterAmount = "amount"
    fileprivate static let parameterLabel = "label"
    fileprivate static let parameterMessage = "message"

    private let validScheme: String
    private let removeScheme: Bool

    public init(validScheme: String, removeScheme: Bool) {
        self.validScheme = validScheme
        self.removeScheme = removeScheme
    }

    func parse(paymentAddress: String) -> BitcoinPaymentData_Local_Usage {
        var parsedString = paymentAddress
        var address: String

        var version: String?
        var amount: Double?
        var label: String?
        var message: String?

        var parameters = [String: String]()
        var parametersParts = [String]()

        let schemeSeparatedParts = paymentAddress.components(separatedBy: ":")
        // check exist scheme. If scheme equal network scheme (Bitcoin or bitcoincash), remove scheme for bitcoin or leave for cash. Otherwise, leave wrong scheme to make throw in validator
        if schemeSeparatedParts.count >= 2 {
            if schemeSeparatedParts[0].lowercased() == validScheme {
                parsedString = removeScheme ? schemeSeparatedParts[1] : paymentAddress
            } else {
                parsedString = paymentAddress
            }
        }

        // check exist version
        var versionSeparatedParts = parsedString.components(separatedBy: CharacterSet(charactersIn: ";?"))
        guard versionSeparatedParts.count >= 2 else {
            address = parsedString

            return BitcoinPaymentData_Local_Usage(address: address)
        }
        address = versionSeparatedParts.removeFirst()
        if let firstPart = versionSeparatedParts.first?.lowercased(), firstPart.range(of: PaymentAddressParser_Local_Usage.parameterVersion) != nil {
            parametersParts.append(firstPart)

            versionSeparatedParts.removeFirst(1)
        }

        // parsing all parameters
        if let parameters = versionSeparatedParts.first?.components(separatedBy: CharacterSet(charactersIn: "&")) {
            parametersParts.append(contentsOf: parameters)
        }

        parametersParts.forEach { parameter in
            let parts = parameter.components(separatedBy: "=")
            if parts.count == 2 {
                switch parts[0] {
                case PaymentAddressParser_Local_Usage.parameterVersion: version = parts[1]
                case PaymentAddressParser_Local_Usage.parameterAmount: amount = Double(parts[1]) ?? nil
                case PaymentAddressParser_Local_Usage.parameterLabel: label = parts[1].removingPercentEncoding
                case PaymentAddressParser_Local_Usage.parameterMessage: message = parts[1].removingPercentEncoding
                default: parameters[parts[0]] = parts[1].removingPercentEncoding
                }
            }
        }

        return BitcoinPaymentData_Local_Usage(address: address, version: version, amount: amount, label: label, message: message, parameters: parameters.isEmpty ? nil : parameters)
    }

}
