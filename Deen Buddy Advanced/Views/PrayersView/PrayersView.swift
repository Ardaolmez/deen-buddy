// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MinimalDesign.extraLargeSpacing) {
                    // MARK: Weekly Progress
               //    WeekProgress(weekStatus: vm.streakWeekStatus)
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
                    // MARK: Next Prayer Focus
                    NextPrayerHeader(
                        nextPrayer: vm.nextPrayer,
                        currentPrayer: vm.currentPrayer,
                        countdown: vm.countdownText,
                        isBetweenSunriseAndDhuhr: vm.isBetweenSunriseAndDhuhr
                    )
                }
                .padding(.horizontal, MinimalDesign.mediumSpacing)
                .padding(.vertical, MinimalDesign.mediumSpacing)
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

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.prayers.history) {
                        openRecords = true
                    }
                    .font(.system(.body))
                    .foregroundStyle(AppColors.Common.secondary)
                }
            }
        }
        .onAppear { vm.recomputeWeekStreak() }
    }
}

#Preview {
    PrayersView()
}
