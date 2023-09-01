//         FILE: Finish.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/1/23 11:15 AM

import Foundation

struct Finish: Codable {
    let location: Point
    let direction: Direction
    
    func convertedLocation( puzzle: WitnessPuzzlesDocument ) -> Point {
        let converted = puzzle.convert( symbol: location )
        let offset = direction.finishOffset( distance: puzzle.lineWidth / 2, extra: 1 )
        return Point( converted.x + offset.x, converted.y + offset.y )
    }
}
