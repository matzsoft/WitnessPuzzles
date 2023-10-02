//         FILE: WitnessPuzzlesApp.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

@main
struct WitnessPuzzlesApp: App {
    @State private var isExporting = false
    @FocusedBinding( \.document ) var document

    var body: some Scene {
        DocumentGroup( newDocument: WitnessPuzzlesDocument() ) { file in
            ContentView(
                document: file.$document,
                windowID: WindowsList.shared.add( binding: file.$document )
            )
            .focusedSceneValue( \.document, file.$document )
        }
        .commands {
            CommandGroup( replacing: .importExport ) {
                Button( "Export" ) {
                    isExporting = true
                }
                .disabled( document == nil )
                .fileExporter(
                    isPresented: $isExporting,
                    document: document,
                    contentType: .png
                ) { result in
                    switch result {
                    case .success( let url ):
                        print( "Saved to \(url)" )
                    case .failure( let error ):
                        print( error.localizedDescription )
                    }
                }
            }
        }
        WindowGroup( "Properties", id: "properties", for: Int.self ) { $id in
            PropertiesView( document: WindowsList.shared.binding( id: id ) )
        } defaultValue: { 0 }
    }
}


extension FocusedValues {
    struct DocumentFocusedValues: FocusedValueKey {
        typealias Value = Binding<WitnessPuzzlesDocument>
    }

    var document: Binding<WitnessPuzzlesDocument>? {
        get {
            self[DocumentFocusedValues.self]
        }
        set {
            self[DocumentFocusedValues.self] = newValue
        }
    }
}
