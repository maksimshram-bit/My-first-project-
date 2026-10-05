import Foundation

enum RateMapper {
    
    static func toTableItem(_ rate: LiveRate, isFavorite: Bool) -> ExchangeTableItem {
        ExchangeTableItem(
            id: rate.code,
            name: rate.name,
            price: rate.ratePerUnit,
            change24h: rate.changePercent,
            section: section(for: rate.code),
            iconName: icon(for: rate.code),
            isFavorite: isFavorite,
            rate: nil
        )
    }
    
    static func section(for code: String) -> ExchangeSection {
        switch code {
        case "XAU", "XAG": return .metals
        case "BTC", "ETH": return .crypto
        default:           return .currencies
        }
    }
    
    static func icon(for code: String) -> String {
        switch code {
        case "USD": return "dollarsign.circle.fill"
        case "EUR": return "eurosign.circle.fill"
        case "RUB": return "rublesign.circle.fill"
        case "CNY": return "yensign.circle.fill"       
        case "GBP": return "sterlingsign.circle.fill"
        case "JPY": return "yensign.circle.fill"
        case "PLN": return "zlotysign.circle.fill"
        case "UAH": return "hryvniasign.circle.fill"
        case "XAU": return "circle.hexagongrid.fill"
        case "XAG": return "circle.hexagongrid.fill"
        case "BTC": return "bitcoinsign.circle.fill"
        case "ETH": return "diamond.circle.fill"
        default:    return "banknote.fill"
        }
    }
    
    static func flag(for code: String) -> String {
        switch code {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "RUB": return "🇷🇺"
        case "CNY": return "🇨🇳"
        case "GBP": return "🇬🇧"
        case "JPY": return "🇯🇵"
        case "PLN": return "🇵🇱"
        case "UAH": return "🇺🇦"
        case "XAU": return "🥇"
        case "XAG": return "🥈"
        default:    return "🏳️"
        }
    }
    
    static func toCurrencyRate(_ live: LiveRate) -> CurrencyRate {
        let valueStr = String(format: "%.2f BYN", live.ratePerUnit)
        return CurrencyRate(
            id: abs(live.code.hashValue),
            flagAndCode: "\(live.flag) \(live.code)",
            value: valueStr
        )
    }
}
