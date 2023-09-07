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
            case .cylinder:  return CGFloat( -puzzle.cylinderRight )
            }
        }
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) -> Void {
            switch self {
            case .rectangle: puzzle.drawRectangle( context: context )
            case .cylinder:  puzzle.drawCylinder( context: context )
            }
        }
    }

    func drawRectangle( context: CGContext ) -> Void {
        let cornerRadius = CGFloat( lineWidth ) / 2

        for col in 0 ... width {
            context.addPath(
                CGPath(
                    roundedRect: CGRect(
                        origin: CGPoint( x: ( lineWidth + blockWidth ) * col, y: 0 ),
                        size: CGSize( width: lineWidth, height: baseHeight )
                    ),
                    cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
            )
        }

        for row in 0 ... height {
            context.addPath(
                CGPath(
                    roundedRect: CGRect(
                        origin: CGPoint( x: 0, y: ( lineWidth + blockWidth ) * row ),
                        size: CGSize( width: baseWidth, height: lineWidth )
                    ),
                    cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
            )
        }
    }
    
    func drawCylinder( context: CGContext ) -> Void {
        context.addRect( CGRect( x: cylinderRight, y: 0, width: cylinderLeft, height: baseHeight ) )
        context.addRect( CGRect(
            x: ( lineWidth + blockWidth ) * width, y: 0, width: cylinderRight, height: baseHeight ) )

        for col in 1 ..< width {
            context.addRect( CGRect(
                x: ( lineWidth + blockWidth ) * col, y: 0, width: lineWidth, height: baseHeight ) )
        }

        for row in 0 ... height {
            context.addRect( CGRect(
                x: 0, y: ( lineWidth + blockWidth ) * row, width: baseWidth, height: lineWidth ) )
        }
    }
}
