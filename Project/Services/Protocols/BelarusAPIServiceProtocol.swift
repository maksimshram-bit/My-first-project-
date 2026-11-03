import Foundation

protocol BelarusbankAPIServiceProtocol {
    func fetchATMs(city: String?, completion: @escaping(Result<[MapPoint], Error>) -> Void)
}
