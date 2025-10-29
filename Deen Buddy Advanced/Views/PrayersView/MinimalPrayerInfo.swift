// Views/PrayersView/MinimalPrayerInfo.swift
import SwiftUI

struct MinimalPrayerInfo: View {
    let currentPrayer: PrayerEntry?
    let nextPrayer: PrayerEntry?
    let countdown: String
    let cityLine: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Current prayer indicator
            if let current = currentPrayer {
                HStack(spacing: 4) {
                    Image(systemName: current.name.icon)
                        .font(.caption)
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                    Text("Now: \(current.name.title)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                }
            }
            
            if currentPrayer != nil && nextPrayer != nil {
                Text("•")
                    .font(.caption)
                    .foregroundColor(AppColors.Common.secondary)
            }
            
            // Next prayer with countdown
            if let next = nextPrayer {
                HStack(spacing: 4) {
                    Text("Next: \(next.name.title)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.Common.primary)
                    
                    if !countdown.isEmpty && countdown != "—" && countdown != "--:--:--" {
                        Text("in \(countdown)")
                            .font(.caption.monospaced())
                            .foregroundColor(AppColors.Prayers.prayerBlue)
                    }
                }
            }
            
            Spacer()
            
            // Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(AppColors.Common.secondary)
                Text(extractCity(from: cityLine))
                    .font(.caption)
                    .foregroundColor(AppColors.Common.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.6))
        )
    }
    
    // Helper function to extract city from cityLine
    private func extractCity(from cityLine: String) -> String {
        // Extract city name from format like "New York, NY, USA" or "Locating..."
        if cityLine == AppStrings.prayers.locating {
            return "Locating..."
        }
        
        let components = cityLine.components(separatedBy: ", ")
        return components.first ?? cityLine
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview with current and next prayer
        MinimalPrayerInfo(
            currentPrayer: PrayerEntry(name: .fajr, time: Date()),
            nextPrayer: PrayerEntry(name: .dhuhr, time: Date().addingTimeInterval(3600 * 2.5)),
            countdown: "2:30:15",
            cityLine: "New York, NY, USA"
        )
        
        // Preview with only next prayer
        MinimalPrayerInfo(
            currentPrayer: nil,
            nextPrayer: PrayerEntry(name: .asr, time: Date().addingTimeInterval(3600 * 4)),
            countdown: "4:15:30",
            cityLine: "London, UK"
        )
        
        // Preview with locating
        MinimalPrayerInfo(
            currentPrayer: nil,
            nextPrayer: PrayerEntry(name: .maghrib, time: Date().addingTimeInterval(3600)),
            countdown: "1:05:45",
            cityLine: AppStrings.prayers.locating
        )
    }
    .padding()
}
