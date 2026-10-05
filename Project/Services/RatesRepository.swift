import Foundation

final class RatesRepository {
    
    static let shared = RatesRepository()
    private init() {}
    
    private let bankService = BankRatesAPIService()
    private let metalService = MetalAPIService()
    
    private(set) var latestRates: [LiveRate] = []
    
    private let englishNames: [String: String] = [
        "USD": "US Dollar",
        "EUR": "Euro",
        "RUB": "Russian Ruble",
        "CNY": "Chinese Yuan",
        "GBP": "British Pound",
        "JPY": "Japanese Yen",
        "PLN": "Polish Zloty",
        "UAH": "Ukrainian Hryvnia",
        "XAU": "Gold",
        "XAG": "Silver"
    ]
    
    func fetchAll(completion: @escaping (Result<[LiveRate], Error>) -> Void) {
        let group = DispatchGroup()
        var currencyRates: [LiveRate] = []
        var metalRates: [LiveRate] = []
        var capturedError: Error?
        
        group.enter()
        bankService.fetchRatesWithChanges { result in
            defer { group.leave() }
            switch result {
            case .success(let pairs):
                currencyRates = pairs.compactMap { pair -> LiveRate? in
                    let abbr = pair.current.abbreviation
                    guard ["USD", "EUR", "RUB", "CNY", "GBP"].contains(abbr) else { return nil }
                    
                    let value = pair.current.officialRate / Double(pair.current.scale)
                    return LiveRate(
                        code: abbr,
                        flag: RateMapper.flag(for: abbr),
                        name: self.englishNames[abbr] ?? pair.current.name,
                        ratePerUnit: value,
                        changePercent: pair.change
                    )
                }
            case .failure(let error):
                capturedError = error
            }
        }
        
        group.enter()
        metalService.fetchGold { goldResult in
            switch goldResult {
            case .success(let gold):
                metalRates.append(LiveRate(
                    code: gold.symbol,
                    flag: "🥇",
                    name: gold.name,
                    ratePerUnit: gold.price,
                    changePercent: 0
                ))
            case .failure(let error):
                capturedError = error
            }
            group.leave()
        }
        
        group.enter()
        metalService.fetchSilver { silverResult in
            switch silverResult {
            case .success(let silver):
                metalRates.append(LiveRate(
                    code: silver.symbol,
                    flag: "🥈",
                    name: silver.name,
                    ratePerUnit: silver.price,
                    changePercent: 0
                ))
            case .failure(let error):
                capturedError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            if currencyRates.isEmpty && metalRates.isEmpty, let error = capturedError {
                completion(.failure(error))
                return
            }
            
            let usdRate = currencyRates.first(where: { $0.code == "USD" })?.ratePerUnit ?? 3.0
            let metalsInBYN = metalRates.map { m -> LiveRate in
                LiveRate(
                    code: m.code,
                    flag: m.flag,
                    name: m.name,
                    ratePerUnit: m.ratePerUnit * usdRate,
                    changePercent: m.changePercent
                )
            }
            
            let all = currencyRates + metalsInBYN
            self?.latestRates = all
            completion(.success(all))
        }
    }
    
    func rate(for code: String) -> Double {
        if code == "BYN" { return 1.0 }
        return latestRates.first(where: { $0.code == code })?.ratePerUnit ?? 0
    }
    
    func convert(_ amount: Double, from: String, to: String) -> Double {
        let fromRate = rate(for: from)
        let toRate = rate(for: to)
        guard fromRate > 0, toRate > 0 else { return 0 }
        return amount * fromRate / toRate
    }
}

