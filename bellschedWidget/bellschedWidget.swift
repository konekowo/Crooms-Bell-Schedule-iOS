import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let widgetData = await fetchWidgetData()
        DataCache.shared.widgetData = widgetData
        DataCache.shared.configuration = configuration
        
        // Generate a timeline consisting of entries for every secind, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
    


        // Return a timeline that updates every minute.
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct bellschedWidgetEntryView : View {
    var entry: Provider.Entry

    
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    
    func getMsgFromDayType(wigitData: WidgetData, type: String) -> String {
        switch type {
        case "normal":
            return wigitData.normal.msg
        case "evenBlock":
            return wigitData.evenBlock.msg
        case "oddBlock":
            return wigitData.oddBlock.msg
        case "activity":
            return wigitData.activity.msg
        default:
            return ""
        }
    }
    
    func getCurrentDayMsg(wigitData: WidgetData) -> String {
        return getMsgFromDayType(wigitData: wigitData, type: getCurrentDayType(wigitData: wigitData));
    }
    
    func getCurrentDayType(wigitData: WidgetData) -> String {
        let currentDay = dayOfWeek(date: entry.date)?.lowercased()
        let msg: String
        switch currentDay {
        case "monday":
            msg = wigitData.days.monday.type
        case "tuesday":
            msg = wigitData.days.tuesday.type
        case "wednesday":
            msg = wigitData.days.wednesday.type
        case "thursday":
            msg = wigitData.days.thursday.type
        case "friday":
            msg = wigitData.days.friday.type
        default:
            msg = ""
        }
        return msg;
    }
    
    func dayOfWeek(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    func getCurrentPeriod(wigitData: WidgetData) -> DayEvent? {
        let currentDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: entry.date)
        let dayType: String = getCurrentDayType(wigitData: wigitData)
        let dayEvent: DayEvent?
        func findCurrentPeriod(periods: [[Int]]) -> DayEvent?{
            struct nearestEvent {
                let event: DayEvent
                let distance: TimeInterval
            }
            var distances: [nearestEvent] = []
            for period in periods {
                let converted = convertDayEvent(eventData: period)
                let startComponents = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: currentDateComponents.day, hour: converted.startHour, minute: converted.startMin)
                let startTime = Calendar.current.date(from: startComponents)!
                let endComponents = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: currentDateComponents.day, hour: converted.endHour, minute: converted.endMin)
                let endTime = Calendar.current.date(from: endComponents)!
                if (entry.date.distance(to: startTime) > 0){
                    distances.append(nearestEvent(event: converted, distance: entry.date.distance(to: startTime)))
                }
                if (entry.date > startTime && entry.date < endTime){
                    return converted
                }
                
            }
            distances.sort(by: {$0.distance < $1.distance})
            return DayEvent(startHour: 0, startMin: 0, period: 200, endHour: distances[0].event.startHour, endMin: distances[0].event.startMin)
        }
        switch dayType {
        case "normal":
            dayEvent = findCurrentPeriod(periods: wigitData.normal.sched[DataCache.shared.configuration!.aLunch ? 0 : 1])
        case "evenBlock":
            dayEvent = findCurrentPeriod(periods: wigitData.evenBlock.sched[DataCache.shared.configuration!.aLunch ? 0 : 1])
        case "oddBlock":
            dayEvent = findCurrentPeriod(periods: wigitData.oddBlock.sched[DataCache.shared.configuration!.aLunch ? 0 : 1])
        case "activity":
            dayEvent = findCurrentPeriod(periods: wigitData.activity.sched[DataCache.shared.configuration!.aLunch ? 0 : 1])
        default:
            dayEvent = nil
        }
        
        return dayEvent
    }
    
    
    func calcEndTimeForPeriod(period: DayEvent) -> Date{
        let currentDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: entry.date)
        let endComponents = DateComponents(year: currentDateComponents.year, month: currentDateComponents.month, day: currentDateComponents.day, hour: period.endHour, minute: period.endMin)
        let endTime = Calendar.current.date(from: endComponents)!
        return endTime
    }
    
    var body: some View {
        VStack{
            HStack{
                VStack {
                    HStack {
                        Text(entry.date, formatter: dayFormatter)
                        Text(entry.date, formatter: dateFormatter)
                        Text(entry.date, style: .time)
                        Spacer()
                    }
                    if (DataCache.shared.widgetData != nil){
                        HStack {
                            Text("\(getCurrentDayMsg(wigitData: DataCache.shared.widgetData!))")
                            Spacer()
                        }
                        HStack {
                            let currentPeriod: DayEvent = getCurrentPeriod(wigitData: DataCache.shared.widgetData!)!
                            Text("\(convertPeriodIntToString(period: currentPeriod.period)), Time Left: \(Text(calcEndTimeForPeriod(period: currentPeriod), style: .timer))")
                            
                            
                        }
                    }
                    
                }
                if (DataCache.shared.widgetData != nil){
                    let currentPeriod: DayEvent = getCurrentPeriod(wigitData: DataCache.shared.widgetData!)!
                    let startTime = currentPeriod.convertToDate(currentDate: entry.date, hour: currentPeriod.startHour, min: currentPeriod.startMin)
                    let endTime = currentPeriod.convertToDate(currentDate: entry.date, hour: currentPeriod.endHour, min: currentPeriod.endMin)
                    ProgressView(timerInterval: startTime...endTime, countsDown: true, label: { EmptyView() }, currentValueLabel: { EmptyView() })
                        .progressViewStyle(.circular)
                        .frame(width: 70.0)
                }
            }
            
            
        }
            

        
            
    }
}


struct bellschedWidget: Widget {
    let kind: String = "bellschedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            bellschedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium]) // Limit to medium size
    }
}

extension ConfigurationAppIntent {
    fileprivate static var aLunch: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.aLunch = true
        return intent
    }
}


#Preview(as: .systemMedium) {
    bellschedWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .aLunch)
}

