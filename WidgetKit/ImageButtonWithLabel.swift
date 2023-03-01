// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

#if canImport(WidgetKit)
import SwiftUI

// View for Quick Action Widget Buttons (Small & Medium)
// +-------------------------------------------------------+
// | +--------+                                            |
// | | ZSTACK |                                            |
// | +--------+                                            |
// | +--------------------------------------------------+  |
// | |+-------+                                         |  |
// | ||VSTACK |                                         |  |
// | |+-------+                                         |  |
// | | +---------------------------------------------+  |  |
// | | |+-------+                                    |  |  |
// | | ||HSTACK | +--------+-----+ +--------------+  |  |  |
// | | |+-------+ | VSTACK |     | |+----------+  |  |  |  |
// | | |          +--------+     | || lOGO FOR |  |  |  |  |
// | | |          | +----------+ | ||  WIDGET  |  |  |  |  |
// | | |          | | LABEL OF | | ||  ACTION  |  |  |  |  |
// | | |          | | SELECTED | | |+----------+  |  |  |  |
// | | |          | |  ACTION  | | |              |  |  |  |
// | | |          | +----------+ | |              |  |  |  |
// | | |          |              | |              |  |  |  |
// | | |          +--------------+ +--------------+  |  |  |
// | | |                                             |  |  |
// | | |                                             |  |  |
// | | +---------------------------------------------+  |  |
// | |                                                  |  |
// | | +--------------------------------------------+   |  |
// | | | +--------------------------+ +-----------+ |   |  |
// | | | | HSTACK (if small widget) | | +-------+ | |   |  |
// | | | +--------------------------+ | |FXICON | | |   |  |
// | | |                              | +-------+ | |   |  |
// | | |                              |           | |   |  |
// | | |                              |           | |   |  |
// | | |                              +-----------+ |   |  |
// | | |                                            |   |  |
// | | +--------------------------------------------+   |  |
// | |                                                  |  |
// | |                                                  |  |
// | |                                                  |  |
// | +--------------------------------------------------+  |
// |                                                       |
// +-------------------------------------------------------+

struct ImageButtonWithLabel: View {
    var link: QuickLink

    var paddingValue: CGFloat {
        return 8.0
    }

    var body: some View {
        Link(destination: link.mediumWidgetUrl) {
            ZStack(alignment: .leading) {
                ContainerRelativeShape()
                        .fill(LinearGradient(gradient: Gradient(colors: link.backgroundColors), startPoint: .bottomLeading, endPoint: .topTrailing))
                
                
                VStack (alignment: .center, spacing: 50.0){
                    HStack(alignment: .top) {
                        VStack(alignment: .leading){
                            
                            Text(link.label)
                                .font(Font.custom("ProximaNova-Medium", size: 12))
                                    .minimumScaleFactor(0.75)
                                    .layoutPriority(1000)
                                
                        }
                        Spacer()
                        
                        Image(link.imageName)
                                .scaledToFit()
                        
                    }
                }
                .foregroundColor(Color("widgetLabelColors"))
                .padding([.horizontal, .vertical], paddingValue)
            }
        }
    }
}

#endif
