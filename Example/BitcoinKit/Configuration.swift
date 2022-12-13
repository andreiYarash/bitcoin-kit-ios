import BitcoinCore
import OntToolKit

class Configuration {
    static let shared = Configuration()

    let minLogLevel: Logger.Level = .verbose
    let testNet = false
    let defaultWords = [
//        "current force clump paper shrug extra zebra employ prefer upon mobile hire",
        "popular game latin harvest silly excess much valid elegant illness edge silk",
    ]

}
