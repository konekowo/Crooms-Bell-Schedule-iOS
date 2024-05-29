//
//  bellschedWidgetLiveActivity.swift
//  bellschedWidget
//
//  Created by Suvan Mangamuri on 5/27/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct bellschedWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct bellschedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: bellschedWidgetAttributes.self) { context in
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

extension bellschedWidgetAttributes {
    fileprivate static var preview: bellschedWidgetAttributes {
        bellschedWidgetAttributes(name: "World")
    }
}

extension bellschedWidgetAttributes.ContentState {
    fileprivate static var smiley: bellschedWidgetAttributes.ContentState {
        bellschedWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: bellschedWidgetAttributes.ContentState {
         bellschedWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: bellschedWidgetAttributes.preview) {
   bellschedWidgetLiveActivity()
} contentStates: {
    bellschedWidgetAttributes.ContentState.smiley
    bellschedWidgetAttributes.ContentState.starEyes
}
