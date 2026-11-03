import Foundation

struct CurrencyRates: Codable {
    let charCode: String
    let name: String
    let rate: Double
    let changePercent: Double?
    let date: Date
}
