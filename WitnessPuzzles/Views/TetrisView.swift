//         FILE: TetrisView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/20/23 8:51 PM

import SwiftUI

struct TetrisView: View {
    @Binding var color: Color
    @Binding var trianglesCount: WitnessPuzzlesDocument.TrianglesCount
    @Binding var tetrisShape: WitnessPuzzlesDocument.TetrisShape

    var body: some View {
        VStack {
            Picker( "Tetris Shape", selection: $tetrisShape ) {
                ForEach( WitnessPuzzlesDocument.tetrisShapes ) {
                    WitnessPuzzlesDocument.Icon.image(
                        size: 25, type: .tetris,
                        color: color, trianglesCount: trianglesCount,
                        tetrisShape: $0, tetrisRotation: .zero
                    ).tag( $0 )
                }
            }.pickerStyle( .segmented )
        }
    }
}
