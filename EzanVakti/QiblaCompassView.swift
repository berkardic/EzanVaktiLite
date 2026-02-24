import SwiftUI
import CoreLocation
import Combine

// MARK: - Kıble Pusulası View
struct QiblaCompassView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @StateObject private var compassManager = CompassManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.12, blue: 0.25),
                    Color(red: 0.08, green: 0.18, blue: 0.38),
                    Color(red: 0.12, green: 0.22, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Başlık
                VStack(spacing: 8) {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    
                    Text(viewModel.language == "tr" ? "Kıble Pusulası" : "Qibla Compass")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if let city = viewModel.selectedCity, let district = viewModel.selectedDistrict {
                        Text("\(viewModel.language == "tr" ? city.sehirAdi : city.sehirAdiEn) / \(viewModel.language == "tr" ? district.ilceAdi : district.ilceAdiEn)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Pusula (2 KATMAN - Bağımsız)
                ZStack {
                    // KATMAN 1: Dönen pusula arka planı
                    CompassRoseBackground(heading: compassManager.heading)
                        .frame(width: 300, height: 300)
                    
                    // KATMAN 2: SABİT Kıble oku (pusuladan bağımsız)
                    QiblaArrowFixed(
                        heading: compassManager.heading,
                        qiblaDirection: compassManager.qiblaDirection,
                        language: viewModel.language
                    )
                    .frame(width: 300, height: 300)
                }
                .frame(width: 300, height: 300)
                
                // Derece bilgisi
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text(viewModel.language == "tr" ? "Yön" : "Direction")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text(compassManager.cardinalDirection)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .frame(height: 40)
                            .background(Color.white.opacity(0.3))
                        
                        VStack(spacing: 4) {
                            Text(viewModel.language == "tr" ? "Kıble" : "Qibla")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text(String(format: "%.0f°", compassManager.qiblaDirection))
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                }
                
                // Uyarı mesajları
                if !compassManager.isAuthorized {
                    WarningCard(
                        icon: "location.slash",
                        message: viewModel.language == "tr" 
                            ? "Konum izni gerekli. Lütfen ayarlardan konum iznini açın."
                            : "Location permission required. Please enable location in settings.",
                        language: viewModel.language
                    )
                } else if !compassManager.location.isValid {
                    WarningCard(
                        icon: "location.circle",
                        message: viewModel.language == "tr"
                            ? "Konum alınıyor..."
                            : "Getting location...",
                        language: viewModel.language,
                        isLoading: true
                    )
                }
                
                Spacer()
                
                // Kapat butonu
                Button {
                    dismiss()
                } label: {
                    Text(viewModel.language == "tr" ? "Kapat" : "Close")
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            compassManager.startUpdating(locationManager: viewModel.locationManager)
        }
        .onDisappear {
            compassManager.stopUpdating()
        }
    }
}

// MARK: - Uyarı Kartı
struct WarningCard: View {
    let icon: String
    let message: String
    let language: String
    var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: icon)
                    .font(.title2)
            }
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.3))
        .cornerRadius(12)
        .padding(.horizontal, 30)
    }
}

// MARK: - Pusula Manager
class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0
    @Published var qiblaDirection: Double = 0
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var isAuthorized = false
    
    private let locationManager = CLLocationManager()
    
    var cardinalDirection: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((heading + 22.5) / 45) % 8
        return directions[index]
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
    }
    
    func startUpdating(locationManager viewModelLocationManager: LocationManager) {
        isAuthorized = viewModelLocationManager.isAuthorized
        
        if isAuthorized {
            viewModelLocationManager.requestCurrentLocation { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let loc):
                    DispatchQueue.main.async {
                        self.location = loc.coordinate
                        self.calculateQiblaDirection()
                        self.locationManager.startUpdatingHeading()
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else { return }
        let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        DispatchQueue.main.async { [weak self] in
            self?.heading = heading
        }
    }
    
    func calculateQiblaDirection() {
        let kaaba = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        let lat1 = location.latitude * .pi / 180
        let lon1 = location.longitude * .pi / 180
        let lat2 = kaaba.latitude * .pi / 180
        let lon2 = kaaba.longitude * .pi / 180
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        qiblaDirection = bearing
    }
}

// Extension: Konum geçerli mi?
extension CLLocationCoordinate2D {
    var isValid: Bool {
        latitude != 0 || longitude != 0
    }
}
// MARK: - KATMAN 1: Dönen Pusula Arka Planı
struct CompassRoseBackground: View {
    let heading: Double
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.2), lineWidth: 2)
            Circle().fill(RadialGradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.5), Color.clear], center: .center, startRadius: 0, endRadius: 150))
            
            ForEach(["N", "E", "S", "W"], id: \.self) { direction in
                VStack {
                    Text(direction)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(direction == "N" ? Color(red: 1.0, green: 0.85, blue: 0.4) : .white.opacity(0.7))
                    Spacer()
                }
                .frame(height: 130)
                .rotationEffect(.degrees(-angleForDirection(direction)))
                .offset(y: -130)
                .rotationEffect(.degrees(angleForDirection(direction)))
            }
            
            ForEach(0..<36) { i in
                let angle = Double(i) * 10
                if angle.truncatingRemainder(dividingBy: 90) != 0 {
                    Rectangle()
                        .fill(angle.truncatingRemainder(dividingBy: 30) == 0 ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
                        .frame(width: 2, height: angle.truncatingRemainder(dividingBy: 30) == 0 ? 15 : 8)
                        .offset(y: -140)
                        .rotationEffect(.degrees(angle))
                }
            }
            
            VStack(spacing: 4) {
                Image(systemName: "building.2.fill").font(.system(size: 24)).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                Text("KABE").font(.caption2.bold()).foregroundColor(.white.opacity(0.8))
            }
        }
        .rotationEffect(.degrees(-heading))
        .animation(.easeInOut(duration: 0.3), value: heading)
    }
    
    func angleForDirection(_ direction: String) -> Double {
        switch direction {
        case "N": return 0
        case "E": return 90
        case "S": return 180
        case "W": return 270
        default: return 0
        }
    }
}

// MARK: - KATMAN 2: SABİT Kıble Oku
struct QiblaArrowFixed: View {
    let heading: Double
    let qiblaDirection: Double
    let language: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                .shadow(color: Color(red: 0.4, green: 0.8, blue: 0.6).opacity(0.6), radius: 15)
            Text(language == "tr" ? "KİBLE" : "QIBLA")
                .font(.caption2.bold())
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                .shadow(color: Color.black.opacity(0.5), radius: 2)
        }
        .offset(y: -90)
        .rotationEffect(.degrees(qiblaDirection - heading))
        .animation(.easeInOut(duration: 0.3), value: heading)
    }
}

