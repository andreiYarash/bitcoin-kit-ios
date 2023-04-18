class Bip69Sorter_Local_Usage: ITransactionDataSorter_Local_Usage {

    func sort(outputs: [Output_Local_Usage]) -> [Output_Local_Usage] {
        outputs.sorted(by: Bip69_Local_Usage.outputComparator)
    }

    func sort(unspentOutputs: [UnspentOutput_Local_Usage]) -> [UnspentOutput_Local_Usage] {
        unspentOutputs.sorted(by: Bip69_Local_Usage.inputComparator)
    }

}

class ShuffleSorter_Local_Usage: ITransactionDataSorter_Local_Usage {

    func sort(outputs: [Output_Local_Usage]) -> [Output_Local_Usage] {
        outputs.shuffled()
    }

    func sort(unspentOutputs: [UnspentOutput_Local_Usage]) -> [UnspentOutput_Local_Usage] {
        unspentOutputs.shuffled()
    }

}

class StraightSorter_Local_Usage: ITransactionDataSorter_Local_Usage {

    func sort(outputs: [Output_Local_Usage]) -> [Output_Local_Usage] {
        outputs
    }

    func sort(unspentOutputs: [UnspentOutput_Local_Usage]) -> [UnspentOutput_Local_Usage] {
        unspentOutputs
    }

}
