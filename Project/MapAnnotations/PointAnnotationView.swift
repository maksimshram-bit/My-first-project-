import MapKit
import UIKit

final class PointAnnotationView: MKMarkerAnnotationView {
    
    static let reuseID = "PointAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
        animatesWhenAdded = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with point: MapPoint) {
        markerTintColor = point.type.color
        glyphTintColor = .white
        glyphImage = UIImage(systemName: point.type == .atm ? "banknote" : "building.columns")
    }
}
