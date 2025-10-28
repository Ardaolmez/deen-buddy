// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.015) {
                    // MARK: Prayer Icons Row
                    PrayerIconsRow(
                        entries: vm.entries,
                        currentPrayer: vm.currentPrayer,
                        isCompleted: { vm.isCompleted($0) },
                        canToggle: { vm.canMark($0) },
                        onToggle: { prayer in
                            vm.toggleCompleted(prayer)
                            vm.recomputeWeekStreak()
                        }
                    )
                    .frame(height: geometry.size.height * 0.12)

                    // Additional spacer to push current prayer section lower
                    Spacer()
                        .frame(height: geometry.size.height * 0.025)

                    // MARK: Next Prayer Focus
                   // NextPrayerHeader(
                   // nextPrayer: vm.nextPrayer,
                   // currentPrayer: vm.currentPrayer,
                   // countdown: vm.countdownText,
                   // isBetweenSunriseAndDhuhr: vm.isBetweenSunriseAndDhuhr
                   // )
                   //.frame(height: geometry.size.height * 0.2)

                    // MARK: Qibla Compass
                    ArrowQiblaCompassView()
                        .frame(height: geometry.size.height * 0.68)
                }
                .padding(.horizontal, geometry.size.width * 0.04)
                .padding(.top, geometry.size.height * 0.03)
            }
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
