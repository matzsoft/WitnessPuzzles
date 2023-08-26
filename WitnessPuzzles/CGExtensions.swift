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
