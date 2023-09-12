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
    
    @State var isConfiguringFinish = false
    @State var isConfiguringHexagon = false
    @State var lastLocation = WitnessPuzzlesDocument.Point( 0, 0 )
    @State var lastDirections = [WitnessPuzzlesDocument.Direction]()
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
                let point = document.toPuzzleSpace( from: location )
                switch true {
                case isStartsSelected:
                    if document.startExists( point: point ) {
                        document.removeStart( point: point )
                    } else if document.isStartPositionOK( point: point ) {
                        document.addStart( point: point )
                    } else {
                        NSSound.beep()
                    }
                case isFinishesSelected:
                    if document.finishExists( point: point ) {
                        document.removeFinish( point: point )
                    } else if let directions =
                                WitnessPuzzlesDocument.Finish.validDirections( for: point, in: document ) {
                        if directions.count == 1 {
                            document.addFinish( point: point, direction: directions.first! )
                        } else {
                            isConfiguringFinish = true
                            lastLocation = point
                            lastDirections = directions
                        }
                    } else {
                        NSSound.beep()
                    }
                case isGapsSelected:
                    if document.gapExists( point: point ) {
                        document.removeGap( point: point )
                    } else if document.isGapPositionOK( point: point ) {
                        document.addGap( point: point )
                    } else {
                        NSSound.beep()
                    }
                case isMissingSelected:
                    if document.missingExists( point: point ) {
                        document.removeMissing( point: point )
                    } else if document.isMissingPositionOK( point: point ) {
                        document.addMissing( point: point )
                    } else {
                        NSSound.beep()
                    }
                case isHexagonsSelected:
                    if document.hexagonExists( point: point ) {
                        document.removeHexagon( point: point )
                    } else if document.isHexagonPositionOK( point: point ) {
                        isConfiguringHexagon = true
                        lastLocation = point
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
            .sheet( isPresented: $isConfiguringFinish, onDismiss: {} ) {
                FinishView(
                    document: $document, location: lastLocation,
                    directions: lastDirections, direction: lastDirections.first!
                )
            }
            .sheet( isPresented: $isConfiguringHexagon, onDismiss: {} ) {
                HexagonView( document: $document, location: lastLocation, color: $lastColor )
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
