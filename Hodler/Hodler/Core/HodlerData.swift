class HodlerData {
    let lockTimeInterval: HodlerPlugin.LockTimeInterval
    let addressString: String

    static func parse(serialized: String?) throws -> HodlerData {
        guard let serialized = serialized else {
            throw HodlerPluginError.invalidData
        }

        let parts = serialized.split(separator: "|")

        guard parts.count == 2 else {
            throw HodlerPluginError.invalidData
        }

        let lockTimeIntervalStr = String(parts[0])
        let addressString = String(parts[1])

        guard let int16 = UInt16(lockTimeIntervalStr), let lockTimeInterval = HodlerPlugin.LockTimeInterval(rawValue: int16) else {
            throw HodlerPluginError.invalidData
        }


        return HodlerData(lockTimeInterval: lockTimeInterval, addressString: addressString)
    }

    init(lockTimeInterval: HodlerPlugin.LockTimeInterval, addressString: String) {
        self.lockTimeInterval = lockTimeInterval
        self.addressString = addressString
    }

    func toString() -> String {
        "\(lockTimeInterval.rawValue)|\(addressString)"
    }

}