import UIKit

protocol SettingsCoordinatorProtocol: AnyObject {}

final class SettingsCoordinator: Coordinator, SettingsCoordinatorProtocol {

    private weak var navigationController: UINavigationController?

    func start(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = Settings(coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func start() {}
}
