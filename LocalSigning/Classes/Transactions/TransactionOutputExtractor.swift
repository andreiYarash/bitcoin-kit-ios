class TransactionOutputExtractor_Local_Usage {
    let pluginManager: IPluginManager_Local_Usage

    init(pluginManager: IPluginManager_Local_Usage) {
        self.pluginManager = pluginManager
    }

}

extension TransactionOutputExtractor_Local_Usage {

    static func processOutput(_ output: Output_Local_Usage) {
        var payload: Data?
        var validScriptType: ScriptType_Local_Usage = .unknown

        let lockingScript = output.lockingScript
        let lockingScriptCount = lockingScript.count

        if lockingScriptCount == ScriptType_Local_Usage.p2pkh.size,                                         // P2PKH Output script 25 bytes: 76 A9 14 {20-byte-key-hash} 88 AC
           lockingScript[0] == OpCode_Local_Usage.dup,
           lockingScript[1] == OpCode_Local_Usage.hash160,
           lockingScript[2] == 20,
           lockingScript[23] == OpCode_Local_Usage.equalVerify,
           lockingScript[24] == OpCode_Local_Usage.checkSig {
            // parse P2PKH transaction output
            payload = lockingScript.subdata(in: 3..<23)
            validScriptType = .p2pkh
        } else if lockingScriptCount == ScriptType_Local_Usage.p2pk.size || lockingScriptCount == 67,       // P2PK Output script 35/67 bytes: {push-length-byte 33/65} {length-byte-public-key 33/65} AC
                  lockingScript[0] == 33 || lockingScript[0] == 65,
                  lockingScript[lockingScriptCount - 1] == OpCode_Local_Usage.checkSig {
            // parse P2PK transaction output
            payload = lockingScript.subdata(in: 1..<(lockingScriptCount - 1))
            validScriptType = .p2pk
        } else if lockingScriptCount == ScriptType_Local_Usage.p2sh.size,                                   // P2SH Output script 23 bytes: A9 14 {20-byte-script-hash} 87
                  lockingScript[0] == OpCode_Local_Usage.hash160,
                  lockingScript[1] == 20,
                  lockingScript[lockingScriptCount - 1] == OpCode_Local_Usage.equal {
            // parse P2SH transaction output
            payload = lockingScript.subdata(in: 2..<(lockingScriptCount - 1))
            validScriptType = .p2sh
        } else if lockingScriptCount == ScriptType_Local_Usage.p2wpkh.size,                                 // P2WPKH Output script 22 bytes: {version-byte 00/81-96} 14 {20-byte-key-hash}
                  lockingScript[0] == 0 || (lockingScript[0] > 0x50 && lockingScript[0] < 0x61), //push version byte 0 or 1-16
                  lockingScript[1] == 20 {
            // parse P2WPKH transaction output
            payload = lockingScript.subdata(in: 2..<lockingScriptCount)
            validScriptType = .p2wpkh
			
		} else if lockingScriptCount == ScriptType_Local_Usage.p2wsh.size,
				  lockingScript[0] == 0 || (lockingScript[0] > 0x50 && lockingScript[0] < 0x61),
				  lockingScript[1] == 32 {
			payload = lockingScript.subdata(in: 2..<lockingScriptCount)
			validScriptType = .p2wsh
		} else if lockingScriptCount > 0 && lockingScript[0] == OpCode_Local_Usage.op_return {              // nullData output
			payload = lockingScript.subdata(in: 0..<lockingScriptCount)
            validScriptType = .nullData
        }

        output.scriptType = validScriptType
        output.keyHash = payload
    }
}
