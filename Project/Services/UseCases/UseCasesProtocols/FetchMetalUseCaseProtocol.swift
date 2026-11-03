import Foundation

protocol FetchMetalsUseCaseProtocol {
    func execute(
        completion: @escaping (Result<[MetalRate], Error>) -> Void
    )
}
