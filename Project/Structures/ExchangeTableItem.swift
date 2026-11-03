import Foundation

struct ExchangeTableItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let change24h: Double
    let section: ExchangeSection
    let iconName: String
    var isFavorite: Bool
    let rate: CurrencyRate?
    var changeText: String {
        String(format: "%@%.2f%%", change24h >= 0 ? "+" : "", change24h)
    }
    var isPositive: Bool { change24h >= 0 }
}
