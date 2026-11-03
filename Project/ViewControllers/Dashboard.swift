import UIKit
import SnapKit
import CoreLocation

class Dashboard: UIViewController {
    
    private var currentRates: [CurrencyRate] = [] {
        didSet {
            updateRatesUI()
        }
    }
    
    private let locationManager = CLLocationManager()
    private var displayedRates: [ExchangeRate] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let ratesRepository: RatesRepository
    private weak var coordinator: DashboardCoordinatorProtocol?
    
    init(ratesRepository: RatesRepository, coordinator: DashboardCoordinatorProtocol) {
        self.ratesRepository = ratesRepository
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to your Bank"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()

    private lazy var notificationsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(notificationTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardTitleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 0.4
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.blue.cgColor
        return view
    }()
    
    private lazy var cardImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "App_logo")
        return imageView
    }()

    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Total balance: "
        label.textColor = .white
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private lazy var notificationDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()
    
    private lazy var totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.text = "0.00 BYN"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private lazy var exchangeRatesView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.blue.cgColor
        return view
    }()
    
    private lazy var exchangeRatesLabel: UILabel = {
        let label = UILabel()
        label.text = "Exchange rates"
        label.textColor = .white
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private lazy var exchangeRatesButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.setTitle("all", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(exchangeAllTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var exchangeRatesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 43
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var converterView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.blue.cgColor
        return view
    }()
    
    private lazy var converterTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Converter"
        label.textColor = .white
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private lazy var byTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0.00"
        textField.alpha = 0.8
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 30
        textField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var sellTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0.00"
        textField.alpha = 0.8
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 30
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    private lazy var oppositeSignButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(oppositeButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var choiceByCurrencyButton: UIButton = {
        let button = UIButton()
        button.setTitle("USD 🔽", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.addTarget(self, action: #selector(choiceByTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var choiceSellCurrencyButton: UIButton = {
        let button = UIButton()
        button.setTitle("BYN 🔽", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.addTarget(self, action: #selector(choiceSellTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageConventerTransition: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        button.addTarget(self, action: #selector(converterTransitionTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var atmFinderButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.addTarget(self, action: #selector(atmFinderTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUIDashboard()
        applyGradientBackground()
        loadLiveResult()
        updateLiveResult()
        setupLocation()
        notificationDot.isHidden = false
        
        choiceByCurrencyButton.setTitle("USD 🔽", for: .normal)
        choiceSellCurrencyButton.setTitle("BYN 🔽", for: .normal)
    }
}

private extension Dashboard {
    func setupUIDashboard() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        scrollView.alwaysBounceVertical = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(notificationsButton)
        notificationsButton.addSubview(notificationDot)
        contentView.addSubview(cardView)
        contentView.addSubview(exchangeRatesView)
        contentView.addSubview(converterView)
        
        cardView.addSubview(cardTitleView)
        cardTitleView.addSubview(cardImage)
        cardTitleView.addSubview(balanceLabel)
        cardTitleView.addSubview(totalBalanceLabel)
        
        exchangeRatesView.addSubview(exchangeRatesLabel)
        exchangeRatesView.addSubview(exchangeRatesButton)
        exchangeRatesView.addSubview(exchangeRatesStackView)
        
        converterView.addSubview(converterTitleLabel)
        converterView.addSubview(byTextField)
        converterView.addSubview(sellTextField)
        converterView.addSubview(oppositeSignButton)
        converterView.addSubview(choiceByCurrencyButton)
        converterView.addSubview(choiceSellCurrencyButton)
        converterView.addSubview(imageConventerTransition)
        converterView.addSubview(atmFinderButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        notificationsButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(28)
        }
        
        notificationDot.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.trailing.equalToSuperview().offset(2)
            make.size.equalTo(10)
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(220)
        }
        
        cardTitleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(40)
        }
        
        cardImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.width.equalTo(43)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33)
            make.leading.equalTo(cardImage.snp.trailing).offset(5)
        }
        
        totalBalanceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(15)
        }
        
        exchangeRatesView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(220)
        }
        
        exchangeRatesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.leading.equalToSuperview().offset(22.5)
        }
        
        exchangeRatesButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(19)
        }
        
        exchangeRatesStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.trailing.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().inset(5)
        }
        
        converterView.snp.makeConstraints { make in
            make.top.equalTo(exchangeRatesView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(220)
            make.bottom.equalToSuperview().inset(24)
        }
        
        converterTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.leading.equalToSuperview().offset(22.5)
        }
        
        byTextField.snp.makeConstraints { make in
            make.top.equalTo(converterTitleLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(75)
        }
        
        sellTextField.snp.makeConstraints { make in
            make.top.equalTo(byTextField.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(75)
        }
        
        oppositeSignButton.snp.makeConstraints { make in
            make.top.equalTo(byTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(40)
            make.height.equalTo(20)
        }
        
        choiceByCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(converterTitleLabel.snp.bottom).offset(27)
            make.leading.equalTo(byTextField.snp.trailing).offset(30)
            make.width.equalTo(60)
        }
        
        choiceSellCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(choiceByCurrencyButton.snp.bottom).offset(47)
            make.leading.equalTo(sellTextField.snp.trailing).offset(30)
            make.width.equalTo(60)
        }
        
        imageConventerTransition.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(17)
            make.trailing.equalToSuperview().inset(22.5)
        }
        
        atmFinderButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().inset(22.5)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardViewTap))
        cardView.addGestureRecognizer(tap)
       
    }
}

private extension Dashboard {
    
    func loadMockData() {
        self.currentRates = [
            CurrencyRate(id: 1, flagAndCode: "🇺🇸 USD", value: "3.07 BYN"),
            CurrencyRate(id: 2, flagAndCode: "🇪🇺 EUR", value: "3.57 BYN"),
            CurrencyRate(id: 3, flagAndCode: "🇷🇺 RUB", value: "0.03 BYN"),
            CurrencyRate(id: 4, flagAndCode: "🏆 Gold (XAU)", value: "510,08 BYN"),
            CurrencyRate(id: 5, flagAndCode: "🥈 Silver (XAG)", value: "4,96 BYN")
        ]
    }

    func loadLiveResult() {
        ratesRepository.fetchAll { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let liveRates):
                self.currentRates = liveRates
                    .filter { ["USD","EUR","RUB","XAU","XAG"].contains($0.code) }
                    .map { RateMapper.toCurrencyRate($0) }
            case .failure(let error):
                print("Dashboard rates error:", error)
                self.loadMockData()
            }
        }
    }

    func updateRatesUI() {
        exchangeRatesStackView.arrangedSubviews.forEach { view in
            exchangeRatesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for rate in currentRates {
            let rowView = createRateRow(for: rate)
            exchangeRatesStackView.addArrangedSubview(rowView)
        }
    }

    func createRateRow(for rate: CurrencyRate) -> UIView {
        let rowView = UIControl()
        rowView.tag = rate.id
        rowView.isUserInteractionEnabled = true
        rowView.addTarget(self, action: #selector(exchangeRatesTap(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.text = rate.flagAndCode
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.isUserInteractionEnabled = false
        
        let valueLabel = UILabel()
        valueLabel.text = rate.value
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.isUserInteractionEnabled = false
        
        rowView.addSubview(label)
        rowView.addSubview(valueLabel)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(20)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalTo(label.snp.centerY)
        }
        
        rowView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        return rowView
    }
}

private extension Dashboard {
    
    @objc func cardViewTap() {
        let alert = UIAlertController(title: "Your card", message: "You are not logged in; you need to log in to view your balance.", preferredStyle: .actionSheet)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(actionOK)
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = cardView
            pop.sourceRect = cardView.bounds
        }
        present(alert, animated: true)
    }
    
    @objc func notificationTap() {
        notificationDot.isHidden = true
        let alert = UIAlertController(title: "Notifications", message: "No new notifications", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    @objc func exchangeAllTap() {
        coordinator?.showAllRates()
    }
    
    @objc func exchangeRatesTap(_ sender: UIControl) {
        guard let tapped = currentRates.first(where: { $0.id == sender.tag }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
       
        let numeric = tapped.value
            .replacingOccurrences(of: " BYN", with: "")
            .replacingOccurrences(of: ",", with: ".")
        let price = Double(numeric) ?? 0

        let lower = tapped.flagAndCode.lowercased()
        let section: ExchangeSection
        let cleanName: String

        if lower.contains("gold") {
            section = .metals
            cleanName = "Gold (XAU)"
        } else if lower.contains("silver") {
            section = .metals
            cleanName = "Silver (XAG)"
        } else {
            section = .currencies
            cleanName = tapped.flagAndCode
                .components(separatedBy: " ")
                .last ?? tapped.flagAndCode
        }

        let item = ExchangeTableItem(
            id: cleanName,
            name: cleanName,
            price: price,
            change24h: Double.random(in: -2.0...2.0),
            section: section,
            iconName: tapped.flagAndCode,
            isFavorite: false,
            rate: nil
        )

        let history: [Double] = (0..<30).map { _ in
            price * Double.random(in: 0.97...1.03)
        }

        coordinator?.showChart(item: item, history: history, rate: tapped)
    }
    
    @objc func oppositeButtonTap() {
        let sourceTitle = choiceByCurrencyButton.title(for: .normal)
        choiceByCurrencyButton.setTitle(choiceSellCurrencyButton.title(for: .normal), for: .normal)
        choiceSellCurrencyButton.setTitle(sourceTitle, for: .normal)
                updateLiveResult()
    }

    
    @objc func choiceByTap() {
        showCurrencyAlert { [weak self] selectedCurrency in
            self?.choiceByCurrencyButton.setTitle("\(selectedCurrency) 🔽", for: .normal)
            self?.updateLiveResult()
        }
    }
    
    @objc func choiceSellTap() {
        showCurrencyAlert { [weak self] selectedCurrency in
            self?.choiceSellCurrencyButton.setTitle("\(selectedCurrency) 🔽", for: .normal)
            self?.updateLiveResult()
        }
    }
    
    @objc func converterTransitionTap() {
        coordinator?.showConverter()
    }
    
    @objc func atmFinderTap() {
        coordinator?.showMap()
    }
    
    @objc func amountChanged() {
        updateLiveResult()
    }
}

private extension Dashboard {
    func showCurrencyAlert(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select a currency", message: nil, preferredStyle: .actionSheet)
        let currencies = ["USD", "EUR", "RUB", "BYN"]
        
        currencies.forEach { currency in
            alert.addAction(UIAlertAction(title: currency, style: .default, handler: { _ in
                completion(currency)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }
    
    func updateLiveResult() {
        let amount = Double(byTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
        let fromCode = (choiceByCurrencyButton.title(for: .normal) ?? "USD").replacingOccurrences(of: " 🔽", with: "")
        let toCode = (choiceSellCurrencyButton.title(for: .normal) ?? "BYN").replacingOccurrences(of: " 🔽", with: "").trimmingCharacters(in: .whitespaces)
        let fromRate = findRate(code: fromCode)
        let toRate = findRate(code: toCode)
        
        guard fromRate > 0, toRate > 0 else {
            sellTextField.text = "-"
            return
        }
        let result = (amount * fromRate) / toRate
        sellTextField.text = String(format: "%.2f", result)
    }
    
    func findRate(code: String) -> Double {
        ratesRepository.rate(for: code)
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

extension Dashboard: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
}
