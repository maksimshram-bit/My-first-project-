import Foundation

protocol FetchRatesWithChangesUseCaseProtocol {
    func execute(
        completion: @escaping (Result<[(current: BankRate, change: Double)], Error>) -> Void
    )
}
