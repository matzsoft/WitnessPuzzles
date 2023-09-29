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
            Picker( "Tetris Group", selection: $info.tetris.group ) {
                ForEach( info.tetris.groups.indices, id: \.self ) {
                    let infoCopy = info.replacing( tetris: info.tetris.replacing( group: $0 ) )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )

            if info.tetris.shapes.count > 1 {
                Picker( "Tetris Shape", selection: $info.tetris.shapeIndex ) {
                    ForEach( info.tetris.shapes.indices, id: \.self ) {
                        let infoCopy = info.replacing( tetris: info.tetris.replacing( shape: $0 ) )
                        WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                    }
                }.pickerStyle( .segmented )
            }
            
            if info.tetris.shape.allowedRotations.count > 1 {
                Picker( "Rotation", selection: $info.tetris.rotation ) {
                    ForEach( info.tetris.shape.allowedRotations ) {
                        let infoCopy = info.replacing( tetris: info.tetris.replacing( rotation: $0 ) )
                        WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                    }
                }.pickerStyle( .segmented )
                
                Picker( "Plain/Skewed", selection: $info.tetris.rotatable ) {
                    let plain = info.replacing( tetris: info.tetris.replacing( rotatable: false ) )
                    let skewed = info.replacing( tetris: info.tetris.replacing( rotatable: true ) )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: plain ).tag( false )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: skewed ).tag( true )
                }.pickerStyle( .segmented )

            }
            
            Picker( "Solid/Hollow", selection: $info.tetris.negated ) {
                let solid = info.replacing( tetris: info.tetris.replacing( negated: false ) )
                let hollow = info.replacing( tetris: info.tetris.replacing( negated: true ) )
                WitnessPuzzlesDocument.Icon.image( size: 25, info: solid ).tag( false )
                WitnessPuzzlesDocument.Icon.image( size: 25, info: hollow ).tag( true )
            }.pickerStyle( .segmented )
        }
    }
}
