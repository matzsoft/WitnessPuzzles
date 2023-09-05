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
    @State var type: WitnessPuzzlesDocument.PuzzleType
    @State var width: Double
    @State var height: Double
    @State var background: Color
    @State var foreground: Color
    @State var scaleFactor: Double
    @State var lineWidth: Double
    @State var blockWidth: Double
    @State var padding: Double

    init( document: Binding<WitnessPuzzlesDocument> ) {
        self._document = document
        _type = State( initialValue: document.wrappedValue.type )
        _width = State( initialValue: Double( document.wrappedValue.width ) )
        _height = State( initialValue: Double( document.wrappedValue.height ) )
        _background = State( initialValue: document.wrappedValue.background )
        _foreground = State( initialValue: document.wrappedValue.foreground )
        _scaleFactor = State( initialValue: document.wrappedValue.scaleFactor )
        _lineWidth = State( initialValue: Double( document.wrappedValue.lineWidth ) )
        _blockWidth = State( initialValue: Double( document.wrappedValue.blockWidth ) )
        _padding = State( initialValue: Double( document.wrappedValue.padding ) )
    }
    
    var body: some View {
        VStack {
            Text( "Properties" )
            Divider()
            Group {
                Spacer( minLength: 10 )
                Picker( "Puzzle Type", selection: $type ) {
                    ForEach( WitnessPuzzlesDocument.PuzzleType.allCases, id: \.self ) {
                        Text( $0.rawValue )
                    }
                }.pickerStyle( .menu )
                VStack {
                    Slider( value: $width, in: 1 ... 20, step: 1 ) {
                        Text( "Width" )
                    } minimumValueLabel: {
                        Text( "1" )
                    } maximumValueLabel: {
                        Text( "20" )
                    }
                    Text( String( format: "%.0f", width ) )
                }
                VStack {
                    Slider( value: $height, in: 1 ... 20, step: 1 ) {
                        Text( "Height" )
                    } minimumValueLabel: {
                        Text( "1" )
                    } maximumValueLabel: {
                        Text( "20" )
                    }
                    Text( String( format: "%.0f", height ) )
                }
                HStack {
                    ColorPicker( "Background", selection: $background )
                    ColorPicker( "Foreground", selection: $foreground )
                }
                VStack {
                    Slider( value: $scaleFactor, in: 1 ... 50, step: 0.5 ) {
                        Text( "Scale Factor" )
                    } minimumValueLabel: {
                        Text( "1" )
                    } maximumValueLabel: {
                        Text( "50" )
                    }
                    Text( String( format: "%.1f", scaleFactor ) )
                }
                VStack {
                    Slider( value: $padding, in: 0 ... 10, step: 1 ) {
                        Text( "Padding" )
                    } minimumValueLabel: {
                        Text( "0" )
                    } maximumValueLabel: {
                        Text( "10" )
                    }
                    Text( String( format: "%.0f", lineWidth ) )
                }
            }
            Divider()
            VStack {
                Slider( value: $lineWidth, in: 1 ... 10, step: 1 ) {
                    Text( "Line Width" )
                } minimumValueLabel: {
                    Text( "1" )
                } maximumValueLabel: {
                    Text( "10" )
                }
                Text( String( format: "%.0f", lineWidth ) )
            }
            VStack {
                Slider( value: $blockWidth, in: 4 ... 20, step: 1 ) {
                    Text( "Block Width" )
                } minimumValueLabel: {
                    Text( "4" )
                } maximumValueLabel: {
                    Text( "20" )
                }
                Text( String( format: "%.0f", blockWidth ) )
            }
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .cancelAction )
                Spacer()
                Button( "Done", role: .destructive ) {
                    document.adjustDimensions( type: type, width: Int( width ), height: Int( height ) )
                    document.background = background
                    document.foreground = foreground
                    document.scaleFactor = scaleFactor
                    document.lineWidth = Int( lineWidth )
                    document.blockWidth = Int( blockWidth )
                    document.padding = Int( padding )
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
