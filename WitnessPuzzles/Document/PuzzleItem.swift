//         FILE: PuzzleItem.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/7/23 11:04 AM

import Foundation

protocol PuzzleItem {
    var position: WitnessPuzzlesDocument.Point { get }
    func location( puzzle: WitnessPuzzlesDocument ) -> WitnessPuzzlesDocument.Point
    func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool
}
