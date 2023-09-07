//         FILE: Finish.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/1/23 11:15 AM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Finish: PuzzleItem, Codable, Hashable {
        let position: Point
        let direction: Direction
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            let converted = position.user2puzzle( puzzle: puzzle )
            let offset = offset( distance: puzzle.lineWidth / 2, extra: 1 )
            return Point( converted.x + offset.x, converted.y + offset.y )
        }
        
        var angle: Double {
            switch direction {
            case .north:     return 0 * Double.pi / 4
            case .northeast: return 7 * Double.pi / 4
            case .east:      return 6 * Double.pi / 4
            case .southeast: return 5 * Double.pi / 4
            case .south:     return 4 * Double.pi / 4
            case .southwest: return 3 * Double.pi / 4
            case .west:      return 2 * Double.pi / 4
            case .northwest: return 1 * Double.pi / 4
            }
        }
        
        func offset( distance: Int, extra: Int ) -> Point {
            let vector = direction.vector
            switch direction {
            case .north, .east, .south, .west:
                return Point( vector.x * ( distance + extra ), vector.y * ( distance + extra ) )
            case .northeast, .southeast, .southwest, .northwest:
                return Point( vector.x * distance, vector.y * distance )
            }
        }
        
        static func validDirection( for point: Point, in puzzle: WitnessPuzzlesDocument ) -> Direction? {
            let validX = puzzle.validSymbolX
            let validY = puzzle.validSymbolY
            
            switch ( point.x, point.y ) {
            case ( validX.lowerBound, validY.lowerBound ): return .southwest
            case ( validX.lowerBound, validY.upperBound ): return .northwest
            case ( validX.upperBound, validY.upperBound ): return .northeast
            case ( validX.upperBound, validY.lowerBound ): return .southeast
            case ( validX.lowerBound, validY ):            return .west
            case ( validX.upperBound, validY ):            return .east
            case ( validX, validY.lowerBound ):            return .south
            case ( validX, validY.upperBound ):            return .north
            default: return nil
            }
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            guard let goodDirection = Finish.validDirection( for: position, in: puzzle ) else {
                return false
            }
            
            return direction == goodDirection
        }
    }

    func drawFinishes( context: CGContext ) -> Void {
        for finish in finishes {
            let user = finish.location( puzzle: self )
            context.saveGState()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            context.addEllipse( in: CGRect(
                x: -finishRadius, y: -finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            
            context.rotate( by: finish.angle )
            context.addRect( CGRect(
                x: -finishRadius, y: -2 * finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            context.restoreGState()
        }
    }

    mutating func toggleFinish( viewPoint: CGPoint ) -> Void {
        let userPoint = Point.fromView2puzzle( from: viewPoint, puzzle: self )

        guard let goodDirection = Finish.validDirection( for: userPoint, in: self ) else {
            NSSound.beep();
            return
        }

        if finishes.contains( where: { $0.position == userPoint } ) {
            finishes = finishes.filter { $0.position != userPoint }
        } else {
            finishes.insert( Finish( position: userPoint, direction: goodDirection ) )
        }
    }
}
