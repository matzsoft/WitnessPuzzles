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
            position.user2puzzle( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( position.x ) && puzzle.validSymbolY.contains( position.y )
                && ( ( ( position.x ^ position.y ) & 1 ) == 1 )
        }
    }
    
    struct Repaints {
        var repaints = Set<Point>()
        
        mutating func add( line: Point, puzzle: WitnessPuzzlesDocument ) -> Void {
            guard puzzle.validSymbolX.contains( line.x ) else { return }
            guard puzzle.validSymbolY.contains( line.y ) else { return }
            if puzzle.missings.contains( where: { $0.position == line } ) { return }
            
            repaints.insert( line )
        }
        
        mutating func add( missing: Missing, puzzle: WitnessPuzzlesDocument ) -> Void {
            if missing.position.x.isMultiple( of: 2 ) {
                // A vertical line
                add( line: Point( missing.position.x - 1, missing.position.y + 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x, missing.position.y + 2 ), puzzle: puzzle )
                add( line: Point( missing.position.x + 1, missing.position.y + 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x - 1, missing.position.y - 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x, missing.position.y - 2 ), puzzle: puzzle )
                add( line: Point( missing.position.x + 1, missing.position.y - 1 ), puzzle: puzzle )
            } else {
                // A horizontal line
                add( line: Point( missing.position.x - 1, missing.position.y + 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x - 2, missing.position.y ), puzzle: puzzle )
                add( line: Point( missing.position.x - 1, missing.position.y - 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x + 1, missing.position.y + 1 ), puzzle: puzzle )
                add( line: Point( missing.position.x + 2, missing.position.y ), puzzle: puzzle )
                add( line: Point( missing.position.x + 1, missing.position.y - 1 ), puzzle: puzzle )
            }
        }
        
        func draw( context: CGContext, puzzle: WitnessPuzzlesDocument ) -> Void {
            for repaint in repaints {
                let user = repaint.user2puzzle( puzzle: puzzle )
                let cornerRadius = CGFloat( puzzle.lineWidth ) / 2

                context.saveGState()
                context.setFillColor( puzzle.foreground.cgColor! )
                context.beginPath()
                if repaint.x.isMultiple( of: 2 ) {
                    // A vertical line
                    context.translateBy(
                        x: CGFloat( user.x - puzzle.lineWidth / 2 ),
                        y: CGFloat( user.y - puzzle.blockWidth / 2 - puzzle.lineWidth )
                    )
                    context.addPath(
                        CGPath(
                            roundedRect: CGRect(
                                origin: CGPoint( x: 0, y: 0 ),
                                size: CGSize(
                                    width: puzzle.lineWidth,
                                    height: puzzle.blockWidth + 2 * puzzle.lineWidth
                                )
                            ),
                            cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
                    )
                } else {
                    // A horizontal line
                    context.translateBy(
                        x: CGFloat( user.x - puzzle.blockWidth / 2 - puzzle.lineWidth ),
                        y: CGFloat( user.y - puzzle.lineWidth / 2 )
                    )
                    context.addPath(
                        CGPath(
                            roundedRect: CGRect(
                                origin: CGPoint( x: 0, y: 0 ),
                                size: CGSize(
                                    width: puzzle.blockWidth + 2 * puzzle.lineWidth,
                                    height: puzzle.lineWidth
                                )
                            ),
                            cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
                    )
                }
                context.fillPath()
                context.restoreGState()
            }
        }
    }

    func drawMissings( context: CGContext ) -> Void {
        var repaints = Repaints()
        
        for missing in missings {
            let user = missing.location( puzzle: self )
            context.saveGState()
            context.setFillColor( background.cgColor! )
            if missing.position.x.isMultiple( of: 2 ) {
                // A vertical line
                context.translateBy(
                    x: CGFloat( user.x - lineWidth / 2 ),
                    y: CGFloat( user.y - blockWidth / 2 - lineWidth )
                )
                context.fill( [
                    CGRect( x: 0, y: 0, width: lineWidth, height: blockWidth + 2 * lineWidth )
                ] )
            } else {
                // A horizontal line
                context.translateBy(
                    x: CGFloat( user.x - blockWidth / 2 - lineWidth ),
                    y: CGFloat( user.y - lineWidth / 2 )
                )
                context.fill( [
                    CGRect( x: 0, y: 0, width: blockWidth + 2 * lineWidth, height: lineWidth )
                ] )
            }
            repaints.add( missing: missing, puzzle: self )
            context.restoreGState()
        }
        
        repaints.draw( context: context, puzzle: self )
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
