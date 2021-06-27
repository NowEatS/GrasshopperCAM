//
//  GrasshopperCAMWidget.swift
//  GrasshopperCAMWidget
//
//  Created by TaeWon Seo on 2021/06/20.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct GrasshopperCAMWidget: Widget {
    let kind: String = "GrasshopperCAMWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GrasshopperCAMProvider(), content: { entry in
            GrasshopperCAMEntryView(entry: entry)
        })
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct GrasshopperCAMWidget_Previews: PreviewProvider {
    static var previews: some View {
        GrasshopperCAMEntryView(entry: GrasshopperCAMEntry(date: Date(), imageData: Data()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        GrasshopperCAMEntryView(entry: GrasshopperCAMEntry(date: Date(), imageData: Data()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
