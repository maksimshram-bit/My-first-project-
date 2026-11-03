import Foundation

protocol BankRatesAPIServiceProtocol {
    func fetchRates(completion: @escaping (Result<[BankRate], Error>) -> Void)
    func fetchRates(date: Date,
                    completion: @escaping (Result<[BankRate], Error>) -> Void)
}
