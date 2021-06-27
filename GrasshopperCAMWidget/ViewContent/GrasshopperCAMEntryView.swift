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
        ZStack(alignment: .center) {
            Color.white
            
            ZStack {
                if let image = UIImage(data: entry.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(10.0)
                } else {
                    Image("베짱이")
                        .resizable()
                        .cornerRadius(10.0)
                }
            }
            .padding()
        }
    }
}
