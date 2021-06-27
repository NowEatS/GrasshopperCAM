//
//  GrasshopperCAMEntryView.swift
//  GrasshopperCAM
//
//  Created by TaeWon Seo on 2021/06/27.
//

import SwiftUI
import WidgetKit

struct GrasshopperCAMEntryView: View {
    let entry: GrasshopperCAMEntry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        if let image = UIImage(data: entry.imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .cornerRadius(10.0)
        } else {
            Image("베짱이")
                .resizable()
                .cornerRadius(10.0)
        }
    }
}
