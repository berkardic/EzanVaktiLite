import Flutter
import UIKit
import CoreLocation
import MapKit
import WidgetKit
import ActivityKit

// MARK: - NativeLocationHandler

/// iOS 14+ instance-based CLLocationManager kullanır.
/// geolocator_apple'ın deprecated CLLocationManager.authorizationStatus class method
/// sorununu bypass eder — iOS 26'da fresh install'da "denied" döndüren bug için çözüm.
class NativeLocationHandler: NSObject, CLLocationManagerDelegate {

  private var pendingResult: FlutterResult?
  private var locationManager: CLLocationManager?

  // MARK: - Public API

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkLocationPermission":
      result(currentStatusString())
    case "requestLocationPermission":
      requestPermission(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Status helpers

  private func currentStatusString() -> String {
    let manager = CLLocationManager()
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = manager.authorizationStatus  // instance property — deprecated class method değil
    } else {
      status = CLLocationManager.authorizationStatus()  // iOS 13 fallback
    }
    return statusString(status)
  }

  private func statusString(_ status: CLAuthorizationStatus) -> String {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      return "authorized"
    case .denied:
      return "denied"
    case .restricted:
      return "deniedForever"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "unknown"
    }
  }

  // MARK: - Request permission

  private func requestPermission(result: @escaping FlutterResult) {
    // Fresh instance — önceki instance'ların durumundan bağımsız
    let manager = CLLocationManager()
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = manager.authorizationStatus  // instance property — deprecated class method değil
    } else {
      status = CLLocationManager.authorizationStatus()  // iOS 13 fallback
    }

    print("[NativeLocation] requestPermission — mevcut status: \(statusString(status))")

    if status == .notDetermined {
      print("[NativeLocation] requestWhenInUseAuthorization() çağrılıyor...")
      // Dialog göster
      locationManager = manager
      locationManager!.delegate = self
      pendingResult = result
      locationManager!.requestWhenInUseAuthorization()
    } else {
      // Zaten belirlenmiş — hemen dön
      print("[NativeLocation] Zaten belirlenmiş, dönülüyor: \(statusString(status))")
      result(statusString(status))
    }
  }

  // MARK: - CLLocationManagerDelegate

  // iOS 14+ yeni delegate — iOS 26'da bu çağrılır
  @available(iOS 14.0, *)
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    print("[NativeLocation] locationManagerDidChangeAuthorization: \(statusString(status))")
    if status == .notDetermined { return }
    deliverResult(status)
  }

  // iOS 13 ve öncesi eski delegate — fallback olarak da implement edildi
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
    print("[NativeLocation] locationManager:didChangeAuthorization: \(statusString(status))")
    if status == .notDetermined { return }
    deliverResult(status)
  }

  private func deliverResult(_ status: CLAuthorizationStatus) {
    guard let result = pendingResult else {
      print("[NativeLocation] deliverResult çağrıldı ama pendingResult nil!")
      return
    }
    print("[NativeLocation] deliverResult: \(statusString(status))")
    pendingResult = nil
    locationManager?.delegate = nil
    locationManager = nil
    result(statusString(status))
  }
}

// MARK: - Live Activity attributes (must match EzanVaktiWidget definition)

@available(iOS 16.2, *)
struct PrayerActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var nextPrayerName: String
    var nextPrayerDate: Date
    var districtName: String
  }
}

// MARK: - Live Activity handler (iOS 16.2+)

@available(iOS 16.2, *)
class PrayerLiveActivityHandler {
  static let shared = PrayerLiveActivityHandler()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start", "update":
      guard
        let args = call.arguments as? [String: Any],
        let name = args["nextPrayerName"] as? String,
        let tsMs  = args["nextPrayerTimestamp"] as? Double,
        let dist  = args["districtName"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        return
      }
      let date = Date(timeIntervalSince1970: tsMs / 1000.0)
      // Don't start activity for past dates
      guard date > Date() else { endAll(); result(nil); return }
      let state = PrayerActivityAttributes.ContentState(
        nextPrayerName: name,
        nextPrayerDate: date,
        districtName:   dist
      )
      startOrUpdate(state: state)
      result(nil)

    case "end":
      endAll()
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startOrUpdate(state: PrayerActivityAttributes.ContentState) {
    let running = Activity<PrayerActivityAttributes>.activities
    let staleDate = state.nextPrayerDate.addingTimeInterval(120)
    if running.isEmpty {
      let attrs = PrayerActivityAttributes()
      let content = ActivityContent(state: state, staleDate: staleDate)
      do {
        try Activity.request(attributes: attrs, content: content,
                             pushType: nil)
        print("[LiveActivity] started: \(state.nextPrayerName)")
      } catch {
        print("[LiveActivity] start error: \(error)")
      }
    } else {
      Task {
        for activity in running {
          let content = ActivityContent(state: state, staleDate: staleDate)
          await activity.update(content)
          print("[LiveActivity] updated: \(state.nextPrayerName)")
        }
      }
    }
  }

  func endAll() {
    Task {
      for activity in Activity<PrayerActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
        print("[LiveActivity] ended")
      }
    }
  }
}

// MARK: - Mosque Finder Handler (MKLocalSearch)

class MosqueFinderHandler: NSObject {

  func findNearby(lat: Double, lng: Double, result: @escaping FlutterResult) {
    let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    let region = MKCoordinateRegion(center: center,
                                    latitudinalMeters: 3000,
                                    longitudinalMeters: 3000)

    let searchTerms = ["cami", "mosque", "mescit"]
    var allItems: [MKMapItem] = []
    var pending = searchTerms.count
    let lock = NSLock()
    // Keep strong refs so searches aren't deallocated before completion
    var activeSearches: [MKLocalSearch] = []

    func finish() {
      lock.lock()
      pending -= 1
      let done = pending == 0
      lock.unlock()
      guard done else { return }

      activeSearches.removeAll()

      // Deduplicate: treat items within ~10m as the same place
      var unique: [MKMapItem] = []
      for item in allItems {
        let c = item.placemark.coordinate
        let isDup = unique.contains { ex in
          let e = ex.placemark.coordinate
          return abs(c.latitude - e.latitude) < 0.0001 &&
                 abs(c.longitude - e.longitude) < 0.0001
        }
        if !isDup { unique.append(item) }
      }

      print("[MosqueFinder] MKLocalSearch tamamlandı: \(unique.count) benzersiz sonuç")
      let list: [[String: Any]] = unique.map { item in
        let c = item.placemark.coordinate
        return ["name": item.name ?? "", "lat": c.latitude, "lng": c.longitude]
      }
      DispatchQueue.main.async { result(list) }
    }

    for term in searchTerms {
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = term
      request.region = region
      let search = MKLocalSearch(request: request)
      lock.lock()
      activeSearches.append(search)
      lock.unlock()
      search.start { response, error in
        if let error = error {
          print("[MosqueFinder] '\(term)' araması hata: \(error.localizedDescription)")
        }
        if let items = response?.mapItems {
          print("[MosqueFinder] '\(term)' araması \(items.count) sonuç döndürdü")
          lock.lock()
          allItems.append(contentsOf: items)
          lock.unlock()
        }
        finish()
      }
    }
  }
}

// MARK: - SceneDelegate

class SceneDelegate: FlutterSceneDelegate {

  private var locationHandler: NativeLocationHandler?
  private var mosqueFinderHandler: MosqueFinderHandler?

  override func scene(_ scene: UIScene,
                      willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    setupNativeLocationChannel()
  }

  private var _channelSetupRetries = 0

  private func setupNativeLocationChannel() {
    guard let flutterVC = self.window?.rootViewController as? FlutterViewController else {
      _channelSetupRetries += 1
      guard _channelSetupRetries <= 20 else {
        print("[SceneDelegate] HATA: FlutterViewController 4 saniyede bulunamadı, vazgeçildi")
        return
      }
      print("[SceneDelegate] FlutterVC henüz hazır değil, retry #\(_channelSetupRetries)")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        self?.setupNativeLocationChannel()
      }
      return
    }

    print("[SceneDelegate] FlutterVC bulundu (retry: \(_channelSetupRetries))")

    // FlutterSceneDelegate engine oluşturduğu için plugin'leri burada kaydet.
    // AppDelegate.application(_:didFinishLaunchingWithOptions:) sırasında engine
    // henüz hazır değil; bu yüzden shared_preferences ve diğer plugin'ler başarısız oluyor.
    print("[SceneDelegate] GeneratedPluginRegistrant kayıt ediliyor...")
    GeneratedPluginRegistrant.register(with: flutterVC)
    print("[SceneDelegate] GeneratedPluginRegistrant kaydı tamamlandı")

    // Native location channel
    let channel = FlutterMethodChannel(
      name: "com.yba.ezanvakti/location",
      binaryMessenger: flutterVC.binaryMessenger
    )
    locationHandler = NativeLocationHandler()
    channel.setMethodCallHandler { [weak self] call, result in
      print("[SceneDelegate] method call: \(call.method)")
      self?.locationHandler?.handle(call, result: result)
    }
    print("[SceneDelegate] location channel başarıyla kuruldu")

    // Widget data channel — Flutter app writes prayer data here so widgets can read it
    let widgetChannel = FlutterMethodChannel(
      name: "com.yba.ezanvakti/widget",
      binaryMessenger: flutterVC.binaryMessenger
    )
    widgetChannel.setMethodCallHandler { call, result in
      guard call.method == "updateWidgetData",
            let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      // Serialize and store in the shared App Group container
      if let jsonData = try? JSONSerialization.data(withJSONObject: args, options: []),
         let jsonString = String(data: jsonData, encoding: .utf8) {
        UserDefaults(suiteName: "group.com.yba.EzanVaktiLite")?.set(jsonString, forKey: "prayerData")
      }
      // Tell WidgetKit to refresh all widget timelines
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(nil)
    }
    print("[SceneDelegate] widget channel başarıyla kuruldu")

    // Live Activity channel (iOS 16.2+)
    let laChannel = FlutterMethodChannel(
      name: "com.yba.ezanvakti/liveactivity",
      binaryMessenger: flutterVC.binaryMessenger
    )
    laChannel.setMethodCallHandler { call, result in
      if #available(iOS 16.2, *) {
        PrayerLiveActivityHandler.shared.handle(call, result: result)
      } else {
        result(nil)
      }
    }
    print("[SceneDelegate] liveactivity channel başarıyla kuruldu")

    // Mosque finder channel (MKLocalSearch — no API key needed)
    let mosqueChannel = FlutterMethodChannel(
      name: "com.yba.ezanvakti/mosque_finder",
      binaryMessenger: flutterVC.binaryMessenger
    )
    mosqueFinderHandler = MosqueFinderHandler()
    mosqueChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "findNearby",
            let args = call.arguments as? [String: Any],
            let lat = args["lat"] as? Double,
            let lng = args["lng"] as? Double else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.mosqueFinderHandler?.findNearby(lat: lat, lng: lng, result: result)
    }
    print("[SceneDelegate] mosque_finder channel başarıyla kuruldu")
  }
}
