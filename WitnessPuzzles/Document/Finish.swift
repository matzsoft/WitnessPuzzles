//         FILE: Finish.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/1/23 11:15 AM

import Foundation

extension WitnessPuzzlesDocument {
    struct Finish: Codable {
        let position: Point
        let direction: Direction
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            let converted = puzzle.convert( symbol: position )
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
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            let validX = puzzle.validSymbolX
            let validY = puzzle.validSymbolY
            
            switch ( position.x, position.y ) {
            case ( validX.lowerBound, validY ): return true
            case ( validX.upperBound, validY ): return true
            case ( validX, validY.lowerBound ): return true
            case ( validX, validY.upperBound ): return true
            default: return false
            }
        }
    }
}
