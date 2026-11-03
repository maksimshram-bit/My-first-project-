import UIKit
import SnapKit

final class ScheduleController: UIViewController {
    
    private let rate: CurrencyRate?
    
    private let item: ExchangeTableItem
    private let history: [Double]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = item.name.isEmpty ? item.id : item.name
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        label.text = String(format: "%.4f", item.price)
        return label
    }()
    
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.text = item.changeText + " за 24ч"
        label.textColor = item.isPositive ? .systemGreen : .systemRed
        return label
    }()
    
    private lazy var chartView: LineChartView = {
        let view = LineChartView()
        view.values = history
        view.lineColor = item.isPositive ? .systemGreen : .systemRed
        return view
    }()
    
    init(item: ExchangeTableItem, history: [Double], rate: CurrencyRate?) {
        self.item = item
        self.history = history
        self.rate = rate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        setupUI()
    }
    
    private func setupUI() {
        [titleLabel, priceLabel, changeLabel, chartView].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
        
        chartView.snp.makeConstraints { make in
            make.top.equalTo(changeLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(260)
        }
    }
}
