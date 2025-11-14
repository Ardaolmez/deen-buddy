//
//  DailyActivitiesSection.swift
//  Deen Buddy Advanced
//
//  Section displaying all daily activities (Verse, Durood, Dua)
//

import SwiftUI

struct DailyActivitiesSection: View {
    @ObservedObject var dailyProgressVM: DailyProgressViewModel
    let onActivitySelected: (DailyActivityContent) -> Void
    @Binding var expandedActivity: DailyActivityType?

    var body: some View {
        VStack(spacing: 16) {
            // Daily Verse
            if let verse = dailyProgressVM.dailyVerse {
                activityCard(for: verse, type: .verse)
            }

            // Daily Durood
            if let durood = dailyProgressVM.dailyDurood {
                activityCard(for: durood, type: .durood)
            }

            // Daily Dua
            if let dua = dailyProgressVM.dailyDua {
                activityCard(for: dua, type: .dua)
            }

            // Daily Wisdom
            if let wisdom = dailyProgressVM.dailyWisdom {
                wisdomCard(for: wisdom)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Reusable Activity Card Builder

    @ViewBuilder
    private func activityCard(for activity: DailyActivityContent, type: DailyActivityType) -> some View {
        SimpleDailyActivityCard(
            activity: activity,
            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(type),
            onMarkComplete: {
                // Only allow marking complete if it's today
                if dailyProgressVM.isSelectedDateToday() {
                    dailyProgressVM.markActivityComplete(type)
                }
            },
            onShowDetail: {
                onActivitySelected(activity)
            },
            isExpanded: Binding(
                get: { expandedActivity == type },
                set: { isExpanded in
                    // Set to this type if expanded, nil if collapsed
                    expandedActivity = isExpanded ? type : nil
                }
            )
        )
    }

    @ViewBuilder
    private func wisdomCard(for wisdom: DailyActivityContent) -> some View {
        WisdomActivityCard(
            activity: wisdom,
            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(.wisdom),
            onMarkComplete: {
                // Only allow marking complete if it's today
                if dailyProgressVM.isSelectedDateToday() {
                    dailyProgressVM.markActivityComplete(.wisdom)
                }
            },
            onShowDetail: {
                onActivitySelected(wisdom)
            },
            isExpanded: Binding(
                get: { expandedActivity == .wisdom },
                set: { isExpanded in
                    // Set to wisdom if expanded, nil if collapsed
                    expandedActivity = isExpanded ? .wisdom : nil
                }
            )
        )
    }
}
