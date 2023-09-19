//         FILE: TrianglesIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/17/23 9:39 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct TrianglesIcon: IconItem, Codable, Equatable, Hashable {
        let position: Point
        let color: Color
        let count: Int
        
        internal init( position: Point, color: Color, count: Int ) {
            guard 1 <= count && count <= 3 else { fatalError( "Invalid triangles icon count \(count)." ) }
            self.position = position
            self.color = color
            self.count = count
        }
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) {
            let stepSize = CGFloat( puzzle.blockWidth ) / 10
            let iconTop = CGPoint( x: 0, y: 2 * sqrt( 3 ) / 3 )
            let iconLeft = CGPoint( x: -1, y: -2 * sqrt( 3 ) / 6 )
            let iconRight = CGPoint( x: 1, y: -2 * sqrt( 3 ) / 6 )
            let drawing = position.puzzle2user( puzzle: puzzle )

            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.scaleBy( x: stepSize, y: stepSize )
            context.setFillColor( color.cgColor! )
            context.beginPath()

            func drawOne( xOffset: CGFloat ) {
                context.translateBy( x: xOffset, y: 0 )
                context.addLines( between: [ iconTop, iconLeft, iconRight ] )
                context.translateBy( x: -xOffset, y: 0 )
            }
            
            switch count {
            case 1:
                drawOne( xOffset: 0 )
            case 2:
                drawOne( xOffset: -2 )
                drawOne( xOffset: 2 )
            case 3:
                drawOne( xOffset: -3 )
                drawOne( xOffset: 0 )
                drawOne( xOffset: 3)
            default:
                fatalError( "Triangles icon with invalid count \(count)." )
            }
            
            context.fillPath()
            context.restoreGState()
        }
        
        func move( to: Point ) -> any IconItem {
            EliminationIcon( position: to, color: color )
        }
    }
    
    mutating func addTrianglesIcon( point: Point, color: Color, count: Int ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            let newIcon = TrianglesIcon( position: point, color: color, count: count )
            icons.insert( Icon( type: .triangles, icon: newIcon ) )
        }
    }
}
