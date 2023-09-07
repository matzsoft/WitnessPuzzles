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
            position.user2puzzle( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( position.x ) && puzzle.validSymbolY.contains( position.y )
                && ( ( position.x & position.y & 1 ) == 0 )
        }
    }

    func drawStarts( context: CGContext ) -> Void {
        for start in starts {
            let drawing = start.location( puzzle: self )
            context.addEllipse( in: CGRect(
                x: drawing.x - startRadius, y: drawing.y - startRadius,
                width: 2 * startRadius, height: 2 * startRadius
            ) )
            if start.position.x == 0 && type == .cylinder {
                let drawing = Point( 2 * width, start.position.y ).user2puzzle( puzzle: self )
                context.addEllipse( in: CGRect(
                    x: drawing.x - startRadius, y: drawing.y - startRadius,
                    width: 2 * startRadius, height: 2 * startRadius
                ) )
            }
        }
    }
    
    mutating func toggleStart( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newStart = Start( position: userPoint )
        
        guard newStart.isValid( puzzle: self ) else {
            NSSound.beep();
            return
        }

        if starts.contains( where: { $0 == newStart } ) {
            starts = starts.filter { $0 != newStart }
        } else {
            starts.insert( newStart )
        }
    }
}
