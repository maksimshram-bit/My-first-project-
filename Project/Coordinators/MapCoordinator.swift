import UIKit

protocol MapCoordinatorProtocol: AnyObject {}

final class MapCoordinator: Coordinator, MapCoordinatorProtocol {

    private let belarusbankService: BelarusbankAPIServiceProtocol
    private weak var navigationController: UINavigationController?

    init(belarusbankService: BelarusbankAPIServiceProtocol) {
        self.belarusbankService = belarusbankService
    }

    func start(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = MapView(
            belarusbankService: belarusbankService,
            coordinator: self
        )
        navigationController.setViewControllers([vc], animated: false)
    }

    func start() {}
}
