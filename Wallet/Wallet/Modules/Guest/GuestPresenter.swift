import Foundation

class GuestPresenter {

    private let interactor: IGuestInteractor
    private let router: IGuestRouter

    init(interactor: IGuestInteractor, router: IGuestRouter) {
        self.interactor = interactor
        self.router = router
    }

}

extension GuestPresenter: IGuestInteractorDelegate {

    func didCreateWallet() {
        router.navigateToBackupRoutingToMain()
    }

    func didFailToCreateWallet() {
        print("Login Error")
        // TODO: show error in GUI
    }

}

extension GuestPresenter: IGuestViewDelegate {

    func createWalletDidClick() {
        interactor.createWallet()
    }

    func restoreWalletDidClick() {
        router.navigateToRestore()
    }

}