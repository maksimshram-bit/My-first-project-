import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showLoading()
    }
    
    private func showLoading() {
        let loadingVC = LoadingViewController()
        window.rootViewController = loadingVC
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showMain()
        }
    }
    
    private func showMain() {
        let tabBarCoordinator = MainTabBarCoordinator(window: window)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}

