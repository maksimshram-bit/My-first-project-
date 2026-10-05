import UIKit
import SnapKit

class PointCollectionViewCell: UICollectionViewCell {
   
    static let reuseID = "PointCell"
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var queueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGreen
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        
        [iconContainer, nameLabel, addressLabel, scheduleLabel, queueLabel].forEach {
            contentView.addSubview($0)
        }
        iconContainer.addSubview(iconImageView)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(iconContainer.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
        }
        
        queueLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(scheduleLabel)
            make.top.equalTo(scheduleLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)

//            make.trailing.equalToSuperview().inset(12)
        }
    }
    
    func configure(with point: MapPoint) {
        nameLabel.text = point.name
        addressLabel.text = point.address
        scheduleLabel.text = point.schedule
        queueLabel.text = "Очередь: \(point.queueStatus)"
        iconContainer.backgroundColor = point.type.color
        iconImageView.image = UIImage(systemName: point.type == .atm ? "banknote" : "building.columns")
    }
}
