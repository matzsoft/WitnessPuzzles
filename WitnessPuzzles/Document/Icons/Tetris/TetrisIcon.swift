//         FILE: TetrisIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/20/23 4:44 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct TetrisIcon: IconItem, Codable, Equatable, Hashable {
        let color: Color
        let blocks: [Point]
        let rotation: TetrisRotations
        let rotatable: TetrisRotationAllowed?
        
        init( color: Color, shape: TetrisShape, rotation: TetrisRotations ) {
            self.color = color
            self.blocks = shape.blocks
            self.rotation = rotation
            self.rotatable = shape.rotatable
        }
        
        func draw( in rect: CGRect, context: CGContext ) {
            let scaleFactor = 66.0
            let blockSize = 10.0
            let gapSize = 2.0
            let padding = 4.0
            let origin = -scaleFactor / 2 + blockSize / 2 + padding
            let stepSize = ( blockSize + gapSize ) / 2
            let blockRect = CGRect(
                x: -blockSize / 2, y: -blockSize / 2, width: blockSize, height: blockSize
            )

            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
            context.scaleBy( x: rect.width / scaleFactor, y: rect.height / scaleFactor )
            context.setFillColor( color.cgColor! )

            func drawOne( block: Point ) {
                let centerX = origin + stepSize * Double( block.x )
                let centerY = origin + stepSize * Double( block.y )
                context.translateBy( x: centerX, y: centerY )
                context.fill( blockRect )
                context.translateBy( x: -centerX, y: -centerY )
            }
            
            for block in blocks {
                drawOne( block: block )
            }
            
            context.restoreGState()
        }
    }
    
    mutating func addTetrisIcon(
        point: Point, color: Color, shape: TetrisShape, rotation: TetrisRotations
    ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            let newIcon = TetrisIcon( color: color, shape: shape, rotation: rotation )
            icons.insert( Icon( position: point, type: .tetris, icon: newIcon ) )
        }
    }
}