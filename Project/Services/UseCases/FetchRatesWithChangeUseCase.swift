import Foundation

final class FetchRatesWithChangesUseCase: FetchRatesWithChangesUseCaseProtocol {

    private let bankService: BankRatesAPIServiceProtocol
    private let dateFormatter: DateFormatterServiceProtocol
    private let calendar: Calendar

    init(bankService: BankRatesAPIServiceProtocol,
         dateFormatter: DateFormatterServiceProtocol,
         calendar: Calendar = .current) {
        self.bankService = bankService
        self.dateFormatter = dateFormatter
        self.calendar = calendar
    }

    func execute(
        completion: @escaping (Result<[(current: BankRate, change: Double)], Error>) -> Void
    ) {
        bankService.fetchRates { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let currentRates):
                self.handleCurrentRates(currentRates, completion: completion)
            }
        }
    }

    private func handleCurrentRates(
        _ currentRates: [BankRate],
        completion: @escaping (Result<[(current: BankRate, change: Double)], Error>) -> Void
    ) {
        guard let firstRate = currentRates.first,
              let currentDate = dateFormatter.date(from: String(firstRate.date.prefix(10))) else {
            completion(.failure(URLError(.cannotParseResponse)))
            return
        }

        findPreviousRates(before: currentDate) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let previousRates):
                let pairs = self.makeChangePairs(current: currentRates, previous: previousRates)
                completion(.success(pairs))
            }
        }
    }

    private func makeChangePairs(
        current: [BankRate],
        previous: [BankRate]
    ) -> [(current: BankRate, change: Double)] {
        var result: [(current: BankRate, change: Double)] = []
        for currentRate in current {
            guard let previousRate = previous.first(where: {
                $0.abbreviation == currentRate.abbreviation
            }) else { continue }

            let currentValue = currentRate.officialRate / Double(currentRate.scale)
            let previousValue = previousRate.officialRate / Double(previousRate.scale)
            guard previousValue != 0 else { continue }

            let change = ((currentValue - previousValue) / previousValue) * 100
            result.append((current: currentRate, change: change))
        }
        return result
    }

    private func findPreviousRates(
        before currentDate: Date,
        completion: @escaping (Result<[BankRate], Error>) -> Void
    ) {
        searchPrevious(from: currentDate, completion: completion)
    }

    private func searchPrevious(
        from date: Date,
        completion: @escaping (Result<[BankRate], Error>) -> Void
    ) {
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else {
            completion(.failure(URLError(.cannotParseResponse)))
            return
        }

        bankService.fetchRates(date: previousDate) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let rates):
                self.evaluatePreviousRates(
                    rates,
                    fallbackDate: previousDate,
                    targetDate: date,
                    completion: completion
                )
            }
        }
    }

    private func evaluatePreviousRates(
        _ rates: [BankRate],
        fallbackDate: Date,
        targetDate: Date,
        completion: @escaping (Result<[BankRate], Error>) -> Void
    ) {
        guard let firstRate = rates.first,
              let returnedDate = dateFormatter.date(from: String(firstRate.date.prefix(10))) else {
            searchPrevious(from: fallbackDate, completion: completion)
            return
        }

        if returnedDate < targetDate {
            completion(.success(rates))
        } else {
            searchPrevious(from: fallbackDate, completion: completion)
        }
    }
}
