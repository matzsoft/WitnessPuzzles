//         FILE: ContentView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

struct ContentView: View {
    @Binding var document: WitnessPuzzlesDocument
    @State var isPresentingProperties = false

    var body: some View {
        Image( nsImage: document.nsImage )
            .toolbar {
                ToolbarItemGroup( placement: .automatic ) {
                    Button( action: { isPresentingProperties = true } ) {
                        Label( "Properties", systemImage: "ruler" )
                    }.labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Drawing", systemImage: "photo" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Starts", systemImage: "play" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Finishes", systemImage: "stop" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Gaps", systemImage: "pause" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Missing", systemImage: "cloud" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Hexagons", systemImage: "hexagon.fill" ) } )
                        .labelStyle( VerticalLabelStyle() )
                    Button( action: {}, label: { Label( "Icons", systemImage: "seal" ) } )
                        .labelStyle( VerticalLabelStyle() )
                }
            }
            .sheet( isPresented: $isPresentingProperties, onDismiss: { isPresentingProperties = false } ) {
                PropertiesView( document: $document )
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( document: .constant( WitnessPuzzlesDocument() ) )
    }
}


struct VerticalLabelStyle: LabelStyle {
    func makeBody( configuration: Configuration ) -> some View {
        VStack {
            configuration.icon.font( .headline )
            configuration.title.font( .subheadline )
        }
    }
}
