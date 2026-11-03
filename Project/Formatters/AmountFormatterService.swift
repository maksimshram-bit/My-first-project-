import Foundation

protocol AmountFormatterServiceProtocol {
    func priceString(_ value: Double) -> String
    func changeString(_ value: Double) -> String
}

final class AmountFormatterService: AmountFormatterServiceProtocol {

    func priceString(_ value: Double) -> String {
        String(format: "%.4f", value)
    }

    func changeString(_ value: Double) -> String {
        String(format: "%@%.2f%%", value >= 0 ? "+" : "", value)
    }
}
