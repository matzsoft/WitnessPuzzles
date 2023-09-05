//         FILE: HexagonView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/2/23 7:05 PM

import SwiftUI

struct HexagonView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    let location: CGPoint
    @Binding var color: Color

    var body: some View {
        VStack {
            Text( "Select a color for the new hexagon" )
            Divider()
            ColorPicker( "", selection: $color )
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                Button( "Done", role: .destructive ) {
                    document.addHexagon( viewPoint: location, color: color )
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }}
