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
    @State var color: Color
    let location: CGPoint
    
    init( document: Binding<WitnessPuzzlesDocument>, location: CGPoint ) {
        self._document = document
        _color = State( initialValue: document.wrappedValue.lastHexagonColor )
        self.location = location
    }
    
    var body: some View {
        VStack {
            Text( "Select a color for the new hexagon" )
            Divider()
            ColorPicker( "Background", selection: $color )
            Divider()
            HStack {
                Button( "Cancel", role: .cancel, action: { presentationMode.wrappedValue.dismiss() } )
                Button( "Done", role: .destructive ) {
                    document.addHexagon( viewPoint: location, color: color )
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }}
