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
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle ).cgPoint
            let long = CGFloat( puzzle.lineWidth )
            let short = 2 * long / 3
            let width = position.isVertical ? long : short
            let height = position.isVertical ? short : long
            
            return CGRect( x: center.x - width / 2, y: center.y - height / 2, width: width, height: height )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Gap.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isLine && puzzle.isConnected( point: position )
        }
    }

    func drawGaps( context: CGContext ) -> Void {
        context.saveGState()
        context.setFillColor( background.cgColor! )
        for gap in gaps {
            context.fill( [ gap.extent( puzzle: self ) ] )
            if let wrapped = type.wrap( point: gap.position, puzzle: self ) {
                context.fill( [ Gap( position: wrapped ).extent( puzzle: self ) ] )
            }
        }
        context.restoreGState()
    }
    
    func gapExists( point: Point ) -> Bool {
        return gaps.contains { point == $0.position }
    }
    
    func isGapPositionOK( point: Point ) -> Bool {
        return Gap.isValid( position: point, puzzle: self ) &&
                !starts.contains { point == $0.position } &&
                !finishes.contains { point == $0.position } &&
                !missings.contains { point == $0.position } &&
                !hexagons.contains { point == $0.position }
    }
    
    mutating func removeGap( point: Point ) -> Void {
        gaps = gaps.filter { $0.position != point }
    }

    mutating func addGap( point: Point ) -> Void {
        guard isGapPositionOK( point: point ) else { return }
        
        if Gap.isValid( position: point, puzzle: self ) {
            gaps.insert( Gap( position: point ) )
        }
    }
}
