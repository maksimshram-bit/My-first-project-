import UIKit

final class MainTabBarCoordinator: Coordinator {

    private let window: UIWindow
    private let tabBarController = UITabBarController()
    private var childCoordinators: [Coordinator] = []

    private let ratesRepository: RatesRepository
    private let belarusbankService: BelarusbankAPIServiceProtocol

    init(window: UIWindow) {
        self.window = window

        let dateFormatter = DateFormatterService()

        let bankService = BankRatesAPIService(dateFormatter: dateFormatter)
        let metalService = MetalAPIService()
        let belarusService = BelarusbankAPIService()

        let fetchRatesWithChanges = FetchRatesWithChangesUseCase(
            bankService: bankService,
            dateFormatter: dateFormatter
        )
        let fetchMetals = FetchMetalsUseCase(metalService: metalService)

        self.ratesRepository = RatesRepository(
            fetchRatesWithChangesUseCase: fetchRatesWithChanges,
            fetchMetalsUseCase: fetchMetals
        )
        self.belarusbankService = belarusService
    }

    func start() {
        setupTabs()

        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.window.rootViewController = self?.tabBarController
        })
    }

    private func setupTabs() {
        let dashboardNav = makeDashboardTab()
        let mapNav = makeMapTab()
        let ratesNav = makeRatesTab()
        let converterNav = makeConverterTab()
        let settingsNav = makeSettingsTab()

        tabBarController.viewControllers = [
            dashboardNav, mapNav, ratesNav, converterNav, settingsNav
        ]
        tabBarController.selectedIndex = 0

        AppTheme.applyTabBarGradient(to: tabBarController.tabBar)
    }

    private func makeDashboardTab() -> UINavigationController {
        let coordinator = DashboardCoordinator(ratesRepository: ratesRepository)
        childCoordinators.append(coordinator)
        let nav = UINavigationController()
        coordinator.start(in: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Main screen",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        return nav
    }

    private func makeMapTab() -> UINavigationController {
        let coordinator = MapCoordinator(belarusbankService: belarusbankService)
        childCoordinators.append(coordinator)
        let nav = UINavigationController()
        coordinator.start(in: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map.fill"),
            tag: 1
        )
        return nav
    }

    private func makeRatesTab() -> UINavigationController {
        let coordinator = RatesCoordinator(ratesRepository: ratesRepository)
        childCoordinators.append(coordinator)
        let nav = UINavigationController()
        coordinator.start(in: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Courses",
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 2
        )
        return nav
    }

    private func makeConverterTab() -> UINavigationController {
        let coordinator = ConverterCoordinator(ratesRepository: ratesRepository)
        childCoordinators.append(coordinator)
        let nav = UINavigationController()
        coordinator.start(in: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Converter",
            image: UIImage(systemName: "arrow.left.arrow.right.circle.fill"),
            tag: 3
        )
        return nav
    }

    private func makeSettingsTab() -> UINavigationController {
        let coordinator = SettingsCoordinator()
        childCoordinators.append(coordinator)
        let nav = UINavigationController()
        coordinator.start(in: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Details",
            image: UIImage(systemName: "gearshape.fill"),
            tag: 4
        )
        return nav
    }
}
