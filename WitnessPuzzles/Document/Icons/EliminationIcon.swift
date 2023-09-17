//         FILE: EliminationIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/16/23 5:13 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct EliminationIcon: IconItem, Codable, Equatable, Hashable {
        let position: Point
        let color: Color
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) {
            let iconWidth = 27 * CGFloat( puzzle.blockWidth ) / 220
            let rect = CGRect( x: -0.5, y: 0, width: iconWidth, height: 2 * iconWidth )
            let drawing = location( puzzle: puzzle )

            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.scaleBy( x: iconWidth, y: iconWidth )
            context.setFillColor( color.cgColor! )
            context.fill( [ rect ] )
            context.rotate( by: 2 * Double.pi / 3 )
            context.fill( [ rect ] )
            context.rotate( by: 2 * Double.pi / 3 )
            context.fill( [ rect ] )
            context.restoreGState()
        }
        
        func move( to: Point ) -> any IconItem {
            EliminationIcon( position: to, color: color )
        }
    }
    
    mutating func addEliminationIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            let newIcon = EliminationIcon( position: point, color: color )
            icons.insert( Icon( type: .elimination, icon: newIcon ) )
        }
    }
}
