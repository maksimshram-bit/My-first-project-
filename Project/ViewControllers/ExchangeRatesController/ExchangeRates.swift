import UIKit
import SnapKit

class ExchangeRates: UIViewController {
    
    private let viewModel = ExchangeRatesModel()
    
    private lazy var allCoursesTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.layer.cornerRadius = 15
        table.layer.borderWidth = 1.5
        table.layer.borderColor = UIColor.blue.cgColor
        table.register(ExchangeTableCell.self, forCellReuseIdentifier: ExchangeTableCell.reuseIdentifier)
        table.backgroundColor = .clear
        table.refreshControl = refreshControl
        return table
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.searchBarStyle = .minimal
        search.returnKeyType = .search
        search.isUserInteractionEnabled = true
        return search
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshTapped), for: .valueChanged)
        return refresh
    }()
    
    private lazy var refreshButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [refreshButton]
        setupUIExchangeRates()
        applyGradientBackground()
        allCoursesTableView.delegate = self
        allCoursesTableView.dataSource = self
        allCoursesTableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        loadData()
        viewModel.loadLiveRates { [weak self] in
            self?.reloadData()
        }
    }
    
    private func loadData() {
            allCoursesTableView.reloadData()
        }
    }

private extension ExchangeRates {
    func setupUIExchangeRates() {
        view.addSubview(allCoursesTableView)
        view.addSubview(searchBar)
        
        allCoursesTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(7)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(55)
        }
        
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(56)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(5)
            make.height.equalTo(44)
        }
    }
}

private extension ExchangeRates {
    @objc func refreshTapped() {
        viewModel.refresh { [weak self] in
            self?.reloadData()
            self?.stopRefreshing()
        }
    }
    
    func reloadData() {
        allCoursesTableView.reloadData()
    }
    
    func stopRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showCharts(for item: ExchangeTableItem) {
        let history = viewModel.priceHistory(for: item.id)
        
        let vc = ScheduleController(item: item, history: history, rate: nil)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ExchangeRates: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        ExchangeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let exchangeSection = ExchangeSection(rawValue: section) else { return 0 }
        return viewModel.items(for: exchangeSection).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = ExchangeSection(rawValue: section) else { return nil }
        let count = viewModel.items(for: section).count
        return count == 0 ? nil : section.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableCell.reuseIdentifier, for: indexPath) as? ExchangeTableCell,
              let exchangeSection = ExchangeSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        let item = viewModel.items(for: exchangeSection)[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = ExchangeSection(rawValue: indexPath.section) else { return }
        let item = viewModel.items(for: section)[indexPath.row]
        showCharts(for: item)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.textColor = .white
        header.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        header.contentView.backgroundColor = .clear
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = .clear
    }
}

extension ExchangeRates: ExchangeTableCellDelegate {
    func didTapFavorite(in cell: ExchangeTableCell) {
        guard let indexPath = allCoursesTableView.indexPath(for: cell),
              let section = ExchangeSection(rawValue: indexPath.section) else { return }
        let item = viewModel.items(for: section)[indexPath.row]
        viewModel.toggleFavorite(id: item.id)
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        allCoursesTableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}

extension ExchangeRates: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearch(searchText)
        reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

