//         FILE: IconView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 8:05 PM

import SwiftUI

struct IconView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    let location: WitnessPuzzlesDocument.Point
    @Binding var color: Color
    @Binding var iconType: WitnessPuzzlesDocument.IconType

    var body: some View {
        VStack {
//            Text( "Select a color for the new hexagon" )
//            Divider()
            ColorPicker( "Color", selection: $color )
            Divider()
            Picker( "Icon Type", selection: $iconType ) {
                ForEach( WitnessPuzzlesDocument.IconType.allCases ) {
                    $0.label.tag( $0 )
                }
            }.pickerStyle( .segmented )
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .cancelAction )
                Spacer()
                Button( "Done", role: .destructive ) {
                    switch iconType {
                    case .square:
                        document.addSquareIcon( point: location, color: color )
                    case .star:
                        document.addStarIcon( point: location, color: color )
                    case .elimination:
                        document.addEliminationIcon( point: location, color: color )
                    }
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .defaultAction )
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }
}
