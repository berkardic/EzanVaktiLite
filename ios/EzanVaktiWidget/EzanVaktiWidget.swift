import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - App Group identifier
private let appGroup = "group.com.yba.EzanVaktiLite"

// MARK: - Data model

struct PrayerItem {
    let key: String
    let name: String
    let time: String
}

struct PrayerData {
    let city: String
    let district: String
    let date: String
    let items: [PrayerItem]
    let tomorrowImsakTime: String
    let tomorrowDate: String

    static let empty = PrayerData(
        city: "", district: "", date: "",
        items: [
            PrayerItem(key: "imsak",  name: "İmsak",  time: "--:--"),
            PrayerItem(key: "gunes",  name: "Güneş",  time: "--:--"),
            PrayerItem(key: "ogle",   name: "Öğle",   time: "--:--"),
            PrayerItem(key: "ikindi", name: "İkindi", time: "--:--"),
            PrayerItem(key: "aksam",  name: "Akşam",  time: "--:--"),
            PrayerItem(key: "yatsi",  name: "Yatsı",  time: "--:--"),
        ],
        tomorrowImsakTime: "",
        tomorrowDate: ""
    )

    private func prayerDate(_ timeStr: String, on now: Date) -> Date? {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        let parts = timeStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        comps.hour = parts[0]; comps.minute = parts[1]; comps.second = 0
        return cal.date(from: comps)
    }

    func nextPrayer(from now: Date) -> (item: PrayerItem, date: Date)? {
        for item in items {
            if let d = prayerDate(item.time, on: now), d > now { return (item, d) }
        }
        return nil
    }

    func remainingItems(from now: Date) -> [PrayerItem] {
        items.filter { item in
            guard let d = prayerDate(item.time, on: now) else { return false }
            return d > now
        }
    }

    func isPast(_ item: PrayerItem, now: Date) -> Bool {
        guard let d = prayerDate(item.time, on: now) else { return false }
        return d <= now
    }

    /// Returns the Date for tomorrow's İmsak, or nil if unavailable.
    func nextDayImsakDate(from now: Date) -> Date? {
        guard !tomorrowImsakTime.isEmpty && tomorrowImsakTime != "--:--" else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.day = (comps.day ?? 0) + 1
        let parts = tomorrowImsakTime.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        comps.hour = parts[0]; comps.minute = parts[1]; comps.second = 0
        return cal.date(from: comps)
    }
}

private func loadPrayerData() -> PrayerData {
    guard
        let defaults = UserDefaults(suiteName: appGroup),
        let json = defaults.string(forKey: "prayerData"),
        let data = json.data(using: .utf8),
        let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
    else { return .empty }

    return PrayerData(
        city:     dict["city"]     ?? "",
        district: dict["district"] ?? "",
        date:     dict["date"]     ?? "",
        items: [
            PrayerItem(key: "imsak",  name: "İmsak",  time: dict["imsak"]   ?? "--:--"),
            PrayerItem(key: "gunes",  name: "Güneş",  time: dict["gunes"]   ?? "--:--"),
            PrayerItem(key: "ogle",   name: "Öğle",   time: dict["ogle"]    ?? "--:--"),
            PrayerItem(key: "ikindi", name: "İkindi", time: dict["ikindi"]  ?? "--:--"),
            PrayerItem(key: "aksam",  name: "Akşam",  time: dict["aksam"]   ?? "--:--"),
            PrayerItem(key: "yatsi",  name: "Yatsı",  time: dict["yatsi"]   ?? "--:--"),
        ],
        tomorrowImsakTime: dict["tomorrowImsak"] ?? "",
        tomorrowDate:      dict["tomorrowDate"]  ?? ""
    )
}

// MARK: - Theme colours
private enum WC {
    static let bg     = Color(red: 0.05, green: 0.12, blue: 0.22)
    static let accent = Color(red: 1.00, green: 0.85, blue: 0.40)
    static let text   = Color.white
    static let muted  = Color(white: 0.65)
}

// MARK: - containerBackground compatibility (iOS 17 requires it)
private extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            background(color)
        }
    }
}

// MARK: - Timeline entry & provider

struct PrayerEntry: TimelineEntry {
    let date: Date
    let data: PrayerData
}

struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(PrayerEntry(date: Date(), data: loadPrayerData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let pd  = loadPrayerData()
        let now = Date()
        var entries = [PrayerEntry(date: now, data: pd)]

        let cal   = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        for item in pd.items {
            let parts = item.time.split(separator: ":").compactMap { Int($0) }
            guard parts.count == 2 else { continue }
            comps.hour = parts[0]; comps.minute = parts[1]; comps.second = 0
            if let d = cal.date(from: comps), d > now {
                entries.append(PrayerEntry(date: d, data: pd))
            }
        }

        let midnight = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now)!)
        completion(Timeline(entries: entries, policy: .after(midnight)))
    }
}

private func dateLabel(_ stored: String, fallback: Date) -> String {
    if !stored.isEmpty { return stored }
    let f = DateFormatter()
    f.locale = Locale(identifier: "tr_TR")
    f.dateFormat = "d MMM yyyy"
    return f.string(from: fallback)
}

// MARK: - Widget A: Remaining Prayers (systemSmall)

struct RemainingPrayersView: View {
    let entry: PrayerEntry

    var body: some View {
        let remaining = entry.data.remainingItems(from: entry.date)
        let nextKey   = entry.data.nextPrayer(from: entry.date)?.item.key ?? ""

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 10))
                    .foregroundColor(WC.accent)
                Text(dateLabel(entry.data.date, fallback: entry.date))
                    .font(.system(size: 14))
                    .foregroundColor(WC.muted)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            if remaining.isEmpty {
                let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) ?? entry.date
                if let tomorrowImsak = entry.data.nextDayImsakDate(from: entry.date) {
                    Spacer()
                    VStack(spacing: 4) {
                        Text(dateLabel("", fallback: tomorrowDate))
                            .font(.system(size: 12))
                            .foregroundColor(WC.muted)
                        HStack {
                            Text("İmsak")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(WC.accent)
                            Spacer()
                            Text(entry.data.tomorrowImsakTime)
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(WC.accent)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(WC.accent.opacity(0.14))
                        .cornerRadius(6)
                        Text(tomorrowImsak, style: .timer)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(WC.accent)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(WC.accent)
                        Text("Tüm namazlar\ntamamlandı")
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(WC.muted)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else {
                VStack(spacing: 2) {
                    ForEach(Array(remaining.prefix(5).enumerated()), id: \.offset) { _, item in
                        let isNext = item.key == nextKey
                        HStack {
                            Text(item.name)
                                .font(.system(size: isNext ? 18 : 17,
                                              weight: isNext ? .semibold : .regular))
                                .foregroundColor(isNext ? WC.accent : WC.text)
                            Spacer()
                            Text(item.time)
                                .font(.system(size: isNext ? 18 : 17,
                                              weight: isNext ? .semibold : .regular,
                                              design: .monospaced))
                                .foregroundColor(isNext ? WC.accent : WC.muted)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, isNext ? 3 : 1)
                        .background(isNext ? WC.accent.opacity(0.14) : Color.clear)
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 2)
                Spacer(minLength: 4)
            }
        }
        .widgetBackground(WC.bg)
    }
}

struct RemainingPrayersWidget: Widget {
    let kind = "RemainingPrayersWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            RemainingPrayersView(entry: entry)
        }
        .configurationDisplayName("Kalan Namazlar")
        .description("Bugün kalan namaz vakitlerini gösterir.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget B: All Prayer Times (systemMedium)

struct AllPrayerTimesView: View {
    let entry: PrayerEntry

    var body: some View {
        let next    = entry.data.nextPrayer(from: entry.date)
        let nextKey = next?.item.key ?? ""
        let loc     = entry.data.district.isEmpty ? entry.data.city : entry.data.district

        HStack(spacing: 0) {
            // Left: prayer list
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(entry.data.items.enumerated()), id: \.offset) { _, item in
                    let isNext = item.key == nextKey
                    let isPast = entry.data.isPast(item, now: entry.date)
                    HStack {
                        Text(item.name)
                            .font(.system(size: 16, weight: isNext ? .semibold : .regular))
                            .foregroundColor(
                                isNext ? WC.accent : (isPast ? WC.muted.opacity(0.5) : WC.text))
                        Spacer()
                        Text(item.time)
                            .font(.system(size: 16,
                                          weight: isNext ? .semibold : .regular,
                                          design: .monospaced))
                            .foregroundColor(
                                isNext ? WC.accent : (isPast ? WC.muted.opacity(0.5) : WC.muted))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(isNext ? WC.accent.opacity(0.12) : Color.clear)
                    .cornerRadius(5)
                }
            }
            .padding(.leading, 4)
            .padding(.vertical, 10)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
                .padding(.vertical, 14)

            // Right: location, date, countdown
            VStack(spacing: 6) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18))
                    .foregroundColor(WC.accent)
                if !loc.isEmpty {
                    Text(loc)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(WC.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                Text(dateLabel(entry.data.date, fallback: entry.date))
                    .font(.system(size: 14))
                    .foregroundColor(WC.muted)
                if let n = next {
                    VStack(spacing: 2) {
                        Text(n.item.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(WC.accent)
                        Text(n.date, style: .timer)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(WC.accent)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 5)
                    .background(WC.accent.opacity(0.10))
                    .cornerRadius(8)
                } else {
                    Text("Tüm\nvakitler\ngeçti")
                        .font(.system(size: 12))
                        .foregroundColor(WC.muted)
                        .multilineTextAlignment(.center)
                }
                Spacer(minLength: 0)
            }
            .frame(width: 104)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
        .widgetBackground(WC.bg)
    }
}

struct AllPrayerTimesWidget: Widget {
    let kind = "AllPrayerTimesWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            AllPrayerTimesView(entry: entry)
        }
        .configurationDisplayName("Tüm Namaz Vakitleri")
        .description("Tüm vakitler, konum ve geri sayım gösterir.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget C: Countdown Only (systemSmall)

struct CountdownView: View {
    let entry: PrayerEntry

    var body: some View {
        let next = entry.data.nextPrayer(from: entry.date)

        VStack(spacing: 6) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 20))
                .foregroundColor(WC.accent)
            if let n = next {
                Text(n.item.name)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(WC.text)
                Text(n.item.time)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(WC.muted)
                Text("Kalan")
                    .font(.system(size: 13))
                    .foregroundColor(WC.muted)
                Text(n.date, style: .timer)
                    .font(.system(size: 29, weight: .bold, design: .monospaced))
                    .foregroundColor(WC.accent)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
            } else if let tomorrowImsak = entry.data.nextDayImsakDate(from: entry.date) {
                let tomorrowDay = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) ?? entry.date
                Text(dateLabel("", fallback: tomorrowDay))
                    .font(.system(size: 12))
                    .foregroundColor(WC.muted)
                Text("İmsak")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(WC.text)
                Text(entry.data.tomorrowImsakTime)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(WC.muted)
                Text("Kalan")
                    .font(.system(size: 13))
                    .foregroundColor(WC.muted)
                Text(tomorrowImsak, style: .timer)
                    .font(.system(size: 29, weight: .bold, design: .monospaced))
                    .foregroundColor(WC.accent)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
            } else {
                Text("Tüm namazlar\ntamamlandı")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(WC.muted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(10)
        .widgetBackground(WC.bg)
    }
}

struct CountdownWidget: Widget {
    let kind = "CountdownWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            CountdownView(entry: entry)
        }
        .configurationDisplayName("Namaz Sayacı")
        .description("Sonraki namaz vaktine kalan süreyi gösterir.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Lock Screen Widgets (iOS 16+)

struct LockScreenRectangularView: View {
    let entry: PrayerEntry

    var body: some View {
        let now = entry.date
        if let next = entry.data.nextPrayer(from: now) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 11))
                    Text(entry.data.district.isEmpty ? entry.data.city : entry.data.district)
                        .font(.system(size: 11))
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(next.item.name)
                        .font(.system(size: 15, weight: .semibold))
                    Text(next.item.time)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text(next.date, style: .timer)
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if let tomorrowImsak = entry.data.nextDayImsakDate(from: now) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 11))
                    Text("İmsak")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
                Text(tomorrowImsak, style: .timer)
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("Tüm namazlar\ntamamlandı")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

// .accessoryCircular — saat yanındaki yuvarlak widget
struct LockScreenCircularView: View {
    let entry: PrayerEntry

    var body: some View {
        let now = entry.date
        if let next = entry.data.nextPrayer(from: now) {
            VStack(spacing: 1) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 11))
                Text(next.item.name)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(next.date, style: .timer)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
            }
            .multilineTextAlignment(.center)
        } else {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
        }
    }
}

// .accessoryInline — saat üstü tek satır
struct LockScreenInlineView: View {
    let entry: PrayerEntry

    var body: some View {
        let now = entry.date
        if let next = entry.data.nextPrayer(from: now) {
            Label {
                Text("\(next.item.name) \(next.item.time)")
            } icon: {
                Image(systemName: "moon.stars.fill")
            }
        } else {
            Label("Tamamlandı", systemImage: "checkmark")
        }
    }
}

struct LockScreenWidgetEntryView: View {
    let entry: PrayerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
                .widgetBackground(.clear)
        case .accessoryInline:
            LockScreenInlineView(entry: entry)
                .widgetBackground(.clear)
        default:
            LockScreenRectangularView(entry: entry)
                .widgetBackground(.clear)
        }
    }
}

struct LockScreenWidget: Widget {
    let kind = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Namaz Vakti")
        .description("Sonraki namaza kalan süreyi kilit ekranında gösterir.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Live Activity (iOS 16.2+)

struct PrayerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var nextPrayerName: String
        var nextPrayerDate: Date
        var districtName: String
    }
}

struct PrayerLockScreenView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 26))
                .foregroundColor(WC.accent)

            VStack(alignment: .leading, spacing: 3) {
                Text(context.state.districtName)
                    .font(.system(size: 11))
                    .foregroundColor(WC.muted)
                Text(context.state.nextPrayerName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(WC.text)
                Text("kalan")
                    .font(.system(size: 11))
                    .foregroundColor(WC.muted)
            }

            Spacer()

            Text(context.state.nextPrayerDate, style: .timer)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(WC.accent)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(WC.bg)
    }
}

struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            PrayerLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(WC.accent)
                        Text(context.state.nextPrayerName)
                            .font(.headline)
                            .foregroundColor(WC.text)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.nextPrayerDate, style: .timer)
                        .font(.system(.title3, design: .monospaced).bold())
                        .foregroundColor(WC.accent)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.districtName)
                        .font(.caption)
                        .foregroundColor(WC.muted)
                }
            } compactLeading: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(WC.accent)
                    .font(.system(size: 13))
            } compactTrailing: {
                Text(context.state.nextPrayerDate, style: .timer)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(WC.accent)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(WC.accent)
            }
        }
    }
}

// MARK: - Widget Bundle

@main
struct EzanVaktiWidgetBundle: WidgetBundle {
    var body: some Widget {
        RemainingPrayersWidget()
        AllPrayerTimesWidget()
        CountdownWidget()
        LockScreenWidget()
        PrayerLiveActivity()
    }
}
