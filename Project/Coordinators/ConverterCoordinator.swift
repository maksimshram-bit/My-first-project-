import UIKit

protocol ConverterCoordinatorProtocol: AnyObject {}

final class ConverterCoordinator: Coordinator, ConverterCoordinatorProtocol {

    private let ratesRepository: RatesRepository
    private weak var navigationController: UINavigationController?

    init(ratesRepository: RatesRepository) {
        self.ratesRepository = ratesRepository
    }

    func start(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = CurrencyConverter(ratesRepository: ratesRepository)
        navigationController.setViewControllers([vc], animated: false)
    }

    func start() {}
}
