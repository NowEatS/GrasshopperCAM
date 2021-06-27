//
//  GrasshopperCAMProvider.swift
//  GrasshopperCAM
//
//  Created by TaeWon Seo on 2021/06/24.
//

import WidgetKit
import Foundation

struct GrasshopperCAMProvider: TimelineProvider {
    typealias Entry = GrasshopperCAMEntry
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), imageData: Data())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        guard let data = UserDefaults.shared.value(forKey: GHUserDefaultsKeys.latestImage.rawValue) as? Data else { return }
        let entry = Entry(date: Date(), imageData: data)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        // 30분마다 Refresh
        
        guard let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate),
              let data = UserDefaults.shared.value(forKey: GHUserDefaultsKeys.latestImage.rawValue) as? Data else { return }
        let entry = Entry(date: Date(), imageData: data)
        let timeLine = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeLine)
    }
}
