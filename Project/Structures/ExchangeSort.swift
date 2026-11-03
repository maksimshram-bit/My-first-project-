import Foundation

enum ExchangeSort: Int, CaseIterable {
    case byName
    case byChange
    
    var title: String {
        switch self {
        case .byName: return "By name"
        case .byChange: return "By change"
        }
    }
}
