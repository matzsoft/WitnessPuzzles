//         FILE: Hexagon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/2/23 11:10 AM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Hexagon: PuzzleItem {
        let position: Point
        let color: Color
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle ).cgPoint
            let radius = CGFloat( puzzle.lineWidth ) / 2
            return CGRect(
                x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius
            )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Hexagon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPath && puzzle.isConnected( point: position )
        }
        
        static let hexPoints = [
            CGPoint( x:  1, y: 0 ), CGPoint( x:  0.5, y:  sqrt( 3 ) / 2 ),
            CGPoint( x: -0.5, y:  sqrt( 3 ) / 2 ), CGPoint( x: -1, y: 0 ),
            CGPoint( x: -0.5, y: -sqrt( 3 ) / 2 ), CGPoint( x:  0.5, y: -sqrt( 3 ) / 2 )
        ]
        
        static func draw( extent: CGRect, context: CGContext, color: Color ) -> Void {
            context.saveGState()
            context.beginPath()
            context.translateBy( x: extent.midX, y: extent.midY )
            context.scaleBy( x: 0.4 * extent.width, y: 0.4 * extent.height )
            context.addLines( between: hexPoints )
            context.setFillColor( color.cgColor! )
            context.fillPath()
            context.restoreGState()
        }
    }

    func drawHexagons( context: CGContext ) -> Void {
        for hexagon in hexagons {
            Hexagon.draw( extent: hexagon.extent( puzzle: self ), context: context, color: hexagon.color )
            if let wrapped = type.wrap( point: hexagon.position, puzzle: self ) {
                let new = Hexagon( position: wrapped, color: hexagon.color )
                Hexagon.draw( extent: new.extent( puzzle: self ), context: context, color: new.color )
            }
        }
    }

    func hexagonExists( point: Point ) -> Bool {
        return hexagons.contains { point == $0.position }
    }
    
    func isHexagonPositionOK( point: Point ) -> Bool {
        return Hexagon.isValid( position: point, puzzle: self ) &&
                !gaps.contains { point == $0.position } &&
                !missings.contains { point == $0.position } &&
                !hexagons.contains { point == $0.position }
    }
    
    mutating func removeHexagon( point: Point ) -> Void {
        hexagons = hexagons.filter { $0.position != point }
    }

    mutating func addHexagon( point: Point, info: IconInfo ) -> Void {
        guard isHexagonPositionOK( point: point ) else { return }
        
        hexagons.insert( Hexagon( position: point, color: info.color ) )
    }
}
