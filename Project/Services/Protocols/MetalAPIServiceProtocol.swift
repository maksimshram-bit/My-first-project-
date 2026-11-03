import Foundation

protocol MetalAPIServiceProtocol {
    func fetchMetal(symbol: String,
                    completion: @escaping (Result<MetalRate, Error>) -> Void)
}
