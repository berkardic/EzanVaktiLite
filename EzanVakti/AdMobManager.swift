import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Combine

// MARK: - AdMob Manager
class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()
    
    @Published var isInitialized = false
    @Published var trackingAuthorized = false
    
    // TEST ID'leri - Canlıya geçerken değiştirin!
    private let bannerAdUnitID = "ca-app-pub-7016816375186028/5975263554" 
    
    private override init() {
        super.init()
    }
    
    /// AdMob'u başlat
    func initialize() {
        guard !isInitialized else { return }
        
        GADMobileAds.sharedInstance().start { [weak self] (initializationStatus: GADInitializationStatus) in
            DispatchQueue.main.async {
                self?.isInitialized = true
                print("✅ AdMob initialized")
            }
        }
    }
    
    /// ATT (App Tracking Transparency) izni iste
    @MainActor
    func requestTrackingPermission() async {
        // iOS 14.5+ için ATT izni
        if #available(iOS 14.5, *) {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            trackingAuthorized = (status == .authorized)
            
            print("📊 Tracking Permission: \(status.rawValue)")
            print("📊 IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
        } else {
            // iOS 14.5 öncesi - izin gerekmiyor
            trackingAuthorized = true
        }
    }
    
    func getBannerAdUnitID() -> String {
        return bannerAdUnitID
    }
}

// MARK: - Banner Ad View (SwiftUI)
struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    
    init(adUnitID: String = AdMobManager.shared.getBannerAdUnitID()) {
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = getRootViewController()
        banner.delegate = context.coordinator
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if uiView.adUnitID != nil {
            let request = GADRequest()
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("✅ Banner ad loaded")
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed: \(error.localizedDescription)")
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return scene.windows.first?.rootViewController
    }
}

// MARK: - Banner Container (Alt kısım için)
struct BannerAdContainer: View {
    @StateObject private var adManager = AdMobManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if adManager.isInitialized {
                AdBannerView()
                    .frame(height: 50)
                    .background(Color(white: 0.95))
            } else {
                // AdMob yüklenene kadar placeholder
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 50)
            }
        }
    }
}
