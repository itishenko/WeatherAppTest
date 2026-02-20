import CoreLocation

final class LocationService: NSObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var onLocation: ((CLLocation) -> Void)?
    private var onDenied: (() -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation(
        onLocation: @escaping (CLLocation) -> Void,
        onDenied: @escaping () -> Void
    ) {
        self.onLocation = onLocation
        self.onDenied = onDenied

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            onDenied()
        @unknown default:
            onDenied()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        onLocation?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onDenied?()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            onDenied?()
        default:
            break
        }
    }
}
