//
//  Deen_Buddy_WidgetsLiveActivity.swift
//  Deen Buddy Widgets
//
//  Created by Arda Olmez on 2025-10-18.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Deen_Buddy_WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Deen_Buddy_WidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Deen_Buddy_WidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Deen_Buddy_WidgetsAttributes {
    fileprivate static var preview: Deen_Buddy_WidgetsAttributes {
        Deen_Buddy_WidgetsAttributes(name: "World")
    }
}

extension Deen_Buddy_WidgetsAttributes.ContentState {
    fileprivate static var smiley: Deen_Buddy_WidgetsAttributes.ContentState {
        Deen_Buddy_WidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Deen_Buddy_WidgetsAttributes.ContentState {
         Deen_Buddy_WidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Deen_Buddy_WidgetsAttributes.preview) {
   Deen_Buddy_WidgetsLiveActivity()
} contentStates: {
    Deen_Buddy_WidgetsAttributes.ContentState.smiley
    Deen_Buddy_WidgetsAttributes.ContentState.starEyes
}
