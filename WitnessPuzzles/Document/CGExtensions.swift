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

struct Point: Codable {
    let x: Int
    let y: Int
    
    init( _ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}


enum Direction: Codable {
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
