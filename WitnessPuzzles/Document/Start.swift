//         FILE: Start.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/4/23 3:07 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Start: PuzzleItem {
        let position: Point
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isPath
        }
    }

    func drawStarts( context: CGContext ) -> Void {
        context.saveGState()
        context.setFillColor( foreground.cgColor! )
        context.beginPath()
        
        let rect = CGRect(
            x: -startRadius, y: -startRadius,
            width: 2 * startRadius, height: 2 * startRadius
        )
        
        func draw( start: Start ) {
            let drawing = start.location( puzzle: self )

            context.saveGState()
            context.translateBy( x: CGFloat( drawing.x ), y: CGFloat( drawing.y ) )
            context.addEllipse( in: rect )
            context.restoreGState()
        }
        
        for start in starts {
            draw( start: start )
            if type.needsWrap( point: start.position, puzzle: self ) {
                draw( start: Start( position: Point( validSymbolX.upperBound + 1, start.position.y ) ) )
            }
        }
        
        context.fillPath()
        context.restoreGState()
    }
    
    mutating func toggleStart( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newStart = Start( position: userPoint )
        
        guard newStart.isValid( puzzle: self ),
              !conflictsWithFinishes( item: newStart ),
              !conflictsWithGaps( item: newStart ),
              !conflictsWithMissings( item: newStart )
        else {
            NSSound.beep();
            return
        }

        if conflictsWithStarts( item: newStart ) {
            starts = starts.filter { $0 != newStart }
        } else {
            starts.insert( newStart )
        }
    }
}
