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


struct PropertiesView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    @State var width: Double

    init( document: Binding<WitnessPuzzlesDocument> ) {
        self._document = document
        _width = State(initialValue: Double( document.wrappedValue.width ) )
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


struct VerticalLabelStyle: LabelStyle {
    func makeBody( configuration: Configuration ) -> some View {
        VStack {
            configuration.icon.font( .headline )
            configuration.title.font( .subheadline )
        }
    }
}
