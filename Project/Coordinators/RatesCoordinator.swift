import UIKit

protocol ExchangeRatesCoordinatorProtocol: AnyObject {
    func showChart(item: ExchangeTableItem, history: [Double], rate: CurrencyRate?)
}

final class RatesCoordinator: Coordinator, ExchangeRatesCoordinatorProtocol {

    private let ratesRepository: RatesRepository
    private weak var navigationController: UINavigationController?

    init(ratesRepository: RatesRepository) {
        self.ratesRepository = ratesRepository
    }

    func start(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let viewModel = ExchangeRatesModel(ratesRepository: ratesRepository)
        let vc = ExchangeRates(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func start() {}

    func showChart(item: ExchangeTableItem, history: [Double], rate: CurrencyRate?) {
        let vc = ScheduleController(item: item, history: history, rate: rate)
        navigationController?.pushViewController(vc, animated: true)
    }
}
