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
            position.isPuzzleSpace( puzzle: puzzle ) && position.isLine
        }
    }
    
    func missingExists( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        return conflictsWithMissings( point: userPoint )
    }
    
    func isMissingPositionOK( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newMissing = Missing( position: userPoint )
        
        guard newMissing.isValid( puzzle: self ),
              !conflictsWithStarts( item: newMissing ),
              !conflictsWithFinishes( item: newMissing ),
              !conflictsWithGaps( item: newMissing ),
              !conflictsWithHexagons( item: newMissing )
        else {
            NSSound.beep();
            return false
        }

        return true
    }
    
    mutating func removeMissing( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        let newMissing = Missing( position: userPoint )

        guard newMissing.isValid( puzzle: self ),
              conflictsWithMissings( item: newMissing )
        else {
            NSSound.beep();
            return
        }

        missings = missings.filter { $0.position != userPoint }
    }

    mutating func addMissing( viewPoint: CGPoint ) -> Void {
        guard isMissingPositionOK( viewPoint: viewPoint ) else { return }
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        
        missings.insert( Missing( position: userPoint ) )
    }
}
