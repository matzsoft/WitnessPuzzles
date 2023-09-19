//         FILE: StarIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/15/23 4:40 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct StarIcon: IconItem, Codable, Equatable, Hashable {
        let position: Point
        let color: Color
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            StarIcon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isBlock
        }
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) -> Void {
            let iconWidth = 0.5 * CGFloat( puzzle.blockWidth )
            let rect = CGRect( x: -iconWidth / 2, y: -iconWidth / 2, width: iconWidth, height: iconWidth )
            let drawing = position.puzzle2user( puzzle: puzzle )
            
            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.setFillColor( color.cgColor! )
            context.fill( [ rect ] )
            context.rotate( by: Double.pi / 4 )
            context.fill( [ rect ] )
            context.restoreGState()
        }
        
        func move( to: Point ) -> any IconItem {
            StarIcon( position: to, color: color )
        }
    }
    
    mutating func addStarIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            icons.insert( Icon( type: .star, icon: StarIcon( position: point, color: color ) ) )
        }
    }
}
