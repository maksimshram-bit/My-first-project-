import UIKit
import SnapKit
import MapKit

class MapView: UIViewController {
    
    private var points: [MapPoint] = []
    private var filteredPoints: [MapPoint] = []
    private var searchResults: [MapPoint] = []
    private var selectedFilter: Int = 0
    
    private let locationManager = CLLocationManager()
    
    private lazy var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bank map"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private lazy var topCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.userTrackingMode = .none
        map.layer.cornerRadius = 24
        map.layer.borderWidth = 2
        map.layer.borderColor = UIColor.systemBlue.cgColor
        map.clipsToBounds = true
        map.delegate = self
        map.register(PointAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: PointAnnotationView.reuseID)
        return map
    }()
    
    private lazy var filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var allButton = UIButton(type: .system)
    private lazy var atmButton = UIButton(type: .system)
    private lazy var branchButton = UIButton(type: .system)
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search: address, name..."
        search.searchBarStyle = .minimal
        search.delegate = self
        search.returnKeyType = .search
        return search
    }()
    
    private lazy var myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapMyLocation), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapZoomIn), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapZoomOut), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var pointsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 90)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.register(PointCollectionViewCell.self,
                            forCellWithReuseIdentifier: PointCollectionViewCell.reuseID)
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        setupUI()
        setupConstraints()
        applyGradientBackground()
        loadRealData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerOnUserIfPossible()
    }
}

private extension MapView {
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupUI() {
        [screenTitleLabel, topCardView, mapView,
         myLocationButton, zoomInButton, zoomOutButton, bottomCardView].forEach { view.addSubview($0) }
        
        [allButton, atmButton, branchButton].forEach {
            filterStackView.addArrangedSubview($0)
        }
        
        topCardView.addSubview(filterStackView)
        topCardView.addSubview(searchBar)
        bottomCardView.addSubview(pointsCollectionView)
        
        setupButtons()
    }
    
    func setupConstraints() {
        screenTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        topCardView.snp.makeConstraints { make in
            make.top.equalTo(screenTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(110)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(36)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(6)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topCardView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        bottomCardView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(110)
        }
        
        pointsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        myLocationButton.snp.makeConstraints { make in
            make.trailing.equalTo(mapView.snp.trailing).offset(-16)
            make.bottom.equalTo(mapView.snp.bottom).offset(-16)
            make.width.height.equalTo(44)
        }
        
        zoomInButton.snp.makeConstraints { make in
            make.trailing.equalTo(myLocationButton)
            make.bottom.equalTo(myLocationButton.snp.top).offset(-12)
            make.width.height.equalTo(44)
        }
        
        zoomOutButton.snp.makeConstraints { make in
            make.trailing.equalTo(myLocationButton)
            make.bottom.equalTo(zoomInButton.snp.top).offset(-12)
            make.width.height.equalTo(44)
        }
        
        mapView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomCardView.snp.top).offset(-12)
        }
    }
    
    func setupButtons() {
        configure(button: allButton, title: "All", tag: 0, isSelected: true)
        configure(button: atmButton, title: "ATMs", tag: 1, isSelected: false)
        configure(button: branchButton, title: "Branches", tag: 2, isSelected: false)
    }
    
    func configure(button: UIButton, title: String, tag: Int, isSelected: Bool) {
        button.tag = tag
        button.isSelected = isSelected
        
        button.configurationUpdateHandler = { btn in
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10,
                                                           bottom: 6, trailing: 10)
            
            var titleAttr = AttributedString(title)
            titleAttr.font = .systemFont(ofSize: 12, weight: .medium)
            
            if button.isSelected {
                config.background.backgroundColor = .systemBlue
                titleAttr.foregroundColor = .white
            } else {
                config.background.backgroundColor = .systemGray6
                titleAttr.foregroundColor = .label
            }
            
            config.attributedTitle = titleAttr
            button.configuration = config
        }
        
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
    }
    
    func loadRealData() {
        
        BelarusbankAPIService.shared.fetchATMs(city: "Минск") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let atmPoints):
                self.points = atmPoints
                self.filteredPoints = atmPoints
                self.updateAnnotations()
                self.pointsCollectionView.reloadData()
                
            case .failure(let error):
                print("Ошибка загрузки данных: \(error)")
                self.showErrorAlert(message: "Не удалось загрузить данные о банкоматах")
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private extension MapView {
    
    @objc
    private func filterTapped(_ sender: UIButton) {
        [allButton, atmButton, branchButton].forEach {
            $0.isSelected = ($0 == sender)
        }
        selectedFilter = sender.tag
        applyFilter()
    }
    
    @objc
    private func didTapMyLocation() {
        centerOnUserIfPossible(animated: true)
    }
    
    @objc private func didTapZoomIn() {
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func didTapZoomOut() {
        var region = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
}

private extension MapView {
    
    func applyFilter() {
        switch selectedFilter {
        case 1: filteredPoints = points.filter { $0.type == .atm }
        case 2: filteredPoints = points.filter { $0.type == .branch }
        default: filteredPoints = points
        }
        updateAnnotations()
        pointsCollectionView.reloadData()
    }
    
    func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = filteredPoints.map { PointAnnotation(point: $0) }
        mapView.addAnnotations(annotations)
    }
    
    func centerOnUserIfPossible(animated: Bool = true) {
        guard let location = locationManager.location else {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590),
                latitudinalMeters: 15_000,
                longitudinalMeters: 15_000
            )
            mapView.setRegion(region, animated: animated)
            return
        }
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        mapView.setRegion(region, animated: animated)
    }
    
    func focusOn(point: MapPoint) {
        let region = MKCoordinateRegion(center: point.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        if let annotation = mapView.annotations
            .compactMap({ $0 as? PointAnnotation })
            .first(where: { $0.point.id == point.id }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func showPopup(for point: MapPoint) {
        let alert = UIAlertController(
            title: point.name,
            message: """
                    Адрес: \(point.address)
                    Режим работы: \(point.schedule)
                    Очередь: \(point.queueStatus)
                    """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MapView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PointCollectionViewCell.reuseID,
            for: indexPath
        ) as! PointCollectionViewCell
        cell.configure(with: filteredPoints[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let point = filteredPoints[indexPath.item]
        focusOn(point: point)
    }
}

extension MapView: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pointAnnotation = annotation as? PointAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: PointAnnotationView.reuseID,
            for: pointAnnotation
        ) as! PointAnnotationView
        view.configure(with: pointAnnotation.point)
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let pointAnnotation = annotation as? PointAnnotation else { return }
        showPopup(for: pointAnnotation.point)
    }
}

extension MapView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        if query.isEmpty {
            applyFilter()
            return
        }
        filteredPoints = points.filter {
            $0.name.lowercased().contains(query) ||
            $0.address.lowercased().contains(query)
        }
        updateAnnotations()
        pointsCollectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let first = filteredPoints.first {
            focusOn(point: first)
        }
    }
}

extension MapView: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
}

