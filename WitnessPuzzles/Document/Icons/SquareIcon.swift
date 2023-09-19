//         FILE: SquareIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/15/23 12:19 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct SquareIcon: IconItem, Codable, Equatable, Hashable {
        let position: Point
        let color: Color
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) {
            let iconWidth = 0.5 * CGFloat( puzzle.blockWidth )
            let cornerRadius = iconWidth / 4
            let rect = CGRect( x: -iconWidth / 2, y: -iconWidth / 2, width: iconWidth, height: iconWidth )
            let drawing = position.puzzle2user( puzzle: puzzle )

            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.setFillColor( color.cgColor! )
            context.beginPath()
            context.addPath(
                CGPath(
                    roundedRect: rect, cornerWidth: cornerRadius,
                    cornerHeight: cornerRadius, transform: nil
                )
            )
            context.fillPath()
            context.restoreGState()
        }
        
        func move( to: Point ) -> any IconItem {
            SquareIcon( position: to, color: color )
        }
    }
    
    mutating func addSquareIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            icons.insert( Icon( type: .square, icon: SquareIcon( position: point, color: color ) ) )
        }
    }
}
