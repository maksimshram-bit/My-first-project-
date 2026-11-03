import Foundation

final class RatesRepository {

    private let fetchRatesWithChangesUseCase: FetchRatesWithChangesUseCaseProtocol
    private let fetchMetalsUseCase: FetchMetalsUseCaseProtocol

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

    init(fetchRatesWithChangesUseCase: FetchRatesWithChangesUseCaseProtocol,
         fetchMetalsUseCase: FetchMetalsUseCaseProtocol) {
        self.fetchRatesWithChangesUseCase = fetchRatesWithChangesUseCase
        self.fetchMetalsUseCase = fetchMetalsUseCase
    }

    func fetchAll(completion: @escaping (Result<[LiveRate], Error>) -> Void) {
        let group = DispatchGroup()
        var currencyRates: [LiveRate] = []
        var metalRates: [LiveRate] = []
        var capturedError: Error?

        group.enter()
        fetchRatesWithChangesUseCase.execute { [weak self] result in
            defer { group.leave() }
            guard let self else { return }
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
        fetchMetalsUseCase.execute { result in
            defer { group.leave() }
            switch result {
            case .success(let metals):
                metalRates = metals.compactMap { metal -> LiveRate? in
                    let flag = metal.symbol == "XAU" ? "🥇" : "🥈"
                    return LiveRate(
                        code: metal.symbol,
                        flag: flag,
                        name: metal.name,
                        ratePerUnit: metal.price,
                        changePercent: 0
                    )
                }
            case .failure(let error):
                capturedError = error
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if currencyRates.isEmpty && metalRates.isEmpty, let error = capturedError {
                completion(.failure(error))
                return
            }
            let usdRate = currencyRates.first(where: { $0.code == "USD" })?.ratePerUnit ?? 3.0
            let metalsInBYN = metalRates.map { m -> LiveRate in
                LiveRate(code: m.code, flag: m.flag, name: m.name,
                         ratePerUnit: m.ratePerUnit * usdRate,
                         changePercent: m.changePercent)
            }
            let all = currencyRates + metalsInBYN
            self.latestRates = all
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
