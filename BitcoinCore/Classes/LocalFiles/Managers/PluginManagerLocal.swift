
class PluginManager_Local_Usage {
    enum PluginError: Error {
        case pluginNotFound
    }

    private let scriptConverter: IScriptConverter_Local_Usage
    private var plugins = [UInt8: IPlugin_Local_Usage]()

    init(scriptConverter: IScriptConverter_Local_Usage) {
        self.scriptConverter = scriptConverter
    }

}

extension PluginManager_Local_Usage: IPluginManager_Local_Usage {

    func validate(address: Address_Local_Usage, pluginData: [UInt8: IPluginData_Local_Usage]) throws {
        for (key, _) in pluginData {
            guard let plugin = plugins[key] else {
                throw PluginError.pluginNotFound
            }

            try plugin.validate(address: address)
        }
    }

    func maxSpendLimit(pluginData: [UInt8: IPluginData_Local_Usage]) throws -> Int? {
        try pluginData.compactMap({ key, data in
            guard let plugin = plugins[key] else {
                throw PluginError.pluginNotFound
            }

            return plugin.maxSpendLimit
        }).min()
    }

    func add(plugin: IPlugin_Local_Usage) {
        plugins[plugin.id] = plugin
    }

    func processOutputs(mutableTransaction: MutableTransaction_Local_Usage, pluginData: [UInt8: IPluginData_Local_Usage], skipChecks: Bool = false) throws {
        for (key, data) in pluginData {
            guard let plugin = plugins[key] else {
                throw PluginError.pluginNotFound
            }

            try plugin.processOutputs(mutableTransaction: mutableTransaction, pluginData: data, skipChecks: skipChecks)
        }
    }

    func processInputs(mutableTransaction: MutableTransaction_Local_Usage) throws {
        for inputToSign in mutableTransaction.inputsToSign {
            guard let pluginId = inputToSign.previousOutput.pluginId else {
                continue
            }

            guard let plugin = plugins[pluginId] else {
                throw PluginError.pluginNotFound
            }

            inputToSign.input.sequence = try plugin.inputSequenceNumber(output: inputToSign.previousOutput)
        }
    }

    func processTransactionWithNullData(transaction: FullTransaction_Local_Usage, nullDataOutput: Output_Local_Usage) throws {
        guard let script = try? scriptConverter.decode(data: nullDataOutput.lockingScript) else {
            return
        }

        var iterator = script.chunks.makeIterator()

        // the first byte OP_RETURN
        _ = iterator.next()

        do {
            while let pluginId = iterator.next() {
                guard let plugin = plugins[pluginId.opCode] else {
                    break
                }

                try plugin.processTransactionWithNullData(transaction: transaction, nullDataChunks: &iterator)
            }
        } catch {
            print(error)
        }
    }

    func isSpendable(unspentOutput: UnspentOutput_Local_Usage) -> Bool {
        guard let pluginId = unspentOutput.output.pluginId else {
            return true
        }

        guard let plugin = plugins[pluginId] else {
            return false
        }

        return (try? plugin.isSpendable(unspentOutput: unspentOutput)) ?? true
    }

    public func parsePluginData(fromPlugin pluginId: UInt8, pluginDataString: String, transactionTimestamp: Int) -> IPluginOutputData_Local_Usage? {
        guard let plugin = plugins[pluginId] else {
            return nil
        }

        return try? plugin.parsePluginData(from: pluginDataString, transactionTimestamp: transactionTimestamp)
    }

}

extension PluginManager_Local_Usage: IRestoreKeyConverter_Local_Usage {

    public func keysForApiRestore(publicKey: PublicKey_Local_Usage) -> [String] {
        (try? plugins.flatMap({ try $0.value.keysForApiRestore(publicKey: publicKey) })) ?? []
    }

    public func bloomFilterElements(publicKey: PublicKey_Local_Usage) -> [Data] {
        []
    }

}
