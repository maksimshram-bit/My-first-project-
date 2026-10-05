import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = 0
        setupTabs()
    }
}

private extension MainTabBarController {
    func setupTabs() {
        let dashboardVC = Dashboard()
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        dashboardNav.tabBarItem = UITabBarItem(
            title: "Main screen",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        
        let mapVC = MapView()
        let mapNav = UINavigationController(rootViewController: mapVC)
        mapNav.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map.fill"),
            tag: 1
        )
        
        let ratesVC = ExchangeRates()
        let ratesNav = UINavigationController(rootViewController: ratesVC)
        ratesNav.tabBarItem = UITabBarItem(
            title: "Courses",
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 2
        )
        let converterVC = CurrencyConverter()
        let converterNav = UINavigationController(rootViewController: converterVC)
        converterNav.tabBarItem = UITabBarItem(
            title: "Converter",
            image: UIImage(systemName: "arrow.left.arrow.right.circle.fill"),
            tag: 3
        )
        
        let settingsVC = Settings()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Details",
            image: UIImage(systemName: "gearshape.fill"),
            tag: 4
        )
        
        viewControllers = [dashboardNav, mapNav, ratesNav, converterNav, settingsNav]
        
        AppTheme.applyTabBarGradient(to: tabBar)
    }
    
    func createNavController(root: UIViewController, title: String, image: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            tag: 0
        )
        return nav
    }
}

