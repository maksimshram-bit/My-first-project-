import Foundation

final class BankRatesAPIService: BankRatesAPIServiceProtocol {

    private let dateFormatter: DateFormatterServiceProtocol

    init(dateFormatter: DateFormatterServiceProtocol) {
        self.dateFormatter = dateFormatter
    }

    func fetchRates(completion: @escaping (Result<[BankRate], Error>) -> Void) {
        guard let url = URL(string: "https://api.nbrb.by/exrates/rates?periodicity=0") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        fetch(url: url, completion: completion)
    }

    func fetchRates(date: Date,
                    completion: @escaping (Result<[BankRate], Error>) -> Void) {
        let dateString = dateFormatter.apiString(from: date)
        guard let url = URL(string: "https://api.nbrb.by/exrates/rates?ondate=\(dateString)&periodicity=0") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        fetch(url: url, completion: completion)
    }

    private func fetch(url: URL,
                       completion: @escaping (Result<[BankRate], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                let rates = try JSONDecoder().decode([BankRate].self, from: data)
                completion(.success(rates))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
