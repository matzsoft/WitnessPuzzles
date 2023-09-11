//         FILE: Gap.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/2/23 10:05 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Gap: PuzzleItem {
        let position: Point
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Gap.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isLine
        }
    }

    func drawGaps( context: CGContext ) -> Void {
        func draw( gap: Gap ) {
            let user = gap.location( puzzle: self )
            context.saveGState()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            context.scaleBy( x: CGFloat( lineWidth ) / 6, y: CGFloat( lineWidth ) / 6 )
            context.setFillColor( background.cgColor! )
            if gap.position.isHorizontal {
                context.fill( [ CGRect( x: -3, y: -2, width: 6, height: 4 ) ] )
            } else {
                context.fill( [ CGRect( x: -2, y: -3, width: 4, height: 6 ) ] )
            }
            context.restoreGState()
        }
        
        for gap in gaps {
            draw( gap: gap )
            if type.needsWrap( point: gap.position, puzzle: self ) {
                draw( gap: Gap( position: Point( validSymbolX.upperBound + 1, gap.position.y ) ) )
            }
        }
    }
    
    func gapExists( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        return conflictsWithGaps( point: userPoint )
    }
    
    func isGapPositionOK( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        
        guard Gap.isValid( position: userPoint, puzzle: self ),
              !conflictsWithStarts( point: userPoint ),
              !conflictsWithFinishes( point: userPoint ),
              !conflictsWithMissings( point: userPoint ),
              !conflictsWithHexagons( point: userPoint )
        else {
            NSSound.beep();
            return false
        }

        return true
    }
    
    mutating func removeGap( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        gaps = gaps.filter { $0.position != userPoint }
    }

    mutating func addGap( viewPoint: CGPoint ) -> Void {
        guard isGapPositionOK( viewPoint: viewPoint ) else { return }
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        
        if Gap.isValid( position: userPoint, puzzle: self ) {
            gaps.insert( Gap( position: userPoint ) )
        }
    }
}
