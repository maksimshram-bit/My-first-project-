import Foundation
import MapKit

struct MapPoint {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: MapPointType
    let schedule: String
    let queueStatus: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
