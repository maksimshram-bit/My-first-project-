import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "App_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BankApp"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your reliable financial assistant"
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 1.0.0"
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateLogo()
        applyGradientBackground()
    }
    
    private func setupUI() {

        [logoImageView, titleLabel, subtitleLabel, activityIndicator, versionLabel].forEach {
            view.addSubview($0)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.size.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.centerX.equalToSuperview()
        }
    }
}

private extension LoadingViewController {
    func animateLogo() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: [.autoreverse, .repeat],
                       animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
    }
}
