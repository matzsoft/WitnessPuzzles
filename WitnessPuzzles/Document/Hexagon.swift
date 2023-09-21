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
            position.isPuzzleSpace( puzzle: puzzle ) && position.isPath
        }
    }

    func drawHexagons( context: CGContext ) -> Void {
        let hexHeight = CGFloat( sqrt( 3 ) / 2 )
        let hexPoints = [
            CGPoint( x:  1, y: 0 ), CGPoint( x:  0.5, y:  hexHeight ), CGPoint( x: -0.5, y:  hexHeight ),
            CGPoint( x: -1, y: 0 ), CGPoint( x: -0.5, y: -hexHeight ), CGPoint( x:  0.5, y: -hexHeight )
        ]
        
        func draw( hexagon: Hexagon ) {
            let extent = hexagon.extent( puzzle: self )
            context.saveGState()
            context.beginPath()
            context.translateBy( x: extent.midX, y: extent.midY )
            context.scaleBy( x: extent.width / 2, y: extent.height / 2 )
            context.addLines( between: hexPoints )
            context.setFillColor( hexagon.color.cgColor! )
            context.fillPath()
            context.restoreGState()
        }
        
        for hexagon in hexagons {
            draw( hexagon: hexagon )
            if let wrapped = type.wrap( point: hexagon.position, puzzle: self ) {
                draw( hexagon: Hexagon( position: wrapped, color: hexagon.color ) )
            }
        }
    }

    func hexagonExists( point: Point ) -> Bool {
        return conflictsWithHexagons( point: point )
    }
    
    func isHexagonPositionOK( point: Point ) -> Bool {
        return Hexagon.isValid( position: point, puzzle: self ) &&
              !conflictsWithGaps( point: point ) &&
              !conflictsWithMissings( point: point ) &&
              !conflictsWithHexagons( point: point )
    }
    
    mutating func removeHexagon( point: Point ) -> Void {
        hexagons = hexagons.filter { $0.position != point }
    }

    mutating func addHexagon( point: Point, info: IconInfo ) -> Void {
        guard isHexagonPositionOK( point: point ) else { return }
        
        hexagons.insert( Hexagon( position: point, color: info.color ) )
    }
}
