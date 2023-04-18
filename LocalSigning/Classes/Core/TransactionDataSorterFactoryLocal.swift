import Foundation

class TransactionDataSorterFactory_Local_Usage: ITransactionDataSorterFactory_Local_Usage {

    func sorter(for type: TransactionDataSortType_Local_Usage) -> ITransactionDataSorter_Local_Usage {
        switch type {
        case .none: return StraightSorter_Local_Usage()
        case .shuffle: return ShuffleSorter_Local_Usage()
        case .bip69: return Bip69Sorter_Local_Usage()
        }
    }

}
