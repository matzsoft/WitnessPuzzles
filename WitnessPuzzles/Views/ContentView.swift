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
    @State var isStartsSelected = false
    @State var isFinishesSelected = false
    @State var isGapsSelected = false
    @State var isMissingSelected = false
    @State var isHexagonsSelected = false
    @State var isIconsSelected = false
    
    @State var isConfiguringHexagon = false
    @State var lastLocation = CGPoint( x: 0, y: 0 )
    @State var lastColor = Color.black

    func select( tool: Binding<Bool> ) -> Void {
        let saved = tool.wrappedValue
        
        isPresentingProperties = false
        isStartsSelected = false
        isFinishesSelected = false
        isGapsSelected = false
        isMissingSelected = false
        isHexagonsSelected = false
        isIconsSelected = false

        tool.wrappedValue = saved
        tool.wrappedValue.toggle()
    }

    var body: some View {
        Image( nsImage: document.nsImage )
            .onTapGesture { location in
                switch true {
                case isStartsSelected:
                    if document.startExists( viewPoint: location ) {
                        document.removeStart( viewPoint: location )
                    } else if document.isStartPositionOK( viewPoint: location ) {
                        document.addStart( viewPoint: location )
                    } else {
                        NSSound.beep()
                    }
                case isFinishesSelected:
                    if document.finishExists( viewPoint: location ) {
                        document.removeFinish( viewPoint: location )
                    } else if document.isFinishPositionOK( viewPoint: location ) {
                        document.addFinish( viewPoint: location )
                    } else {
                        NSSound.beep()
                    }
                case isGapsSelected:
                    if document.gapExists( viewPoint: location ) {
                        document.removeGap( viewPoint: location )
                    } else if document.isGapPositionOK( viewPoint: location ) {
                        document.addGap( viewPoint: location )
                    } else {
                        NSSound.beep()
                    }
                case isMissingSelected:
                    if document.missingExists( viewPoint: location ) {
                        document.removeMissing( viewPoint: location )
                    } else if document.isMissingPositionOK( viewPoint: location ) {
                        document.addMissing( viewPoint: location )
                    } else {
                        NSSound.beep()
                    }
                case isHexagonsSelected:
                    if document.hexagonExists( viewPoint: location ) {
                        document.removeHexagon( viewPoint: location )
                    } else if document.isHexagonPositionOK( viewPoint: location ) {
                        isConfiguringHexagon = true
                        lastLocation = location
                    } else {
                        NSSound.beep()
                    }
                default:
                    break
                }
            }
            .toolbar {
                ToolbarItemGroup( placement: .automatic ) {
                    Button( action: { select( tool: $isPresentingProperties ) } ) {
                        Label( "Properties", systemImage: "ruler" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isPresentingProperties ) )
                    Button( action: { select( tool: $isStartsSelected ) } ) {
                        Label( "Starts", systemImage: "play" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isStartsSelected ) )
                    Button( action: { select( tool: $isFinishesSelected ) } ) {
                        Label( "Finishes", systemImage: "stop" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isFinishesSelected ) )
                    Button( action: { select( tool: $isGapsSelected ) } ) {
                        Label( "Gaps", systemImage: "pause" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isGapsSelected ) )
                    Button( action: { select( tool: $isMissingSelected ) } ) {
                        Label( "Missing", systemImage: "cloud" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isMissingSelected ) )
                    Button( action: { select( tool: $isHexagonsSelected ) } ) {
                        Label( "Hexagons", systemImage: "hexagon.fill" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isHexagonsSelected ) )
                    Button( action: { select( tool: $isIconsSelected ) } ) {
                        Label( "Icons", systemImage: "seal" )
                    }.labelStyle( VerticalLabelStyle( isSelected: isIconsSelected ) )
                }
            }
            .sheet( isPresented: $isPresentingProperties, onDismiss: {} ) {
                PropertiesView( document: $document )
            }
            .sheet( isPresented: $isConfiguringHexagon, onDismiss: {} ) {
                HexagonView(document: $document, location: lastLocation, color: $lastColor )
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( document: .constant( WitnessPuzzlesDocument() ) )
    }
}


struct VerticalLabelStyle: LabelStyle {
    var isSelected: Bool
    
    func makeBody( configuration: Configuration ) -> some View {
        VStack {
            configuration.icon.font( .headline )
            configuration.title.font( .subheadline )
        }
        .frame( alignment: .top )
        .padding( 5 )
        .scaleEffect( isSelected ? 1.2 : 1 )
        .background( isSelected ? .green : .white )
    }
}
