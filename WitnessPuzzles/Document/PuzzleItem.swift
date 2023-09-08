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
        starts.contains(where: { item.position == $0.position } )
    }
    
    func conflictsWithFinishes( item: any PuzzleItem ) -> Bool {
        finishes.contains(where: { item.position == $0.position } )
    }
    
    func conflictsWithGaps( item: any PuzzleItem ) -> Bool {
        gaps.contains(where: { item.position == $0.position } )
    }
    
    func conflictsWithMissings( item: any PuzzleItem ) -> Bool {
        missings.contains(where: { item.position == $0.position } )
    }
    
    func conflictsWithHexagons( item: any PuzzleItem ) -> Bool {
        hexagons.contains(where: { item.position == $0.position } )
    }
}
