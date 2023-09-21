//         FILE: TetrisShapes.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/20/23 2:59 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    enum TetrisRotations: Int, CaseIterable, Identifiable, Codable {
        case zero, one, two, three
        var id: Int { rawValue }
    }
    
    enum TetrisRotationAllowed: Int, CaseIterable, Identifiable, Codable {
        case two = 2, ten = 10
        var id: Int { rawValue }
    }
    
    struct TetrisShape: Hashable, Identifiable, Codable {
        let blocks: [Point]
        let allowedRotations: [TetrisRotations]
        let rotatable: TetrisRotationAllowed?
        
        var id: UUID { UUID() }
        
        init(
            blocks: [ ( Int,Int ) ], rotatable: TetrisRotationAllowed?, allowedRotations: TetrisRotations...
        ) {
            self.blocks = blocks.map { Point( $0.0, $0.1 ) }
            self.allowedRotations = allowedRotations
            self.rotatable = rotatable
        }
    }
    
    static let tetrisShapes = [
        // ▉
        TetrisShape( blocks: [ (4,4) ], rotatable: nil, allowedRotations: .zero ),
        // ▉▉
        TetrisShape( blocks: [ (3,4), (5,4) ], rotatable: .two, allowedRotations: .one ),
        //  ▉
        // ▉
        TetrisShape( blocks: [ (3,3), (5,5) ], rotatable: .two, allowedRotations: .one ),
        // ▉▉▉
        TetrisShape( blocks: [ (2,4), (4,4), (6,4) ], rotatable: .two, allowedRotations: .one ),
        // ▉
        // ▉▉
        TetrisShape(
            blocks: [ (4,4), (6,4), (4,6) ], rotatable: .two, allowedRotations: .one, .two, .three
        ),
        //  ▉
        // ▉ ▉
        TetrisShape(
            blocks: [ (2,3), (6,3), (4,5) ], rotatable: .two, allowedRotations: .one, .two, .three
        ),
        // ▉▉
        // ▉▉
        TetrisShape( blocks: [ (3,3), (5,3), (3,5), (5,5) ], rotatable: nil, allowedRotations: .zero ),
    ]
}
