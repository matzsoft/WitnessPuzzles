//         FILE: Missing.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/4/23 11:33 AM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Missing: PuzzleItem {
        let position: Point
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( position.x ) && puzzle.validSymbolY.contains( position.y )
                && ( ( ( position.x ^ position.y ) & 1 ) == 1 )
        }
    }
    
    mutating func toggleMissing( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newMissing = Missing( position: userPoint )
        
        guard newMissing.isValid( puzzle: self ),
              !conflictsWithStarts( item: newMissing ),
              !conflictsWithFinishes( item: newMissing ),
              !conflictsWithGaps( item: newMissing ),
              !conflictsWithHexagons( item: newMissing )
        else {
            NSSound.beep();
            return
        }

        if conflictsWithMissings( item: newMissing ) {
            missings = missings.filter { $0.position != userPoint }
        } else {
            missings.insert( newMissing )
        }
    }
}
