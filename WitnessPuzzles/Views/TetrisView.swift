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
            Picker( "Tetris Class", selection: $info.tetrisClass ) {
                ForEach( WitnessPuzzlesDocument.tetrisClasses ) {
                    let infoCopy = info.replacing( tetrisShape: $0.first! )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0.first! )
                }
            }.pickerStyle( .segmented )
            Picker( "Tetris Shape", selection: $info.tetrisShape ) {
                ForEach( info.tetrisClass ) {
                    let infoCopy = info.replacing( tetrisShape: $0 )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )
        }
    }
}
