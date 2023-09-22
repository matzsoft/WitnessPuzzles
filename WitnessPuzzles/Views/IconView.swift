//         FILE: IconView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 8:05 PM

import SwiftUI

struct IconView: View {
    @Environment( \.presentationMode ) var presentationMode
    @Binding var document: WitnessPuzzlesDocument
    let location: WitnessPuzzlesDocument.Point
    @Binding var info: WitnessPuzzlesDocument.IconInfo
    @State var working: WitnessPuzzlesDocument.IconInfo

    init(
        document: Binding<WitnessPuzzlesDocument>, location: WitnessPuzzlesDocument.Point,
        info: Binding<WitnessPuzzlesDocument.IconInfo>
    ) {
        self._document = document
        self.location = location
        self._info = info
        self._working = State( initialValue: info.wrappedValue )
    }
    
    var body: some View {
        VStack {
//            Text( "Select a color for the new hexagon" )
//            Divider()
            ColorPicker( "Color", selection: $working.color )
            Divider()
            Picker( "Icon Type", selection: $working.iconType ) {
                ForEach( WitnessPuzzlesDocument.IconType.allCases ) {
                    let infoCopy = working.replacing( iconType: $0 )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )
            if working.iconType == .triangles {
                VStack {
                    Picker( "Triangles Count", selection: $working.trianglesCount ) {
                        ForEach( WitnessPuzzlesDocument.TrianglesCount.allCases ) {
                            let infoCopy = working.replacing( trianglesCount: $0 )
                            WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                        }
                    }.pickerStyle( .segmented )
                }
            }
            if working.iconType == .tetris {
                TetrisView( info: $working )
            }
            Divider()
            HStack {
                Button( "Cancel", role: .cancel ) {
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .cancelAction )
                Spacer()
                Button( "Done", role: .destructive ) {
                    info = working
                    switch info.iconType {
                    case .square:
                        document.addSquareIcon( point: location, color: info.color )
                    case .star:
                        document.addStarIcon( point: location, color: info.color )
                    case .triangles:
                        document.addTrianglesIcon( point: location, info: info )
                    case .elimination:
                        document.addEliminationIcon( point: location, color: info.color )
                    case .tetris:
                        document.addTetrisIcon( point: location, info: info )
                    }
                    if NSColorPanel.shared.isVisible { NSColorPanel.shared.orderOut( nil ) }
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut( .defaultAction )
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }
}
