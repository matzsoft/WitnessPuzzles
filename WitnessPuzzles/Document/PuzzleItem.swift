//         FILE: PuzzleItem.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/7/23 11:04 AM

import Foundation

protocol PuzzleItem: Codable, Hashable {
    var position: WitnessPuzzlesDocument.Point { get }
    func location( puzzle: WitnessPuzzlesDocument ) -> WitnessPuzzlesDocument.Point
    func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool
}


// This is what I want but Set<SomeProtocol> is not supported as of Swift 5.8.
//func isConflicting( item: any PuzzleItem, others: Set<PuzzleItem>... ) -> Bool {
//    others.contains( where: { $0.contains( where: { $0.position == item.position } ) } )
//}


extension WitnessPuzzlesDocument {
    func conflictsWithStarts( item: any PuzzleItem ) -> Bool {
        starts.contains( where: { item.position == $0.position } )
    }
    
    func conflictsWithFinishes( item: any PuzzleItem ) -> Bool {
        finishes.contains( where: { item.position == $0.position } )
    }
    
    func conflictsWithGaps( item: any PuzzleItem ) -> Bool {
        gaps.contains( where: { item.position == $0.position } )
    }
    
    func conflictsWithMissings( item: any PuzzleItem ) -> Bool {
        conflictsWithMissings( point: item.position )
    }
    
    func conflictsWithMissings( point: Point ) -> Bool {
        guard point.isPuzzleSpace( puzzle: self ) else { return true }
        switch true {
        case point.isLine:
            return missings.contains( where: { point == $0.position } )
        case point.isBlock, point.isIntersection:
            let lines = Set( [
                Point( point.x - 1, point.y ), Point( point.x, point.y - 1 ),
                Point( point.x + 1, point.y ), Point( point.x, point.y + 1 )
            ].filter { $0.isPuzzleSpace( puzzle: self ) }.map { Missing( position: $0 ) } )
            return lines.isSubset( of: missings )
        default:
            return false
        }
    }
    
    func conflictsWithHexagons( item: any PuzzleItem ) -> Bool {
        hexagons.contains( where: { item.position == $0.position } )
    }
}
