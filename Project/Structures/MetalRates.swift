import Foundation

struct MetalRate: Decodable {
    let currency: String
    let currencySymbol: String
    let exchangeRate: Double
    let name: String
    let price: Double
    let symbol: String
    let updatedAt: String
    let updatedAtReadable: String
}
