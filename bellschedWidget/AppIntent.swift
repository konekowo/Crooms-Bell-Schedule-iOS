//
//  AppIntent.swift
//  bellsched
//
//  Created by Suvan Mangamuri on 5/28/24.
//

import Foundation
import AppIntents
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Crooms Bell Schedule App"
    static var description = IntentDescription("The widget for the Crooms Bell Schedule App.")

    
    @Parameter(title: "A Lunch", default: true)
    var aLunch: Bool
    
    

}
