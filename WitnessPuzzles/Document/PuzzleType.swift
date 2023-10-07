//         FILE: PuzzleType.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/6/23 7:56 PM

import Foundation
import CoreGraphics

extension WitnessPuzzlesDocument {
    enum PuzzleType: String, CaseIterable, Codable {
        case rectangle = "Rectangle", cylinder = "Cylinder"
        
        func baseRect( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let baseHeight = ( puzzle.height + 1 ) * puzzle.lineWidth + puzzle.height * puzzle.blockWidth
            switch self {
            case .rectangle:
                let baseWidth = ( puzzle.width + 1 ) * puzzle.lineWidth + puzzle.width * puzzle.blockWidth
                return CGRect( x: 0, y: 0, width: baseWidth, height: baseHeight )
            case .cylinder:
                let baseWidth = puzzle.width * ( puzzle.lineWidth + puzzle.blockWidth )
                return CGRect( x: 0, y: 0, width: baseWidth, height: baseHeight )
            }
        }
        
        func userRect( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let baseRect = baseRect( puzzle: puzzle )
            let startsRects = puzzle.starts.map { $0.extent( puzzle: puzzle ) }
            let finishesRects = puzzle.finishes.map { $0.extent( puzzle: puzzle ) }
            let itemRects = startsRects + finishesRects
            let overflowRect = itemRects.reduce( baseRect ) { $0.union( $1 ) }
            let paddedRect = overflowRect.insetBy(
                dx: -CGFloat( puzzle.padding ), dy: -CGFloat( puzzle.padding )
            )
            
            switch self {
            case .rectangle:
                return paddedRect
            case .cylinder:
                return CGRect(
                    x: baseRect.minX + CGFloat( puzzle.lineWidth ) / 4, y: paddedRect.minY,
                    width: baseRect.width, height: paddedRect.height
                )
            }
        }
        
        func validPuzzleX( puzzle: WitnessPuzzlesDocument ) -> ClosedRange<Int> {
            switch self {
            case .rectangle: return 0 ... ( 2 * puzzle.width )
            case .cylinder:  return 0 ... ( 2 * puzzle.width - 1 )
            }
        }
        
        func wrap( point: Point, puzzle: WitnessPuzzlesDocument ) -> Point? {
            switch self {
            case .rectangle: return nil
            case .cylinder:
                if point.x == validPuzzleX( puzzle: puzzle ).lowerBound {
                    return Point( validPuzzleX( puzzle: puzzle ).upperBound + 1, point.y )
                }
                return nil
            }
        }
    }

    var lineGeometry: ( CGRect, CGFloat ) {
        let width = CGFloat( blockWidth + 2 * lineWidth )
        let height = CGFloat( lineWidth )
        let originX = -width / 2
        let originY = -height / 2
        let cornerRadius = CGFloat( lineWidth ) / 2
        let rect = CGRect(
            origin: CGPoint( x: originX, y: originY ),
            size: CGSize( width: width, height: height )
        )
        
        return ( rect, cornerRadius )
    }
    
    func drawPuzzle( context: CGContext, guiState: GuiState? ) -> Void {
        let guiState = guiState?.selectedTool == .missings ? guiState : nil
        let ( lineRect, cornerRadius ) = lineGeometry
        let lines = lines

        func draw( line: Point, alpha: CGFloat ) {
            context.saveGState()
            context.beginPath()
            
            drawOne( line: line )
            if let wrapped = type.wrap( point: line, puzzle: self ) {
                drawOne( line: wrapped )
            }
            
            context.setFillColor( foreground.cgColor!.copy( alpha: alpha )! )
            context.fillPath()
            context.restoreGState()
        }
        
        func drawOne( line: Point ) {
            let user = line.puzzle2user( puzzle: self )
            
            context.saveGState()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            if line.isVertical {
                // Rotate vertical lines info horizontal position
                context.rotate( by:  Double.pi / 2 )
            }
            
            context.addPath(
                CGPath(
                    roundedRect: lineRect, cornerWidth: cornerRadius,
                    cornerHeight: cornerRadius, transform: nil
                )
            )
            context.restoreGState()
        }
        
        lines.filter { $0 != guiState?.location }.forEach { draw( line: $0, alpha: 1.0 ) }
        if let hovered = lines.first( where: { $0 == guiState?.location } ) {
            draw( line: hovered, alpha: 0.5 )
        } else if let missing = missings.first( where: { $0.position == guiState?.location } ) {
            draw( line: missing.position, alpha: 0.75 )
        }
    }
}
