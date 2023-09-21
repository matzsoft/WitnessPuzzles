//         FILE: PropertiesView.swift
//  DESCRIPTION: WitnessPuzzles - Defines the Properties Sheet
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/29/23 9:17 PM

import SwiftUI

struct PropertiesView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    @State var working: WitnessPuzzlesDocument

    init( document: Binding<WitnessPuzzlesDocument> ) {
        self._document = document
        self._working = State( initialValue: document.wrappedValue )
    }
    
    var body: some View {
        VStack {
            Text( "Properties" )
            Divider()
            Group {
                Spacer( minLength: 10 )
                Picker( "Puzzle Type", selection: $working.type ) {
                    ForEach( WitnessPuzzlesDocument.PuzzleType.allCases, id: \.self ) {
                        Text( $0.rawValue )
                    }
                }.pickerStyle( .menu )
                IntSlider( value: $working.width, range: 1 ... 20, step: 1, label: "Width" )
                IntSlider( value: $working.height, range: 1 ... 20, step: 1, label: "Height" )
                HStack {
                    ColorPicker( "Background", selection: $working.background )
                    ColorPicker( "Foreground", selection: $working.foreground )
                }
                DoubleSlider(
                    value: $working.scaleFactor, range: 1 ... 50, step: 0.5, label: "Scale Factor"
                )
                IntSlider( value: $working.padding, range: 0 ... 10, step: 1, label: "Padding" )
            }
            Divider()
            IntSlider( value: $working.lineWidth, range: 1 ... 10, step: 1, label: "Line Width" )
            IntSlider( value: $working.blockWidth, range: 4 ... 20, step: 1, label: "Block Width" )
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .cancelAction )
                Spacer()
                Button( "Done", role: .destructive ) {
                    working.adjustDimensions()
                    document = working
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
