import SwiftUI

struct CityDistrictPickerView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var step: Step = .city
    @State private var searchCity = ""
    @State private var searchDistrict = ""

    enum Step { case city, district }

    var filteredCities: [DiyanetCity] {
        let q = viewModel.normalize(searchCity)
        guard !q.isEmpty else { return viewModel.cities }
        return viewModel.cities.filter {
            viewModel.normalize($0.sehirAdi).contains(q)
        }
    }

    var filteredDistricts: [DiyanetDistrict] {
        let q = viewModel.normalize(searchDistrict)
        guard !q.isEmpty else { return viewModel.districts }
        return viewModel.districts.filter {
            viewModel.normalize($0.ilceAdi).contains(q)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.06, green: 0.13, blue: 0.27).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Adım göstergesi
                    HStack(spacing: 0) {
                        stepCircle(num: "1", label: "İl", active: true)
                        Rectangle()
                            .fill(step == .district
                                  ? Color(red: 1.0, green: 0.85, blue: 0.4)
                                  : Color.white.opacity(0.2))
                            .frame(height: 2).frame(maxWidth: .infinity)
                            .padding(.bottom, 18)
                        stepCircle(num: "2", label: "İlçe", active: step == .district)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)

                    if step == .city {
                        cityListView
                    } else {
                        districtListView
                    }
                }
            }
            .navigationTitle(step == .city
                ? (viewModel.language == "tr" ? "İl Seç" : "Select Province")
                : (viewModel.language == "tr" ? "İlçe Seç" : "Select District"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if step == .district {
                        Button {
                            withAnimation { step = .city }
                            searchDistrict = ""
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text(viewModel.language == "tr" ? "İller" : "Back")
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.language == "tr" ? "Kapat" : "Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - İl Listesi
    var cityListView: some View {
        VStack(spacing: 0) {
            searchField($searchCity, placeholder: viewModel.language == "tr" ? "İl ara..." : "Search...")

            if viewModel.isLoadingCities {
                Spacer()
                VStack(spacing: 12) {
                    ProgressView().tint(Color(red: 1.0, green: 0.85, blue: 0.4)).scaleEffect(1.3)
                    Text(viewModel.language == "tr" ? "İller yükleniyor..." : "Loading...")
                        .foregroundColor(.white.opacity(0.7)).font(.subheadline)
                }
                Spacer()
            } else if viewModel.cities.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash").font(.largeTitle).foregroundColor(.white.opacity(0.4))
                    Text(viewModel.language == "tr" ? "Şehirler yüklenemedi" : "Could not load cities")
                        .foregroundColor(.white.opacity(0.7))
                    Button {
                        Task { await viewModel.loadCitiesAndRestore() }
                    } label: {
                        Text(viewModel.language == "tr" ? "Tekrar Dene" : "Retry")
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                            .cornerRadius(12).foregroundColor(.white)
                    }
                }
                Spacer()
            } else {
                List(filteredCities) { city in
                    Button {
                        Task {
                            await viewModel.selectCity(city)
                            withAnimation { step = .district }
                            searchCity = ""
                        }
                    } label: {
                        HStack {
                            Text(viewModel.language == "tr" ? city.sehirAdi : city.sehirAdiEn)
                                .foregroundColor(.white)
                            Spacer()
                            if city.id == viewModel.selectedCity?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))
                    .listRowSeparatorTint(Color.white.opacity(0.1))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - İlçe Listesi
    var districtListView: some View {
        VStack(spacing: 0) {
            searchField($searchDistrict, placeholder: viewModel.language == "tr" ? "İlçe ara..." : "Search...")

            if viewModel.isLoadingDistricts {
                Spacer()
                VStack(spacing: 12) {
                    ProgressView().tint(Color(red: 1.0, green: 0.85, blue: 0.4)).scaleEffect(1.3)
                    Text(viewModel.language == "tr" ? "İlçeler yükleniyor..." : "Loading...")
                        .foregroundColor(.white.opacity(0.7)).font(.subheadline)
                }
                Spacer()
            } else if viewModel.districts.isEmpty {
                Spacer()
                Text(viewModel.language == "tr" ? "İlçe bulunamadı" : "No districts found")
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            } else {
                List(filteredDistricts) { district in
                    Button {
                        Task {
                            await viewModel.selectDistrict(district)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text(viewModel.language == "tr" ? district.ilceAdi : district.ilceAdiEn)
                                .foregroundColor(.white)
                            Spacer()
                            if district.id == viewModel.selectedDistrict?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))
                    .listRowSeparatorTint(Color.white.opacity(0.1))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Yardımcı bileşenler
    func searchField(_ text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.5))
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    func stepCircle(num: String, label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(active ? Color(red: 0.18, green: 0.52, blue: 0.34) : Color.white.opacity(0.15))
                    .frame(width: 30, height: 30)
                Text(num).font(.caption.bold()).foregroundColor(.white)
            }
            Text(label).font(.caption2).foregroundColor(.white.opacity(0.6))
        }
    }
}
