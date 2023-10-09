//         FILE: ContentView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

struct GuiState {
    var selectedTool: ContentView.ToolType?
    var location = WitnessPuzzlesDocument.Point( 0, 0 )
    var findingDirection = false
    var origin = WitnessPuzzlesDocument.Point( 0, 0 )
    var directions = Set<WitnessPuzzlesDocument.Point>()
    
    func replacing(
        selectedTool: ContentView.ToolType? = nil,
        location: WitnessPuzzlesDocument.Point? = nil,
        findingDirection: Bool? = nil,
        origin: WitnessPuzzlesDocument.Point? = nil,
        directions: Set<WitnessPuzzlesDocument.Point>? = nil
    ) -> GuiState {
        var copy = self
        
        if let selectedTool = selectedTool { copy.selectedTool = selectedTool }
        if let location = location { copy.location = location }
        if let findingDirection = findingDirection { copy.findingDirection = findingDirection }
        if let origin = origin { copy.origin = origin }
        if let directions = directions { copy.directions = directions }
        
        return copy
    }
}

struct ContentView: View {
    @Environment( \.openWindow ) private var openWindow
    @Binding var document: WitnessPuzzlesDocument
    let windowID: Int
    @State var currentConfiguration: ToolType?
    @State var lastDirections = [WitnessPuzzlesDocument.Direction]()
    @State var guiState = GuiState()
    @State var iconInfo = WitnessPuzzlesDocument.IconInfo(
        color: Color( cgColor: CGColor( red: 1, green: 0.4, blue: 0.1, alpha: 1 ) ),
        iconType: WitnessPuzzlesDocument.IconType.square,
        trianglesCount: WitnessPuzzlesDocument.TrianglesCount.two,
        tetris: WitnessPuzzlesDocument.TetrisInfo()
    )
    @State var columnVisibility = NavigationSplitViewVisibility.detailOnly

    func toggleTool( _ tool: ToolType ) {
        if guiState.selectedTool == tool {
            guiState.selectedTool = nil
            columnVisibility = .detailOnly
        } else {
            guiState.selectedTool = tool
            switch guiState.selectedTool {
            case .none, .starts, .finishes, .gaps, .missings:
                columnVisibility = .detailOnly
            case .hexagons, .icons:
                columnVisibility = .all
            }
        }
    }
    func deselectTool( _ tool: ToolType ) {
        if guiState.selectedTool == tool { guiState.selectedTool = nil }
    }

    var body: some View {
        NavigationSplitView( columnVisibility: $columnVisibility ) {
            switch guiState.selectedTool {
            case .none, .starts, .finishes, .gaps, .missings:
                Text( "No settings to display." )
            case .hexagons:
                HexagonView( info: $iconInfo )
            case .icons:
                IconView( info: $iconInfo )
            }
        } detail: {
            Image( document.image( guiState: guiState, info: iconInfo ), scale: 1.0, label: Text( "" ) )
                .onTapGesture { location in
                    guiState.location = document.toPuzzleSpace( from: location )
                    if !document.processTap( guiState: guiState, iconInfo: iconInfo ) {
                        NSSound.beep()
                    }
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active( let location ):
                        guiState.location = document.toPuzzleSpace( from: location )
                        guiState = document.processHover( guiState: guiState )
                    case .ended:
                        break
                    }
                }
                .toolbar {
                    ToolbarItemGroup( placement: .automatic ) {
                        Button( action: { openWindow( id: "properties", value: windowID ) } ) {
                            Label( "Properties", systemImage: "ruler" )
                        }.labelStyle( VerticalLabelStyle( isSelected: false ) )
                        Button( action: { toggleTool( .starts ) } ) {
                            Label( "Starts", systemImage: "play" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .starts ) )
                        Button( action: { toggleTool( .finishes ) } ) {
                            Label( "Finishes", systemImage: "stop" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .finishes ) )
                        Button( action: { toggleTool( .gaps ) } ) {
                            Label( "Gaps", systemImage: "pause" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .gaps ) )
                        Button( action: { toggleTool( .missings ) } ) {
                            Label( "Missing", systemImage: "cloud" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .missings ) )
                        Button( action: { toggleTool( .hexagons ) } ) {
                            Label( "Hexagons", systemImage: "hexagon.fill" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .hexagons ) )
                        Button( action: { toggleTool( .icons ) } ) {
                            Label( "Icons", systemImage: "seal" )
                        }.labelStyle( VerticalLabelStyle( isSelected: guiState.selectedTool == .icons ) )
                    }
                }
                .sheet( item: $currentConfiguration ) { sheet in
                    switch sheet {
                    case .finishes:
                        FinishView(
                            document: $document, location: guiState.location,
                            directions: lastDirections, direction: lastDirections.first!
                        )
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
        case starts, finishes, gaps, missings, hexagons, icons
        
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
