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
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle )
            let short = puzzle.lineWidth
            let long = puzzle.lineWidth + puzzle.blockWidth
            let width = position.isVertical ? short : long
            let height = position.isVertical ? long : short
            
            return CGRect( x: center.x - width / 2, y: center.y - height / 2, width: width, height: height )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Missing.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isLine
        }
    }
    
    func missingExists( point: Point ) -> Bool {
        return missings.contains { point == $0.position }
    }
    
    func isMissingPositionOK( point: Point ) -> Bool {
        return Missing.isValid( position: point, puzzle: self ) &&
                !starts.contains { point == $0.position } &&
                !finishes.contains { point == $0.position } &&
                !gaps.contains { point == $0.position } &&
                !hexagons.contains { point == $0.position }
    }
    
    mutating func removeMissing( point: Point ) -> Void {
        missings = missings.filter { $0.position != point }
    }

    mutating func addMissing( point: Point ) -> Void {
        guard isMissingPositionOK( point: point ) else { return }
        
        if Missing.isValid( position: point, puzzle: self ) {
            missings.insert( Missing( position: point ) )
        }
    }
}
