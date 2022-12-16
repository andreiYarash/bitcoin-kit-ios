import BitcoinCore
import OntToolKit

class Configuration {
    static let shared = Configuration()

    let minLogLevel: Logger.Level = .verbose
    var testNet = true
    let defaultWords = [
//        "current force clump paper shrug extra zebra employ prefer upon mobile hire",
        "cry special tunnel clutch fade present logic snow need endless genre club",
    ]

}
