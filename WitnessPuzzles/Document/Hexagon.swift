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
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( position.x ) && puzzle.validSymbolY.contains( position.y )
                && ( ( position.x & position.y & 1 ) == 0 )
        }
    }

    func drawHexagons( context: CGContext ) -> Void {
        let hexHeight = CGFloat( sqrt( 3 ) / 2 )
        let hexPoints = [
            CGPoint( x:  1, y: 0 ), CGPoint( x:  0.5, y:  hexHeight ), CGPoint( x: -0.5, y:  hexHeight ),
            CGPoint( x: -1, y: 0 ), CGPoint( x: -0.5, y: -hexHeight ), CGPoint( x:  0.5, y: -hexHeight )
        ]
        
        for hexagon in hexagons {
            let user = hexagon.location( puzzle: self )
            context.saveGState()
            context.beginPath()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            context.scaleBy( x: CGFloat( lineWidth ) / 2, y: CGFloat( lineWidth ) / 2 )
            context.addLines( between: hexPoints )
            context.setFillColor( hexagon.color.cgColor! )
            context.fillPath()
            context.restoreGState()
        }
    }

    mutating func removeHexagon( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newHexagon = Hexagon( position: userPoint, color: .black )
        
        guard newHexagon.isValid( puzzle: self ),
              !conflictsWithGaps( item: newHexagon ),
              !conflictsWithMissings( item: newHexagon )
        else {
            NSSound.beep();
            return true
        }

        if conflictsWithHexagons( item: newHexagon ) {
            hexagons = hexagons.filter { $0.position != userPoint }
            return true
        }
        
        return false
    }

    mutating func addHexagon( viewPoint: CGPoint, color: Color ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newHexagon = Hexagon( position: userPoint, color: color )
        
        guard newHexagon.isValid( puzzle: self ),
              !conflictsWithGaps( item: newHexagon ),
              !conflictsWithMissings( item: newHexagon ),
              !conflictsWithHexagons( item: newHexagon )
        else {
            NSSound.beep();
            return
        }

        hexagons.insert( newHexagon )
    }
}
