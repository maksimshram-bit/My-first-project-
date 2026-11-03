import Foundation

struct ConversionHistoryItem {
    let sourceAmount: String
    let sourceCurrency: String
    let targetAmount: String
    let targetCurrency: String
    
    var description: String {
        "\(sourceAmount) \(sourceCurrency) -> \(targetAmount) \(targetCurrency)"
    }
}
