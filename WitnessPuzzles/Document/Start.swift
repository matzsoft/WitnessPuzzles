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
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle )
            return CGRect(
                x: center.x - puzzle.startRadius, y: center.y - puzzle.startRadius,
                width: 2 * puzzle.startRadius, height: 2 * puzzle.startRadius
            )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Start.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isPath
        }
    }

    func drawStarts( context: CGContext ) -> Void {
        context.saveGState()
        context.setFillColor( foreground.cgColor! )
        context.beginPath()
        
        for start in starts {
            context.addEllipse( in: start.extent( puzzle: self ) )
            if let wrapped = type.wrap( point: start.position, puzzle: self ) {
                context.addEllipse( in: Start( position: wrapped ).extent( puzzle: self ) )
            }
        }
        
        context.fillPath()
        context.restoreGState()
    }
    
    func startExists( point: Point ) -> Bool {
        return conflictsWithStarts( point: point )
    }
    
    func isStartPositionOK( point: Point ) -> Bool {
        return Start.isValid( position: point, puzzle: self ) &&
              !conflictsWithFinishes( point: point ) &&
              !conflictsWithGaps( point: point ) &&
              !conflictsWithMissings( point: point )
    }
    
    mutating func removeStart( point: Point ) -> Void {
        starts = starts.filter { $0.position != point }
    }

    mutating func addStart( point: Point ) -> Void {
        guard isStartPositionOK( point: point ) else { return }
        
        if Start.isValid( position: point, puzzle: self ) {
            starts.insert( Start( position: point ) )
        }
    }
}
