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
        let color: Color
        let count: Int
        
        internal init( color: Color, count: Int ) {
            guard 1 <= count && count <= 3 else { fatalError( "Invalid triangles icon count \(count)." ) }
            self.color = color
            self.count = count
        }
        
        func draw( in rect: CGRect, context: CGContext ) {
            let stepSize = rect.width / 10
            let iconTop = CGPoint( x: 0, y: 2 * sqrt( 3 ) / 3 )
            let iconLeft = CGPoint( x: -1, y: -2 * sqrt( 3 ) / 6 )
            let iconRight = CGPoint( x: 1, y: -2 * sqrt( 3 ) / 6 )

            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
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
    }
    
    mutating func addTrianglesIcon( point: Point, color: Color, count: Int ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            let newIcon = TrianglesIcon( color: color, count: count )
            icons.insert( Icon( position: point, type: .triangles, icon: newIcon ) )
        }
    }
}
