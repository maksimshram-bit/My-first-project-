import Foundation

final class BelarusbankAPIService: BelarusbankAPIServiceProtocol {

    func fetchATMs(city: String? = nil,
                   completion: @escaping (Result<[MapPoint], Error>) -> Void) {
        var urlString = "https://belarusbank.by/api/atm"
        if let city, !city.isEmpty {
            let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
            urlString += "?city=\(encoded)"
        }
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data else {
                DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
                return
            }
            do {
                let atms = try self.parseATMResponse(data: data)
                DispatchQueue.main.async { completion(.success(atms)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    private func parseATMResponse(data: Data) throws -> [MapPoint] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw NetworkError.invalidResponse
        }
        var points: [MapPoint] = []
        for atmData in json {
            let atmId = atmData["ATM_id"] as? String ?? UUID().uuidString
            let address = atmData["address"] as? String ?? ""
            let city = atmData["city"] as? String ?? ""
            let workTime = atmData["work_time"] as? String ?? "Круглосуточно"
            guard let latitude = parseCoordinate(atmData["gps_x"]),
                  let longitude = parseCoordinate(atmData["gps_y"]) else { continue }
            let point = MapPoint(
                id: atmId,
                name: "Банкомат Беларусбанк",
                address: "\(city), \(address)",
                latitude: latitude,
                longitude: longitude,
                type: .atm,
                schedule: workTime,
                queueStatus: "Нет данных"
            )
            points.append(point)
        }
        return points
    }

    private func parseCoordinate(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let s = value as? String { return Double(s) }
        return nil
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case parsingError
}
