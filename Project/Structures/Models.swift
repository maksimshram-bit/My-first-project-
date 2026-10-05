import Foundation
import UIKit
import MapKit

struct CurrencyRate: Hashable {
    let id: Int
    let flagAndCode: String
    let value: String
}

struct ExchangeRate: Hashable {
    let id: Int
}

struct MapPoint {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: MapPointType
    let schedule: String
    let queueStatus: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

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

struct CurrencyRates: Codable {
    let charCode: String
    let name: String
    let rate: Double
    let changePercent: Double?
    let date: Date
}

struct ConversionHistoryItem {
    let sourceAmount: String
    let sourceCurrency: String
    let targetAmount: String
    let targetCurrency: String
    
    var description: String {
        "\(sourceAmount) \(sourceCurrency) -> \(targetAmount) \(targetCurrency)"
    }
}

enum LocationType: String {
    case atm = "ATM"
    case branch = "Branch"
}

struct LocationDetail {
    let title: String
    let type: String
    let imageUrl: String?
    let address: String
    let workingHours: String
    let phone: String?
    let services: [String]
    let latitude: Double
    let longitude: Double
}
struct BankRate: Decodable {
    let id: Int
    let code: String
    let date: String
    let abbreviation: String
    let scale: Int
    let name: String
    let officialRate: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "Cur_ID"
        case code = "Cur_Code"
        case date = "Date"
        case abbreviation = "Cur_Abbreviation"
        case scale = "Cur_Scale"
        case name = "Cur_Name"
        case officialRate = "Cur_OfficialRate"
    }
}

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

struct LiveRate {
    let code: String
    let flag: String
    let name: String
    let ratePerUnit: Double
    let changePercent: Double
}





