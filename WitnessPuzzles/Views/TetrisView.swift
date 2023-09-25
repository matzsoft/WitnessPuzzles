//         FILE: TetrisView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/20/23 8:51 PM

import SwiftUI

struct TetrisView: View {
    @Binding var info: WitnessPuzzlesDocument.IconInfo

    var body: some View {
        VStack {
            Picker( "Tetris Class", selection: $info.tetrisClassIndex ) {
                ForEach( WitnessPuzzlesDocument.tetrisClasses.indices, id: \.self ) {
                    let infoCopy = info.replacing( tetrisClassIndex: $0 )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )
            if WitnessPuzzlesDocument.tetrisClasses[info.tetrisClassIndex].count > 1 {
                Picker( "Tetris Shape", selection: $info.tetrisShapeIndex[info.tetrisClassIndex] ) {
                    ForEach( WitnessPuzzlesDocument.tetrisClasses[info.tetrisClassIndex].indices, id: \.self ) {
                        let infoCopy = info.replacing( tetrisShapeIndex: $0 )
                        WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                    }
                }.pickerStyle( .segmented )
            }
            Picker( "Solid/Hollow", selection: $info.tetrisNegated ) {
                let solid = info.replacing( tetrisNegated: false )
                let hollow = info.replacing( tetrisNegated: true )
                WitnessPuzzlesDocument.Icon.image(size: 25, info: solid ).tag( false )
                WitnessPuzzlesDocument.Icon.image(size: 25, info: hollow ).tag( true )
            }.pickerStyle( .segmented )
        }
    }
}
