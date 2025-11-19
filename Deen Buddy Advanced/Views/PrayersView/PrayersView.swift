// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Creamy Papyrus Background
                CreamyPapyrusBackground()

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)

                        // MARK: Madhab Selector
                        MadhabSelector(selectedMadhab: $vm.selectedMadhab)

                        Spacer()
                            .frame(height: 16)

                        // MARK: Prayer Icons Row
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

                        Spacer()
                            .frame(height: 20)

                        // MARK: Qibla Header
                        QiblaHeader(cityLine: vm.cityLine)
                        // MARK: Qibla Compass
                        ArrowQiblaCompassView()
                            .frame(height: 500)
                    }
                    .padding(.horizontal)
                }
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
            }
        }
        .onAppear { vm.recomputeWeekStreak() }
    }
}

#Preview {
    PrayersView()
}
