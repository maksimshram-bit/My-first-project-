import Foundation

final class FetchMetalsUseCase: FetchMetalsUseCaseProtocol {

    private let symbols: [String]
    private let metalService: MetalAPIServiceProtocol

    init(metalService: MetalAPIServiceProtocol,
         symbols: [String] = ["XAU", "XAG"]) {
        self.metalService = metalService
        self.symbols = symbols
    }

    func execute(completion: @escaping (Result<[MetalRate], Error>) -> Void) {
        let group = DispatchGroup()
        var results: [MetalRate] = []
        var capturedError: Error?

        for symbol in symbols {
            group.enter()
            metalService.fetchMetal(symbol: symbol) { result in
                switch result {
                case .success(let rate):
                    results.append(rate)
                case .failure(let error):
                    capturedError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if results.isEmpty, let error = capturedError {
                completion(.failure(error))
            } else {
                completion(.success(results))
            }
        }
    }
}
