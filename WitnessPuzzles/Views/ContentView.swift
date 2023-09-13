//         FILE: ContentView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

struct ContentView: View {
    enum ToolType: String, Identifiable {
        case none, properties, starts, finishes, gaps, missings, hexagons, icons
        
        var id: String { rawValue }
        
        mutating func select( _ tool: ToolType ) -> Void {
            self = tool == self ? .none : tool
        }
    }
    
    @Binding var document: WitnessPuzzlesDocument
    @State var toolType = ToolType.none
    
    @State var isConfiguringProperties = false
    @State var isConfiguringFinish = false
    @State var isConfiguringHexagon = false
    @State var isConfiguringIcon = false
    
    @State var lastLocation = WitnessPuzzlesDocument.Point( 0, 0 )
    @State var lastDirections = [WitnessPuzzlesDocument.Direction]()
    @State var lastColor = Color.black

    var body: some View {
        Image( nsImage: document.nsImage )
            .onTapGesture { location in
                let point = document.toPuzzleSpace( from: location )
                switch toolType {
                case .none, .properties:
                    break
                case .starts:
                    if document.startExists( point: point ) {
                        document.removeStart( point: point )
                    } else if document.isStartPositionOK( point: point ) {
                        document.addStart( point: point )
                    } else {
                        NSSound.beep()
                    }
                case .finishes:
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
                case .gaps:
                    if document.gapExists( point: point ) {
                        document.removeGap( point: point )
                    } else if document.isGapPositionOK( point: point ) {
                        document.addGap( point: point )
                    } else {
                        NSSound.beep()
                    }
                case .missings:
                    if document.missingExists( point: point ) {
                        document.removeMissing( point: point )
                    } else if document.isMissingPositionOK( point: point ) {
                        document.addMissing( point: point )
                    } else {
                        NSSound.beep()
                    }
                case .hexagons:
                    if document.hexagonExists( point: point ) {
                        document.removeHexagon( point: point )
                    } else if document.isHexagonPositionOK( point: point ) {
                        isConfiguringHexagon = true
                        lastLocation = point
                    } else {
                        NSSound.beep()
                    }
                case .icons:
                    if document.iconExists( point: point ) {
                        document.removeIcon( point: point )
                    } else if document.isIconPositionOK( point: point ) {
                        isConfiguringIcon = true
                        lastLocation = point
                    } else {
                        NSSound.beep()
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup( placement: .automatic ) {
                    Button( action: { toolType.select( .properties ); isConfiguringProperties = true } ) {
                        Label( "Properties", systemImage: "ruler" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .properties ) )
                    Button( action: { toolType.select( .starts ) } ) {
                        Label( "Starts", systemImage: "play" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .starts ) )
                    Button( action: { toolType.select( .finishes ) } ) {
                        Label( "Finishes", systemImage: "stop" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .finishes ) )
                    Button( action: { toolType.select( .gaps ) } ) {
                        Label( "Gaps", systemImage: "pause" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .gaps ) )
                    Button( action: { toolType.select( .missings ) } ) {
                        Label( "Missing", systemImage: "cloud" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .missings ) )
                    Button( action: { toolType.select( .hexagons ) } ) {
                        Label( "Hexagons", systemImage: "hexagon.fill" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .hexagons ) )
                    Button( action: { toolType.select( .icons ) } ) {
                        Label( "Icons", systemImage: "seal" )
                    }.labelStyle( VerticalLabelStyle( isSelected: toolType == .icons ) )
                }
            }
            .sheet( isPresented: $isConfiguringProperties, onDismiss: { toolType = .none } ) {
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
            .sheet( isPresented: $isConfiguringIcon, onDismiss: {} ) {
                IconView( document: $document, location: lastLocation, color: $lastColor )
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
