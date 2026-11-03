import UIKit

enum MapPointType {
    case atm, branch
    
    var title: String {
        switch self {
        case .atm: return "ATM"
        case .branch: return "Branch"
        }
    }
    
    var color: UIColor {
        switch self {
        case .atm: return .systemRed
        case .branch: return .systemBlue
        }
    }
}
