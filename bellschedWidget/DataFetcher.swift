//
//  DataFetcher.swift
//  bellsched
//
//  Created by Suvan Mangamuri on 5/28/24.
//

import Foundation


struct DayType: Codable {
    let msg: String
    let sched: [[[Int]]]
}

struct Day: Codable {
    let type: String
}

struct Days: Codable {
    let monday: Day
    let tuesday: Day
    let wednesday: Day
    let thursday: Day
    let friday: Day
}

struct WidgetData: Codable {
    let normal: DayType
    let evenBlock: DayType
    let oddBlock: DayType
    let activity: DayType
    let days: Days
}

struct DayEvent {
    let startHour: Int
    let startMin: Int
    let period: Int
    let endHour: Int
    let endMin: Int
    
    func convertToDate(currentDate: Date, hour: Int, min: Int) -> Date {
        let currentDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currentDate)
        let components = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: currentDateComponents.day, hour: hour, minute: min)
        let time = Calendar.current.date(from: components)!
        return time
    }
}

func convertDayEvent(eventData: [Int]) -> DayEvent {
    return DayEvent(startHour: eventData[0], startMin: eventData[1], period: eventData[2], endHour: eventData[3], endMin: eventData[4])
}

func convertPeriodIntToString(period: Int) -> String {
    let periodString: String
    switch period {
    case 1:
        periodString = "Period 1"
    case 2:
        periodString = "Period 2"
    case 3:
        periodString = "Period 3"
    case 4:
        periodString = "Period 4"
    case 5:
        periodString = "Period 5"
    case 6:
        periodString = "Period 6"
    case 7:
        periodString = "Period 7"
    case 100:
        periodString = "Morning"
    case 101:
        periodString = "Welcome"
    case 102:
        periodString = "Lunch"
    case 103:
        periodString = "Homeroom"
    case 104:
        periodString = "Dismissal"
    case 105:
        periodString = "After School"
    case 106:
        periodString = "End"
    case 200:
        periodString = "Walk To Class"
    default:
        periodString = ""
    }
    return periodString;
}

class DataCache {
    static let shared = DataCache()
    var widgetData: WidgetData?
    var configuration: ConfigurationAppIntent?
    private init() {}
}



func fetchWidgetData() async -> WidgetData? {
    guard let url = URL(string: "https://croomssched.tech/sched/sched.json") else {
        return nil
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let widgetData = try decoder.decode(WidgetData.self, from: data)
        print("Sucessfully fetched new data!")
        return widgetData
    } catch {
        print(error)
        return nil
    }
}
