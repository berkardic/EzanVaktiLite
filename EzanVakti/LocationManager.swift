import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // 🐛 DEBUG: Konum debug paneli için veri
    @Published var debugInfo: LocationDebugInfo = LocationDebugInfo()

    // Tek seferlik konum isteği için completion handler
    private var locationCompletionHandler: ((Result<CLLocation, Error>) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
        
        // Mevcut izin durumunu kontrol et
        checkAuthorizationStatus()
    }
    
    /// İzin durumunu kontrol et ve güncelle
    private func checkAuthorizationStatus() {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }

    /// "When In Use" izni iste
    func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    /// "Always" izni iste (önce "When In Use" verilmiş olmalı)
    func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }
    
    /// Varsayılan izin isteği - "When In Use" ile başlar
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Tek seferlik konum iste.
    /// 60 saniyeden taze bir önbellek varsa anında döner.
    /// Yoksa `requestLocation()` ile iOS'un kendi timeout'unu (~10s) kullanır.
    func requestCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        print("📍 LocationManager: requestCurrentLocation called")
        print("📍 LocationManager: Current authorization status: \(authorizationStatus.rawValue)")
        
        // İzin kontrolü
        guard isAuthorized else {
            print("📍 LocationManager: Not authorized. Status: \(authorizationStatus.rawValue)")
            let error = NSError(domain: "LocationManager", code: 1, 
                              userInfo: [NSLocalizedDescriptionKey: "Konum izni verilmedi"])
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        
        // Taze önbellek var mı?
        if let cached = manager.location,
           abs(cached.timestamp.timeIntervalSinceNow) < 60 {
            print("📍 LocationManager: Using cached location: \(cached.coordinate)")
            DispatchQueue.main.async { completion(.success(cached)) }
            return
        }
        
        print("📍 LocationManager: Requesting fresh location...")
        // Halihazırda devam eden bir istek varsa öncekini iptal et
        locationCompletionHandler = completion
        manager.requestLocation()   // iOS'un timeout + best-effort konumunu kullanır
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        print("📍 LocationManager: Did update location: \(loc.coordinate)")
        
        DispatchQueue.main.async {
            self.location = loc
            
            // 🐛 DEBUG: Debug paneli için bilgi güncelleme
            self.debugInfo.latitude  = String(format: "%.4f", loc.coordinate.latitude)
            self.debugInfo.longitude = String(format: "%.4f", loc.coordinate.longitude)
            self.debugInfo.error     = nil

            // Completion handler varsa çağır (requestLocation'dan gelen cevap)
            if let handler = self.locationCompletionHandler {
                self.locationCompletionHandler = nil
                handler(.success(loc))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 LocationManager: Did fail with error: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            // 🐛 DEBUG: Debug paneli için hata bilgisi
            self.debugInfo.error = error.localizedDescription
            
            if let handler = self.locationCompletionHandler {
                self.locationCompletionHandler = nil
                handler(.failure(error))
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            // Debug bilgisi
            let statusText: String
            switch status {
            case .notDetermined: statusText = "not determined"
            case .restricted: statusText = "restricted"
            case .denied: statusText = "denied"
            case .authorizedAlways: statusText = "always"
            case .authorizedWhenInUse: statusText = "when in use"
            @unknown default: statusText = "unknown"
            }
            print("📍 LocationManager: Authorization status changed to: \(statusText)")
        }
        // NOT: Burada startUpdatingLocation() ÇAĞIRMIYORUZ.
        // Konum isteği ViewModel'deki enableLocationMode() tarafından kontrol edilir.
    }

    // Debug panelini güncellemek için ViewModel'den çağrılır
    func applyPlacemark(_ p: CLPlacemark, location: CLLocation) {
        debugInfo = LocationDebugInfo(
            latitude:              String(format: "%.4f", location.coordinate.latitude),
            longitude:             String(format: "%.4f", location.coordinate.longitude),
            name:                  p.name ?? "-",
            thoroughfare:          p.thoroughfare ?? "-",
            subThoroughfare:       p.subThoroughfare ?? "-",
            locality:              p.locality ?? "-",
            subLocality:           p.subLocality ?? "-",
            administrativeArea:    p.administrativeArea ?? "-",
            subAdministrativeArea: p.subAdministrativeArea ?? "-",
            postalCode:            p.postalCode ?? "-",
            country:               p.country ?? "-",
            isoCountryCode:        p.isoCountryCode ?? "-",
            error:                 nil
        )
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
}

struct LocationDebugInfo {
    var latitude:              String = "-"
    var longitude:             String = "-"
    var name:                  String = "-"
    var thoroughfare:          String = "-"
    var subThoroughfare:       String = "-"
    var locality:              String = "-"
    var subLocality:           String = "-"
    var administrativeArea:    String = "-"
    var subAdministrativeArea: String = "-"
    var postalCode:            String = "-"
    var country:               String = "-"
    var isoCountryCode:        String = "-"
    var error:                 String? = nil
}
