import UIKit

struct AppTheme {
    static let darkBlue = UIColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0)
    static let mediumBlue = UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
    
    static let tabBarColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
    static let textColor = UIColor.white
    static let accentColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
    
    static func applyGradientBackground(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            darkBlue.cgColor,
            mediumBlue.cgColor,
            mediumBlue.cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    static func applyTabBarGradient(to tabBar: UITabBar) {
        let gradient = CAGradientLayer()
        gradient.frame = tabBar.bounds
        gradient.colors = [
            darkBlue.cgColor,
            mediumBlue.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
    }
}

extension UIViewController {
    func applyGradientBackground() {
        AppTheme.applyGradientBackground(to: view)
    }
}
