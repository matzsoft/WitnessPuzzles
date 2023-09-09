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
        
        func baseWidth( puzzle: WitnessPuzzlesDocument ) -> Int {
            switch self {
            case .rectangle:
                return ( puzzle.width + 1 ) * puzzle.lineWidth + puzzle.width * puzzle.blockWidth
            case .cylinder:
                return puzzle.width * ( puzzle.lineWidth + puzzle.blockWidth )
            }
        }
        
        func userWidth( puzzle: WitnessPuzzlesDocument ) -> CGFloat {
            switch self {
            case .rectangle:
                return CGFloat(
                    puzzle.baseWidth + 2 * puzzle.padding + puzzle.extraLeft() + puzzle.extraRight()
                )
            case .cylinder:
                return CGFloat( puzzle.baseWidth )
            }
        }
        
        func validPuzzleX( puzzle: WitnessPuzzlesDocument ) -> ClosedRange<Int> {
            switch self {
            case .rectangle: return 0 ... ( 2 * puzzle.width )
            case .cylinder:  return 0 ... ( 2 * puzzle.width - 1 )
            }
        }
        
        func xOriginOffset( puzzle: WitnessPuzzlesDocument ) -> CGFloat {
            switch self {
            case .rectangle: return CGFloat( puzzle.padding + puzzle.extraLeft() )
            case .cylinder:  return CGFloat( -puzzle.lineWidth ) / 4
            }
        }
        
        func needsWrap( point: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            switch self {
            case .rectangle: return false
            case .cylinder:  return point.x == validPuzzleX( puzzle: puzzle ).lowerBound
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
            if ( line.y & 1 ) - ( line.x & 1 ) > 0 {
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
            if type.needsWrap( point: line, puzzle: self ) {
                draw( line: Point( validSymbolX.upperBound + 1, line.y ) )
            }
        }
    }
}
