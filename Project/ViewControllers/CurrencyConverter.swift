import UIKit
import SnapKit

class CurrencyConverter: UIViewController {
    
    private var historyData: [ConversionHistoryItem] = [
        ConversionHistoryItem(sourceAmount: "100", sourceCurrency: "USD", targetAmount: "88.04", targetCurrency: "EUR"),
        ConversionHistoryItem(sourceAmount: "50", sourceCurrency: "EUR", targetAmount: "56.79", targetCurrency: "USD")
    ]
    
    private var currentInput = "0"
    private var sourceCurrency: String = "BYN"
    private var targetCurrency: String = "USD"
    
    private let ratesRepository: RatesRepository
    
    init(ratesRepository: RatesRepository) {
        self.ratesRepository = ratesRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var currencyView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.blue.cgColor
        return view
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00 USD"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var fromStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private lazy var fromTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0.00"
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 28, weight: .medium)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var fromCurrencyButton: UIButton = {
        let button = UIButton()
        button.setTitle("BYN 🔽", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(selectSourceCurrency), for: .touchUpInside)
        return button
    }()
    
    private lazy var toStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private lazy var toTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0.00"
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 28, weight: .medium)
        textField.borderStyle = .roundedRect
        textField.isEnabled = false
        textField.backgroundColor = .systemGray6
        return textField
    }()
    
    private lazy var toCurrencyButton: UIButton = {
        let button = UIButton()
        button.setTitle("USD 🔽", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(selectTargetCurrency), for: .touchUpInside)
        return button
    }()
    
    private lazy var swapButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(swapCurrencies), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save ✅", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var historyLabel: UILabel = {
        let label = UILabel()
        label.text = "History conversion"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var historyTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIConverter()
        applyGradientBackground()
        updateLiveResult()
        
        ratesRepository.fetchAll { [weak self] _ in
            self?.updateLiveResult()
        }
    }
}

private extension CurrencyConverter {
    func setupUIConverter() {
      
        [fromStackView, toStackView, swapButton, historyTableView, currencyView, resultLabel, saveButton].forEach {
            view.addSubview($0)
        }
        
        currencyView.addSubview(historyLabel)
        currencyView.addSubview(historyTableView)
        
        [fromTextField, fromCurrencyButton].forEach {
            fromStackView.addArrangedSubview($0)
        }
        
        [toTextField, toCurrencyButton].forEach {
            toStackView.addArrangedSubview($0)
        }
    
        currencyView.snp.makeConstraints { make in
            make.top.equalTo(fromStackView.snp.bottom).offset(150)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(7)
            make.bottom.equalToSuperview()
        }
        
        historyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
        }
        
        fromStackView.snp.makeConstraints { make in
            make.top.equalTo(swapButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(view.snp.centerX).inset(20)
        }
        
        toStackView.snp.makeConstraints { make in
            make.top.equalTo(fromStackView)
            make.leading.equalTo(view.snp.centerX).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        
        swapButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(30)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(fromStackView.snp.bottom).offset(70)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
        }
        
        historyTableView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(currencyView)
        }
    }
}

private extension CurrencyConverter {
    
    @objc private func swapCurrencies() {
        let currency = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = currency
        
        let sourceText = fromTextField.text
        fromTextField.text = toTextField.text
        toTextField.text = sourceText
        
        updateCurrencyButtons()
        updateLiveResult()
    }
    
    @objc private func selectSourceCurrency() {
        showCurrencyAlert { [weak self] selectedCurrency in
            guard let self else { return }
            self.sourceCurrency = selectedCurrency
            self.updateCurrencyButtons()
            self.updateLiveResult()
        }
    }
    
    @objc private func selectTargetCurrency() {
        showCurrencyAlert { [weak self] selectedCurrency in
            guard let self else { return }
            self.targetCurrency = selectedCurrency
            self.updateCurrencyButtons()
            self.updateLiveResult()
        }
    }
    
    @objc func amountChanged() {
        updateLiveResult()
    }
    
    @objc func saveButtonTapped() {
        saveToHistory()
    }
}

private extension CurrencyConverter {
    
    func updateCurrencyButtons() {
        fromCurrencyButton.setTitle("\(sourceCurrency) 🔽", for: .normal)
        toCurrencyButton.setTitle("\(targetCurrency) 🔽", for: .normal)
    }
    
    func showCurrencyAlert(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select a currency", message: nil, preferredStyle: .actionSheet)
        let currencies = ["BYN", "USD", "EUR", "RUB", "CNY", "GBP", "XAU", "XAG"]
        
        currencies.forEach { currency in
            alert.addAction(UIAlertAction(title: currency, style: .default, handler: { _ in
                completion(currency)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = view.bounds
        }
        present(alert, animated: true)
    }

    func updateLiveResult() {
        let text = fromTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let amount = Double(text) ?? 0
        let result = ratesRepository.convert(amount, from: sourceCurrency, to: targetCurrency)
        
        toTextField.text = String(format: "%.2f", result)
        resultLabel.text = String(format: "%.2f %@", result, targetCurrency)
    }
    
    func saveToHistory() {
        let sourceText = fromTextField.text ?? "0"
        let targetText = toTextField.text ?? "0"
        
        guard !sourceText.isEmpty,
              Double(sourceText) != 0 else { return }
        let newItem = ConversionHistoryItem(sourceAmount: sourceText, sourceCurrency: sourceCurrency, targetAmount: targetText, targetCurrency: targetCurrency)
        historyData.insert(newItem, at: 0)
        historyTableView.reloadData()
        historyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension CurrencyConverter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let item = historyData[indexPath.row]
        
        var configure = cell.defaultContentConfiguration()
        configure.text = "\(item.sourceAmount) \(item.sourceCurrency) -> \(item.targetAmount) \(targetCurrency) -> \(item.targetCurrency)"
        configure.secondaryText = "\(item.sourceCurrency) -> \(item.targetCurrency)"
        
        configure.textProperties.color = .white
        configure.secondaryTextProperties.color = UIColor.white.withAlphaComponent(0.7)
        cell.contentConfiguration = configure
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = historyData[indexPath.row]
        sourceCurrency = item.sourceCurrency
        targetCurrency = item.targetCurrency
        fromTextField.text = item.sourceAmount
        updateCurrencyButtons()
        updateLiveResult()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        historyData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}


