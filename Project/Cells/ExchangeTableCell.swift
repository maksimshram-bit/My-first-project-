import UIKit
import SnapKit

protocol ExchangeTableCellDelegate: AnyObject {
    func didTapFavorite(in cell: ExchangeTableCell)
}

final class ExchangeTableCell: UITableViewCell {
    
    static let reuseIdentifier = "ExchangeTableCell"
    weak var delegate: ExchangeTableCellDelegate?
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        label.alpha = 0.7
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteButton.setImage(nil, for: .normal)
    }
    
    private func setupUI() {
        
        selectionStyle = .none
        backgroundColor = .clear
        
        [iconView, codeLabel, nameLabel, priceLabel, changeLabel, favoriteButton].forEach {
            contentView.addSubview($0)
        }
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        codeLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(codeLabel)
            make.top.equalTo(codeLabel.snp.bottom).offset(2)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(priceLabel)
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
        }
    }
    
    func configure(with item: ExchangeTableItem) {
        iconView.image = UIImage(systemName: item.iconName)
        codeLabel.text = item.id
        nameLabel.text = item.name
        priceLabel.text = String(format: "%.4f", item.price)
        changeLabel.text = item.changeText
        changeLabel.textColor = item.isPositive ? .systemGreen : .systemRed
        
        let favoriteImage = item.isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: favoriteImage), for: .normal)
    }
    
    @objc private func favTapped() {
        delegate?.didTapFavorite(in: self)
    }
}
