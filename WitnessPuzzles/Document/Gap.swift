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
        
        func draw( context: CGContext, puzzle: WitnessPuzzlesDocument ) -> Void {
            context.fill( extent( puzzle: puzzle ) )
            if let wrapped = puzzle.type.wrap( point: position, puzzle: puzzle ) {
                context.fill( Gap( position: wrapped ).extent( puzzle: puzzle ) )
            }
        }
    }

    func drawGaps( context: CGContext, guiState: GuiState? ) -> Void {
        let guiState = guiState?.selectedTool == .gaps ? guiState : nil
        context.saveGState()

        context.setFillColor( background.cgColor! )
        for gap in gaps {
            if guiState?.location == gap.position {
                context.setFillColor( background.cgColor!.copy( alpha: 0.5 )! )
            } else {
                context.setFillColor( background.cgColor! )
            }
            gap.draw( context: context, puzzle: self )
        }
        
        if let location = guiState?.location, isGapPositionOK( point: location ) {
            context.setFillColor( background.cgColor!.copy( alpha: 0.75 )! )
            Gap( position: location ).draw( context: context, puzzle: self )
        }
    
        context.restoreGState()
    }
    
    func gapExists( point: Point ) -> Bool {
        return gaps.contains { point == $0.position }
    }
    
    func isGapPositionOK( point: Point ) -> Bool {
        return Gap.isValid( position: point, puzzle: self ) &&
                !gaps.contains { point == $0.position } &&
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
