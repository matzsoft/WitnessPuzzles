//         FILE: CGExtensions.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/25/23 12:12 PM

import SwiftUI
import Foundation
import CoreGraphics

extension WitnessPuzzlesDocument {
    struct Point: Equatable, Hashable, Codable {
        let x: Int
        let y: Int
        
        init( _ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
        
        func puzzle2user( puzzle: WitnessPuzzlesDocument ) -> Point {
            let x = x * ( puzzle.lineWidth + puzzle.blockWidth ) / 2 + puzzle.lineWidth / 2
            let y = y * ( puzzle.lineWidth + puzzle.blockWidth ) / 2 + puzzle.lineWidth / 2
            return Point( x, y )
        }
        
        static func fromView2puzzle( from: CGPoint, puzzle: WitnessPuzzlesDocument ) -> Point {
            let context = puzzle.getContext()
            puzzle.setOrigin( context: context )
            let user = context.convertToUserSpace( from )
            let resolution = Double( puzzle.lineWidth + puzzle.blockWidth ) / 2
            let offset = Double( puzzle.lineWidth ) / 2
            let x = Int( ( ( user.x - offset ) / resolution ).rounded() )
            let y = Int( ( ( user.y - offset ) / resolution ).rounded() )
            
            return Point( x, y )
        }
    }
    
    
    enum Direction: String, Codable {
        case north, northeast, east, southeast, south, southwest, west, northwest
        
        var vector: Point {
            switch self {
            case .north:     return Point( 0, 1 )
            case .northeast: return Point( 1, 1 )
            case .east:      return Point( 1, 0 )
            case .southeast: return Point( 1, -1 )
            case .south:     return Point( 0, -1 )
            case .southwest: return Point( -1, -1 )
            case .west:      return Point( -1, 0 )
            case .northwest: return Point( -1, 1 )
            }
        }
    }
}
