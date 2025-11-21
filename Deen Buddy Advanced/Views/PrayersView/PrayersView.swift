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
                ToolbarItem(placement: .topBarLeading) {
                    Text(AppStrings.prayers.myPrayers)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(Madhab.allCases, id: \.self) { madhab in
                            Button(action: {
                                vm.selectedMadhab = madhab
                            }) {
                                HStack {
                                    Text(madhab.displayName)
                                    if vm.selectedMadhab == madhab {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(vm.selectedMadhab.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.primary.opacity(0.6))
                    }
                }
            }
        }
        .onAppear { vm.recomputeWeekStreak() }
    }
}

#Preview {
    PrayersView()
}
