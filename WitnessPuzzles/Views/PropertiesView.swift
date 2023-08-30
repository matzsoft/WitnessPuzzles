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
    @State var width: Double

    init( document: Binding<WitnessPuzzlesDocument> ) {
        self._document = document
        _width = State( initialValue: Double( document.wrappedValue.width ) )
    }
    
    var body: some View {
        return NavigationView {
            VStack {
                Text( "Properties Page" )
                HStack {
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
                }
                HStack {
                    Button( "Cancel", role: .cancel, action: { presentationMode.wrappedValue.dismiss() } )
                    Button( "Done", role: .destructive ) {
                        document.width = Int( width )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
