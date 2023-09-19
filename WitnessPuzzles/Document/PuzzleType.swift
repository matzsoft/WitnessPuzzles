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
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) -> Void {
            context.saveGState()
            context.setFillColor( puzzle.foreground.cgColor! )
            context.beginPath()
            switch self {
            case .rectangle: puzzle.drawPuzzle( context: context )
            case .cylinder:  puzzle.drawPuzzle( context: context )
            }
            context.fillPath()
            context.restoreGState()
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
    
    func drawPuzzle( context: CGContext ) -> Void {
        let ( lineRect, cornerRadius ) = lineGeometry

        func draw( line: Point ) {
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
        
        for line in lines {
            draw( line: line )
            if let wrapped = type.wrap( point: line, puzzle: self ) {
                draw( line: wrapped )
            }
        }
    }
}
