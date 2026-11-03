import Foundation

final class MetalAPIService: MetalAPIServiceProtocol {

    private let baseURL = "https://api.gold-api.com/price"

    func fetchMetal(symbol: String,
                    completion: @escaping (Result<MetalRate, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(symbol)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard let data else {
                completion(.failure(URLError(.zeroByteResource)))
                return
            }
            do {
                let result = try JSONDecoder().decode(MetalRate.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
