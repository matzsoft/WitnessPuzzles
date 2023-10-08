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
            position.isPath && puzzle.isConnected( point: position )
        }
        
        func draw( context: CGContext, puzzle: WitnessPuzzlesDocument, alpha: CGFloat ) -> Void {
            context.setFillColor( puzzle.foreground.cgColor!.copy( alpha: alpha )! )
            context.fillEllipse( in: extent( puzzle: puzzle ) )
            if let wrapped = puzzle.type.wrap( point: position, puzzle: puzzle ) {
                context.fillEllipse( in: Start( position: wrapped ).extent( puzzle: puzzle ) )
            }
        }
    }

    func drawStarts( context: CGContext, guiState: GuiState? ) -> Void {
        let guiState = guiState?.selectedTool == .starts ? guiState : nil
        context.saveGState()
        
        starts.filter { $0.position != guiState?.location }.forEach {
            $0.draw( context: context, puzzle: self, alpha: 1.0 )
        }
        if let hovered = starts.first( where: { $0.position == guiState?.location } ) {
            hovered.draw( context: context, puzzle: self, alpha: 0.5 )
        } else if let location = guiState?.location, isStartPositionOK( point: location ) {
            Start( position: location ).draw( context: context, puzzle: self, alpha: 0.75 )
        }
    
        context.restoreGState()
    }
    
    func startExists( point: Point ) -> Bool {
        return starts.contains { point == $0.position }
    }
    
    func isStartPositionOK( point: Point ) -> Bool {
        return Start.isValid( position: point, puzzle: self ) &&
                !starts.contains { point == $0.position } &&
                !finishes.contains { point == $0.position } &&
                !gaps.contains { point == $0.position } &&
                !missings.contains { point == $0.position }
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
