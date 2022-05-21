import CoreLocation

@available(iOS 13.0, *)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  @Published var authorized = false

  override init() {
    super.init()
    locationManager.delegate = self
      if #available(iOS 14.0, *) {
          if locationManager.authorizationStatus == .authorizedWhenInUse {
              authorized = true
              locationManager.startMonitoringSignificantLocationChanges()
          }
      } else {
          // Fallback on earlier versions
      }
  }

  func requestAuthorization() {
  //request location authorization when the user taps the Request Location Authorization button
    locationManager.requestWhenInUseAuthorization()
  }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                authorized = true
            } else {
                authorized = false
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
