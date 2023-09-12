//         FILE: FinishView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/11/23 3:53 PM

import SwiftUI

struct FinishView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    let location: WitnessPuzzlesDocument.Point
    let directions: [WitnessPuzzlesDocument.Direction]
    @State var direction: WitnessPuzzlesDocument.Direction

    
    var body: some View {
        VStack {
//            Text( "Select a direction for the new finish" )
//            Divider()
            Picker( "Direction", selection: $direction ) {
                ForEach( directions ) {
                    $0.label.tag( $0 )
                }
            }.pickerStyle( .segmented )
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .cancelAction )
                Spacer()
                Button( "Done", role: .destructive ) {
                    document.addFinish( point: location, direction: direction )
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .defaultAction )
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }
}
