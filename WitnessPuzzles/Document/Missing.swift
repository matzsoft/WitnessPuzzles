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
            Missing.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isLine
        }
    }
    
    func missingExists( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        return conflictsWithMissings( point: userPoint )
    }
    
    func isMissingPositionOK( viewPoint: CGPoint ) -> Bool {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        
        return Missing.isValid( position: userPoint, puzzle: self ) &&
              !conflictsWithStarts( point: userPoint ) &&
              !conflictsWithFinishes( point: userPoint ) &&
              !conflictsWithGaps( point: userPoint ) &&
              !conflictsWithHexagons( point: userPoint )
    }
    
    mutating func removeMissing( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        missings = missings.filter { $0.position != userPoint }
    }

    mutating func addMissing( viewPoint: CGPoint ) -> Void {
        guard isMissingPositionOK( viewPoint: viewPoint ) else { return }
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )
        
        if Missing.isValid( position: userPoint, puzzle: self ) {
            missings.insert( Missing( position: userPoint ) )
        }
    }
}
