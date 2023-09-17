//         FILE: Icon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 5:30 PM

import Foundation
import SwiftUI

protocol IconItem: Hashable, Codable {
    var position: WitnessPuzzlesDocument.Point { get }
    var color: Color { get }
    func draw( puzzle: WitnessPuzzlesDocument, context: CGContext )
    func move( to: WitnessPuzzlesDocument.Point ) -> any IconItem
}


extension WitnessPuzzlesDocument {
    enum IconType: String, CaseIterable, Identifiable, Codable {
        case square, star, elimination
        var id: String { rawValue }
        
        var label: Image {
            switch self {
            case .square:      return Image( systemName: "stop.fill" )
            case .star:        return Image( systemName: "seal.fill" )
            case .elimination: return Image( systemName: "arrow.triangle.merge")
            }
        }
    }
    
    struct Icon: PuzzleItem, Hashable, Codable {
        let type: IconType
        let icon: any IconItem
        
        init( type: WitnessPuzzlesDocument.IconType, icon: any IconItem ) {
            self.type = type
            self.icon = icon
        }
        
        enum CodingKeys: CodingKey {
            case type
            case icon
        }

        init( from decoder: Decoder ) throws {
            let container = try decoder.container( keyedBy: CodingKeys.self )
            type = try container.decode( IconType.self, forKey: .type )
            switch type {
            case .square:
                icon = try container.decode( SquareIcon.self, forKey: .icon )
            case .star:
                icon = try container.decode( StarIcon.self, forKey: .icon )
            case .elimination:
                icon = try container.decode( EliminationIcon.self, forKey: .icon )
            }
        }
        
        func encode( to encoder: Encoder ) throws {
            var container = encoder.container( keyedBy: CodingKeys.self )
            try container.encode( type, forKey: .type )
            
            switch type {
            case .square:
                try container.encode( icon as! SquareIcon, forKey: .icon )
            case .star:
                try container.encode( icon as! StarIcon, forKey: .icon )
            case .elimination:
                try container.encode( icon as! EliminationIcon, forKey: .icon )
            }
        }
        
        var position: Point { icon.position }
        var id: UUID { UUID() }

        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Icon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isBlock
        }

        static func ==( lhs: Icon, rhs: Icon ) -> Bool {
            lhs.type == rhs.type && lhs.icon.position == rhs.icon.position
        }
        
        func hash( into hasher: inout Hasher ) {
            hasher.combine( type )
            hasher.combine( icon )
        }
    }

    func drawIcons( context: CGContext ) -> Void {
        for icon in icons {
            icon.icon.draw( puzzle: self, context: context )
            if type.needsWrap( point: icon.position, puzzle: self ) {
                let newPosition = Point( validSymbolX.upperBound + 1, icon.position.y )
                let moved = icon.icon.move( to: newPosition )
                moved.draw( puzzle: self, context: context )
            }
        }
        
        context.fillPath()
        context.restoreGState()
    }
    
    func iconExists( point: Point ) -> Bool {
        return conflictsWithIcons( point: point )
    }
    
    func isIconPositionOK( point: Point ) -> Bool {
        return Icon.isValid( position: point, puzzle: self )
    }
    
    mutating func removeIcon( point: Point ) -> Void {
        icons = icons.filter { $0.position != point }
    }
}
