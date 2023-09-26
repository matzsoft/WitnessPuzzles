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
                    let infoCopy = info.replacing( tetrisGroup: $0 )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )

            let group = info.tetris.group
            if info.tetris.groups[group].shapes.count > 1 {
                Picker( "Tetris Shape", selection: $info.tetris.groups[group].shape ) {
                    ForEach( info.tetris.groups[group].shapes.indices, id: \.self ) {
                        let infoCopy = info.replacing( tetrisShapeIndex: $0 )
                        WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                    }
                }.pickerStyle( .segmented )
            }
            
            let shapeIndex = info.tetris.groups[group].shape
            let shapeInfo = info.tetris.groups[group].shapes[shapeIndex]
            let shape = WitnessPuzzlesDocument.tetrisShapes[shapeInfo.shape]
            if shape.allowedRotations.count > 1 {
                let rotationBinding = $info.tetris.groups[group].shapes[shapeIndex].rotation
                let rotatableBinding = $info.tetris.groups[group].shapes[shapeIndex].rotatable
                Picker( "Rotation", selection: rotationBinding ) {
                    ForEach( shape.allowedRotations ) {
                        let infoCopy = info.replacing( tetrisRotation: $0 )
                        WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                    }
                }.pickerStyle( .segmented )
                
                Picker( "Plain/Skewed", selection: rotatableBinding ) {
                    let plain = info.replacing( tetrisRotatable: false )
                    let skewed = info.replacing( tetrisRotatable: true )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: plain ).tag( false )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: skewed ).tag( true )
                }.pickerStyle( .segmented )

            }
            
            Picker( "Solid/Hollow", selection: $info.tetris.negated ) {
                let solid = info.replacing( tetrisNegated: false )
                let hollow = info.replacing( tetrisNegated: true )
                WitnessPuzzlesDocument.Icon.image( size: 25, info: solid ).tag( false )
                WitnessPuzzlesDocument.Icon.image( size: 25, info: hollow ).tag( true )
            }.pickerStyle( .segmented )
        }
    }
}
