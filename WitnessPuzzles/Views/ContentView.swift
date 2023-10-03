//         FILE: ContentView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

struct ContentView: View {
    @Environment( \.openWindow ) private var openWindow
    @Binding var document: WitnessPuzzlesDocument
    let windowID: Int
    @State var selectedTool: ToolType?
    @State var currentConfiguration: ToolType?
    @State var lastLocation = WitnessPuzzlesDocument.Point( 0, 0 )
    @State var lastDirections = [WitnessPuzzlesDocument.Direction]()
    @State var iconInfo = WitnessPuzzlesDocument.IconInfo(
        color: Color( cgColor: CGColor( red: 1, green: 0.4, blue: 0.1, alpha: 1 ) ),
        iconType: WitnessPuzzlesDocument.IconType.square,
        trianglesCount: WitnessPuzzlesDocument.TrianglesCount.two,
        tetris: WitnessPuzzlesDocument.TetrisInfo()
    )
    @State var columnVisibility = NavigationSplitViewVisibility.detailOnly

    func toggleTool( _ tool: ToolType ) {
        if selectedTool == tool {
            selectedTool = nil
            columnVisibility = .detailOnly
        } else {
            selectedTool = tool
            switch selectedTool {
            case .none, .properties, .starts, .finishes, .gaps, .missings:
                columnVisibility = .detailOnly
            case .hexagons, .icons:
                columnVisibility = .all
            }
        }
    }
    func deselectTool( _ tool: ToolType ) { if selectedTool == tool { selectedTool = nil } }

    var body: some View {
        NavigationSplitView( columnVisibility: $columnVisibility ) {
            switch selectedTool {
            case .none, .properties, .starts, .finishes, .gaps, .missings:
                Text( "No settings to display." )
            case .hexagons:
                HexagonView( info: $iconInfo )
            case .icons:
                IconView( document: $document, location: lastLocation, info: $iconInfo )
            }
        } detail: {
            Image( document.image, scale: 1.0, label: Text(verbatim: "" ) )
                .onTapGesture { location in
                    let point = document.toPuzzleSpace( from: location )
                    switch selectedTool {
                    case nil, .properties:
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
                                currentConfiguration = .finishes
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
                            lastLocation = point
                            document.addHexagon( point: point, info: iconInfo )
                        } else {
                            NSSound.beep()
                        }
                    case .icons:
                        if document.iconExists( point: point ) {
                            document.removeIcon( point: point )
                        } else if document.isIconPositionOK( point: point ) {
                            currentConfiguration = .icons
                            lastLocation = point
                        } else {
                            NSSound.beep()
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup( placement: .automatic ) {
                        Button( action: { openWindow( id: "properties", value: windowID ) } ) {
                            Label( "Properties", systemImage: "ruler" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .properties ) )
                        Button( action: { toggleTool( .starts ) } ) {
                            Label( "Starts", systemImage: "play" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .starts ) )
                        Button( action: { toggleTool( .finishes ) } ) {
                            Label( "Finishes", systemImage: "stop" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .finishes ) )
                        Button( action: { toggleTool( .gaps ) } ) {
                            Label( "Gaps", systemImage: "pause" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .gaps ) )
                        Button( action: { toggleTool( .missings ) } ) {
                            Label( "Missing", systemImage: "cloud" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .missings ) )
                        Button( action: { toggleTool( .hexagons ) } ) {
                            Label( "Hexagons", systemImage: "hexagon.fill" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .hexagons ) )
                        Button( action: { toggleTool( .icons ) } ) {
                            Label( "Icons", systemImage: "seal" )
                        }.labelStyle( VerticalLabelStyle( isSelected: selectedTool == .icons ) )
                    }
                }
                .sheet( item: $currentConfiguration, onDismiss: { deselectTool( .properties ) } ) { sheet in
                    switch sheet {
                    case .properties:
                        PropertiesView( document: $document )
                    case .finishes:
                        FinishView(
                            document: $document, location: lastLocation,
                            directions: lastDirections, direction: lastDirections.first!
                        )
                    case .icons:
                        IconView( document: $document, location: lastLocation, info: $iconInfo )
                    default:
                        Text( verbatim: "No configuration for \(sheet.rawValue.capitalized)." )
                    }
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let documentBinding = Binding.constant( WitnessPuzzlesDocument() )
        ContentView(
            document: documentBinding,
            windowID: WindowsList.shared.add( binding: documentBinding ) )
    }
}


extension ContentView {
    enum ToolType: String, Identifiable {
        case properties, starts, finishes, gaps, missings, hexagons, icons
        
        var id: String { rawValue }
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
        .background( isSelected ? Color( nsColor: .selectedControlColor ) : Color( nsColor: .clear ) )
    }
}
