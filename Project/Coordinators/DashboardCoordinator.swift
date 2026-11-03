import UIKit

protocol DashboardCoordinatorProtocol: AnyObject {
    func showAllRates()
    func showConverter()
    func showMap()
    func showChart(item: ExchangeTableItem, history: [Double], rate: CurrencyRate?)
}

final class DashboardCoordinator: Coordinator, DashboardCoordinatorProtocol, ExchangeRatesCoordinatorProtocol {

    private let ratesRepository: RatesRepository
    private weak var navigationController: UINavigationController?

    init(ratesRepository: RatesRepository) {
        self.ratesRepository = ratesRepository
    }

    func start(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = Dashboard(ratesRepository: ratesRepository, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func start() {}

    func showAllRates() {
        let vc = ExchangeRates(
            viewModel: ExchangeRatesModel(ratesRepository: ratesRepository),
            coordinator: self
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    func showConverter() {
        let vc = CurrencyConverter(ratesRepository: ratesRepository)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showMap() {
        navigationController?.tabBarController?.selectedIndex = 1
    }

    func showChart(item: ExchangeTableItem, history: [Double], rate: CurrencyRate?) {
        let vc = ScheduleController(item: item, history: history, rate: rate)
        navigationController?.pushViewController(vc, animated: true)
    }
}
