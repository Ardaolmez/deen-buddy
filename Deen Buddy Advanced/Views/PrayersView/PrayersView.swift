// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.01) {
                    // MARK: Prayer Icons Row - 25%
                    PrayerIconsRow(
                        entries: vm.entries,
                        currentPrayer: vm.currentPrayer,
                        nextPrayer: vm.nextPrayer,
                        countdown: vm.countdownText,
                        isCompleted: { vm.isCompleted($0) },
                        canToggle: { vm.canMark($0) },
                        onToggle: { prayer in
                            vm.toggleCompleted(prayer)
                            vm.recomputeWeekStreak()
                        }
                    )
                    .frame(height: geometry.size.height * 0.22)

                    // MARK: Qibla Header - 5%
                    QiblaHeader(cityLine: vm.cityLine)
                        .frame(height: geometry.size.height * 0.05)

                    // MARK: Qibla Compass - 68%
                    ArrowQiblaCompassView()
                        .frame(height: geometry.size.height * 0.68)
                }
                .padding(.horizontal, geometry.size.width * 0.04)
                .padding(.top, geometry.size.height * 0.015)
            }
            .background(CreamyPapyrusBackground())
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $openRecords) {
                PrayerRecordsView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(AppStrings.prayers.myPrayers)
                        .font(.system(.title2, weight: .bold))
                }

                 //   ToolbarItem(placement: .navigationBarTrailing) {
                 //     Button(AppStrings.prayers.history) {
                 //       openRecords = true
                 //   }
                 //   .font(.system(.body))
                 //  .foregroundStyle(AppColors.Common.secondary)
                 // }
            }
        }
        .onAppear { vm.recomputeWeekStreak() }
    }
}

#Preview {
    PrayersView()
}
