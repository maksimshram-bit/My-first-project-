import UIKit
import SnapKit
import MapKit

class Settings: UIViewController {
    
    private var data: LocationDetail?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private weak var coordinator: SettingsCoordinatorProtocol?
    
    init(coordinator: SettingsCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private lazy var locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "building.2.fill")
        imageView.tintColor = .systemGray3
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        return imageView
    }()
   
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var servicesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Services"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var servicesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var actionButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var routeButton: UIButton = createActionButton(title: "Get directions", image: "map.fill", color: .systemBlue, action: #selector(didTapRoute))
    
    private lazy var callButton: UIButton = createActionButton(title: "Call", image: "phone.fill", color: .systemGreen, action: #selector(didTapCall))
    
    private lazy var copyAddressButton: UIButton = createActionButton(title: "Copy address", image: "doc.on.doc.fill", color: .systemGray5, textColor: .label, action: #selector(didTapCopyAddress))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        applyGradientBackground()
        
        let mockData = LocationDetail(
            title: "Беларусбанк - ЦБУ No511",
            type: "Branch",
            imageUrl: nil,
            address: "г. Минск, ул. Долгобродская 1",
            workingHours: "Пн-Пт: 09:00 — 19:00\nСб: Выходной\nВс: Выходной",
            phone: "+375 17 218 84 31",
            services: ["Currency exchange", "Lending", "Utility bill payment"],
            latitude: 53.9006,
            longitude: 27.5590
        )
        configure(with: mockData)
    }
}

private extension Settings {
    
    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [locationImageView, typeLabel, titleLabel, infoStackView, servicesTitleLabel, servicesStackView, actionButtonsStackView].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(locationImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        servicesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        servicesStackView.snp.makeConstraints { make in
            make.top.equalTo(servicesTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        actionButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(servicesStackView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }
        
        actionButtonsStackView.addArrangedSubview(routeButton)
        actionButtonsStackView.addArrangedSubview(callButton)
        actionButtonsStackView.addArrangedSubview(copyAddressButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImageAlert))
        locationImageView.isUserInteractionEnabled = true
        locationImageView.addGestureRecognizer(tap)
    }
    
    func configure(with model: LocationDetail) {
        self.data = model
        
        titleLabel.text = model.title
        typeLabel.text = model.type.uppercased()
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        servicesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addInfoRow(icon: "mappin.and.ellipse", text: model.address)
        addInfoRow(icon: "clock", text: model.workingHours)
        if let phone = model.phone {
            addInfoRow(icon: "phone", text: phone)
            callButton.isHidden = false
        } else {
            callButton.isHidden = true
        }
        
        for service in model.services {
            let serviceRow = createServiceRow(text: service)
            servicesStackView.addArrangedSubview(serviceRow)
        }
        
        if let imageUrlString = model.imageUrl,
           let url = URL(string: imageUrlString) {
        }
    }
}
    
private extension Settings {
    
    func addInfoRow(icon: String, text: String) {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .top
        
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(label)
        infoStackView.addArrangedSubview(container)
    }
    
    func createServiceRow(text: String) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 10
        container.alignment = .center
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.tintColor = .systemGreen
        checkmark.snp.makeConstraints { make in
            make.size.equalTo(18)
        }
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        
        container.addArrangedSubview(checkmark)
        container.addArrangedSubview(label)
        return container
    }
    
    func createActionButton(title: String, image: String, color: UIColor, textColor: UIColor = .white, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        var configure = UIButton.Configuration.filled()
        configure.title = title
        configure.image = UIImage(systemName: image)
        configure.imagePadding = 8
        configure.baseBackgroundColor = color
        configure.baseForegroundColor = textColor
        configure.cornerStyle = .fixed
        configure.background.cornerRadius = 12
        configure.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 16, weight: .semibold)
            return out
        }
        button.configuration = configure
        button.snp.makeConstraints { $0.height.equalTo(50) }
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func open(urlString: String, fallback: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webURL = URL(string: fallback) {
            UIApplication.shared.open(webURL)
        }
    }
    
    func showToast(_ text: String) {
        let toast = UILabel()
        toast.text = " \(text) "
        toast.font = .systemFont(ofSize: 14, weight: .medium)
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 12
        toast.layer.masksToBounds = true
        toast.alpha = 0
        
        view.addSubview(toast)
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        
        UIView.animate(withDuration: 0.25) { toast.alpha = 1 } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 1.4) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview() }
        }
    }
}
    
private extension Settings {
    
    @objc func showImageAlert() {
        let alert = UIAlertController(title: "You have not selected a bank.", message: "A photo of your bank's location will appear here.", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOK)
        
        present(alert, animated: true)
    }
    
    @objc func didTapRoute() {
        guard let data else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let alert = UIAlertController(title: "Get directions", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yandex.maps", style: .default) { _ in
            let url = "Yandexmaps://build_route_on_map?lat_to=\(data.latitude)&lon_to=\(data.longitude)"
            self.open(urlString: url, fallback: "https://yandex.ru/maps/?rtext=~\(data.latitude),\(data.longitude)")
        })
        
        alert.addAction(UIAlertAction(title: "Google maps", style: .default) { _ in
            let url = "comgooglemaps://?daddr=\(data.latitude),\(data.longitude)&directionsmode=driving"
            self.open(urlString: url, fallback: "https://www.google.com/maps/dir/?api=1&destination=\(data.latitude),\(data.longitude)")
        })
        
        alert.addAction(UIAlertAction(title: "Apple maps", style: .default) { _ in
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude))
            let item = MKMapItem(placemark: placemark)
            item.name = data.title
            
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = routeButton
            pop.sourceRect = routeButton.bounds
        }
        present(alert, animated: true)
    }
    
    @objc func didTapCall() {
        guard let phone = data?.phone else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let cleaned = phone.components(separatedBy: CharacterSet(charactersIn: "+0123456789").inverted).joined()
        guard let url = URL(string: "tel://\(cleaned)"),
              UIApplication.shared.canOpenURL(url) else {
            showToast("Unable to make the call")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc func didTapCopyAddress() {
        guard let address = data?.address else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIPasteboard.general.string = address
        showToast("Address copied")
    }
}

