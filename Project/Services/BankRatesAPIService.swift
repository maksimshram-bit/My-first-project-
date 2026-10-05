import Foundation

final class BankRatesAPIService {
    
    private let url = URL(
        string: "https://api.nbrb.by/exrates/rates?periodicity=0"
    )!
    
    func fetchRates(completion: @escaping (Result<[BankRate], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  200..<300 ~= response.statusCode else {
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
                let rates = try JSONDecoder().decode(
                    [BankRate].self,
                    from: data
                )
                completion(.success(rates))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func fetchRates(
        date: Date,
        completion: @escaping (Result<[BankRate], Error>) -> Void
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = formatter.string(from: date)
        
        guard let url = URL(
            string: "https://api.nbrb.by/exrates/rates?ondate=\(dateString)&periodicity=0"
        ) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  200..<300 ~= response.statusCode else {
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
                let rates = try JSONDecoder().decode(
                    [BankRate].self,
                    from: data
                )
                completion(.success(rates))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func fetchRatesWithChanges(
        completion: @escaping (
            Result<[(current: BankRate, change: Double)], Error>
        ) -> Void
    ) {
        fetchRates { currentResult in
            
            switch currentResult {
            case .failure(let error):
                completion(.failure(error))
            case .success(let currentRates):
                guard let firstRate = currentRates.first else {
                    completion(
                        .failure(
                            URLError(.zeroByteResource)
                        )
                    )
                    return
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                
                guard let currentDate = formatter.date(
                    from: String(firstRate.date.prefix(10))
                ) else {
                    completion(
                        .failure(
                            URLError(.cannotParseResponse)
                        )
                    )
                    return
                }
                
                self.findPreviousAvailableRates(
                    before: currentDate,
                    currentRates: currentRates,
                    formatter: formatter
                ) { result in
                    
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let previousRates):
                        var result: [(current: BankRate, change: Double)] = []
                        
                        for currentRate in currentRates {
                            guard let previousRate = previousRates.first(
                                where: {
                                    $0.abbreviation == currentRate.abbreviation
                                }
                            ) else {
                                continue
                            }
                            
                            let currentValue =
                            currentRate.officialRate /
                            Double(currentRate.scale)
                            
                            let previousValue =
                            previousRate.officialRate /
                            Double(previousRate.scale)
                            
                            guard previousValue != 0 else {
                                continue
                            }
                            
                            let change =
                            ((currentValue - previousValue) /
                             previousValue) * 100
                            result.append((current: currentRate, change: change))
                        }
                        completion(.success(result))
                    }
                }
            }
        }
    }
    
    private func findPreviousAvailableRates(
        before currentDate: Date,
        currentRates: [BankRate],
        formatter: DateFormatter,
        completion: @escaping (
            Result<[BankRate], Error>
        ) -> Void
    ) {
        var searchDate = currentDate
        
        let calendar = Calendar.current
        
        func search() {
            guard let previousDate = calendar.date(
                byAdding: .day,
                value: -1,
                to: searchDate
            ) else {
                completion(
                    .failure(
                        URLError(.cannotParseResponse)
                    )
                )
                return
            }
            searchDate = previousDate
            
            self.fetchRates(date: previousDate) { result in
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let rates):
                    guard let firstRate = rates.first else {
                        search()
                        return
                    }
                    
                    let returnedDateString =
                    String(firstRate.date.prefix(10))
                    
                    guard let returnedDate = formatter.date(
                        from: returnedDateString
                    ) else {
                        search()
                        return
                    }
                    if returnedDate < currentDate {
                        completion(.success(rates))
                    } else {
                        search()
                    }
                }
            }
        }
        search()
    }
}

