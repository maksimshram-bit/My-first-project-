import MapKit

final class PointAnnotation: NSObject, MKAnnotation {
    
    let point: MapPoint
    
    dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String? { point.name }
    
    var subtitle: String? { point.address }
    
    init(point: MapPoint) {
        self.point = point
        self.coordinate = point.coordinate
        super.init()
    }
}
