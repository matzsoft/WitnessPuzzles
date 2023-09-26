//         FILE: TetrisShapes.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/20/23 2:59 PM

import Foundation
import SwiftUI

extension Array: Identifiable where Element: Hashable {
   public var id: Self { self }
}

extension WitnessPuzzlesDocument {
    enum TetrisRotationsCount: Int {
        case zero = 1, one, three = 4
    }
    
    /// This enum represents multiples of 90 degrees.
    enum TetrisRotations: Int, CaseIterable, Identifiable, Codable {
        case zero, one, two, three
        var id: Int { rawValue }
    }
    
    /// This enum represents multiples of 30 degrees.
    enum TetrisRotationAllowed: Int, CaseIterable, Identifiable, Codable {
        case two = 2, ten = 10
        var id: Int { rawValue }
    }
    
    struct TetrisInfo {
        struct TetrisGroupInfo {
            var shape: Int
            var shapes: [TetrisShapeInfo]
        }
        
        struct TetrisShapeInfo {
            let shape: Int
            var rotation: TetrisRotations
            var rotatable: Bool
        }
        
        var group: Int
        var groups: [TetrisGroupInfo]
        var negated: Bool
        
        init() {
            group = 0
            groups = WitnessPuzzlesDocument.tetrisShapes.enumerated()
                .reduce( into: [ Int : [Int] ]() ) {
                    $0[ $1.element.blocks.count, default: [] ].append( $1.offset )
                }
                .sorted( by: { $0.key < $1.key } )
                .map { TetrisGroupInfo( shape: 0, shapes: $0.value.map {
                    TetrisShapeInfo( shape: $0, rotation: .zero, rotatable: false )
                } ) }
            negated = false
        }
    }
    
    struct TetrisShape: Hashable, Identifiable, Codable {
        let blocks: [Point]
        let allowedRotations: [TetrisRotations]
        let rotatable: TetrisRotationAllowed?
        
        var id: UUID { UUID() }
        
        init(
            blocks: [ (Int,Int) ], rotations: TetrisRotationsCount, display: TetrisRotationAllowed? = nil
        ) {
            if rotations == .zero && display != nil { fatalError( "Invalid TetrisShape setup." ) }
            if rotations != .zero && display == nil { fatalError( "Invalid TetrisShape setup." ) }
            
            self.blocks = blocks.map { Point( $0.0, $0.1 ) }
            switch rotations {
            case .zero:
                self.allowedRotations = [ .zero ]
            case .one:
                self.allowedRotations = [ .zero, .one ]
            case .three:
                self.allowedRotations = [ .zero, .one, .two, .three ]
            }
            self.rotatable = display
        }
    }
    
    static let tetrisShapes = [
        // ▉
        TetrisShape( blocks: [ (4,4) ], rotations: .zero ),
        // ▉▉
        TetrisShape( blocks: [ (3,4), (5,4) ], rotations: .one, display: .two ),
        //  ▉
        // ▉
        TetrisShape( blocks: [ (3,3), (5,5) ], rotations: .one, display: .two ),
        // ▉▉▉
        TetrisShape( blocks: [ (2,4), (4,4), (6,4) ], rotations: .one, display: .two ),
        // ▉
        // ▉▉
        TetrisShape(
            blocks: [ (4,4), (6,4), (4,6) ], rotations: .three, display: .two ),
        //  ▉
        // ▉ ▉
        TetrisShape(
            blocks: [ (2,3), (6,3), (4,5) ], rotations: .three, display: .two ),
        // ▉▉
        // ▉▉
        TetrisShape( blocks: [ (3,3), (5,3), (3,5), (5,5) ], rotations: .zero ),
    ]
}
