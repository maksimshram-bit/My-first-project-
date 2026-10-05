import Foundation

final class MetalAPIService {
    
    private let baseURL = "https://api.gold-api.com/price"
    
    func fetchGold(
        completion: @escaping (Result<MetalRate, Error>) -> Void
    ) {
        fetchMetal(
            symbol: "XAU",
            completion: completion
        )
    }
    
    func fetchSilver(
        completion: @escaping (Result<MetalRate, Error>) -> Void
    ) {
        fetchMetal(
            symbol: "XAG",
            completion: completion
        )
    }
    
    private func fetchMetal(
        symbol: String,
        completion: @escaping (Result<MetalRate, Error>) -> Void
    ) {
        
        guard let url = URL(
            string: "\(baseURL)/\(symbol)"
        ) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(
            with: request
        ) { data, response, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(
                    .failure(
                        URLError(.badServerResponse)
                    )
                )
                return
            }
            print(
                "Gold API \(symbol) status:",
                response.statusCode
            )
            
            guard 200..<300 ~= response.statusCode else {
                if let data,
                   let body = String(
                       data: data,
                       encoding: .utf8
                   ) {
                    print(
                        "Gold API \(symbol) error:",
                        body
                    )
                }
                completion(
                    .failure(
                        URLError(.badServerResponse)
                    )
                )
                return
            }
            
            guard let data else {
                completion(
                    .failure(
                        URLError(.zeroByteResource)
                    )
                )
                return
            }
            
            do {
                let result = try JSONDecoder().decode(
                    MetalRate.self,
                    from: data
                )
                completion(.success(result))
            } catch {
                print(
                    "Gold API \(symbol) decoding error:",
                    error
                )
                completion(.failure(error))
            }
        }
        .resume()
    }
}

