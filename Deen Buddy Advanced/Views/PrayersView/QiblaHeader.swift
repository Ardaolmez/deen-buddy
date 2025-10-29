// Views/PrayersView/QiblaHeader.swift
import SwiftUI

struct QiblaHeader: View {
    let cityLine: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Qibla icon and title
            HStack(spacing: 6) {
                Image(systemName: "location.north.circle.fill")
                    .font(.title3)
                    .foregroundColor(AppColors.Prayers.prayerGreen)

                Text(ArrowQiblaStrings.qiblaDirection)
                    .font(.headline.weight(.medium))
                    .foregroundColor(AppColors.Common.primary)
            }
            
            Spacer()
            
            // Location context (optional, only if different from prayer info)
            if !cityLine.isEmpty && cityLine != AppStrings.prayers.locating {
                Text(extractCity(from: cityLine))
                    .font(.caption)
                    .foregroundColor(AppColors.Common.secondary)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // Helper function to extract city from cityLine
    private func extractCity(from cityLine: String) -> String {
        // Extract city name from format like "New York, NY, USA"
        let components = cityLine.components(separatedBy: ", ")
        return components.first ?? cityLine
    }
}

#Preview {
    VStack(spacing: 20) {
        QiblaHeader(cityLine: "New York, NY, USA")
        QiblaHeader(cityLine: "London, UK")
        QiblaHeader(cityLine: AppStrings.prayers.locating)
        QiblaHeader(cityLine: "")
    }
    .padding()
}
