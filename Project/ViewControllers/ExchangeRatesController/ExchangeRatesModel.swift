import Foundation

final class ExchangeRatesModel {
    
    private var cryptos: [ExchangeTableItem] = [
        ExchangeTableItem(id: "BTC", name: "Bitcoin", price: 258694, change24h:  1.87, section: .crypto, iconName: "bitcoinsign.circle.fill", isFavorite: false, rate: nil),
        ExchangeTableItem(id: "ETH", name: "Ethereum", price: 8000,   change24h: -2.14, section: .crypto, iconName: "diamond.circle.fill", isFavorite: false, rate: nil),
    ]
    
    private(set) var searchText: String = ""
    private(set) var sort: ExchangeSort = .byName
    
    private var currencies: [ExchangeTableItem] = []
    private var metals: [ExchangeTableItem] = []
    
    private var allItems: [ExchangeTableItem] {
        currencies + cryptos + metals
    }
    
    func items(for section: ExchangeSection) -> [ExchangeTableItem] {
        var result = allItems.filter { $0.section == section }
        
        if !searchText.isEmpty {
            let text = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(text) || $0.id.lowercased().contains(text)
            }
        }
        
        switch sort {
        case .byName:
            result.sort { $0.name < $1.name }
        case .byChange:
            result.sort { $0.change24h > $1.change24h }
        }
        
        return result
    }
    
    func updateSearch(_ text: String) {
        searchText = text
    }
    
    func toggleFavorite(id: String) {
        if let idx = currencies.firstIndex(where: { $0.id == id }) {
            currencies[idx].isFavorite.toggle()
        } else if let idx = cryptos.firstIndex(where: { $0.id == id }) {
            cryptos[idx].isFavorite.toggle()
        } else if let idx = metals.firstIndex(where: { $0.id == id }) {
            metals[idx].isFavorite.toggle()
        }
    }
    
    func item(by id: String) -> ExchangeTableItem? {
        allItems.first { $0.id == id }
    }
    
    func loadLiveRates(completion: @escaping () -> Void) {
        RatesRepository.shared.fetchAll { [weak self] result in
            guard let self else { return }
            if case .success(let liveRates) = result {
                self.currencies = liveRates
                    .filter { $0.code != "XAU" && $0.code != "XAG" }
                    .map { RateMapper.toTableItem($0, isFavorite: false) }
                
                self.metals = liveRates
                    .filter { $0.code == "XAU" || $0.code == "XAG" }
                    .map { RateMapper.toTableItem($0, isFavorite: false) }
            }
            completion()
        }
    }
    
    func refresh(completion: @escaping () -> Void) {
        loadLiveRates { completion() }
    }
    
    func priceHistory(for id: String, points: Int = 30) -> [Double] {
        guard let item = item(by: id) else { return [] }
        var values: [Double] = []
        var current = item.price * 0.98
        for _ in 0..<points {
            current += Double.random(in: -item.price * 0.01...item.price * 0.01)
            values.append(current)
        }
        values.append(item.price)
        return values
    }
}
