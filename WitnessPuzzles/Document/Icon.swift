//         FILE: Icon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 5:30 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Icon: PuzzleItem {
        let position: Point
        let color: Color

        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Icon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isBlock
        }
    }

    func drawIcons( context: CGContext ) -> Void {
        let iconWidth = 0.5 * CGFloat( blockWidth )
        let cornerRadius = iconWidth / 4
        let rect = CGRect( x: -iconWidth / 2, y: -iconWidth / 2, width: iconWidth, height: iconWidth )
        
        func draw( icon: Icon ) {
            let drawing = icon.location( puzzle: self )

            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.setFillColor( icon.color.cgColor! )
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
        
        for icon in icons {
            draw( icon: icon )
            if type.needsWrap( point: icon.position, puzzle: self ) {
                let newPosition = Point( validSymbolX.upperBound + 1, icon.position.y )
                draw( icon: Icon( position: newPosition, color: icon.color ) )
            }
        }
        
        context.fillPath()
        context.restoreGState()
    }
    
    func iconExists( point: Point ) -> Bool {
        return conflictsWithIcons( point: point )
    }
    
    func isIconPositionOK( point: Point ) -> Bool {
        return Icon.isValid( position: point, puzzle: self )
    }
    
    mutating func removeIcon( point: Point ) -> Void {
        icons = icons.filter { $0.position != point }
    }

    mutating func addIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            icons.insert( Icon( position: point, color: color ) )
        }
    }
}
