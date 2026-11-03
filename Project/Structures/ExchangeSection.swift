import Foundation

enum ExchangeSection: Int, CaseIterable {
    case currencies = 0
    case crypto
    case metals
    
    var title: String {
        switch self {
        case .currencies: return "Currencies"
        case .crypto: return "Cryptocurrencies"
        case .metals: return "Precious metals"
        }
    }
}
