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
    func draw( in rect: CGRect, context: CGContext )
}


extension WitnessPuzzlesDocument {
    enum IconType: String, CaseIterable, Identifiable, Codable {
        case square, star, triangles, elimination
        var id: String { rawValue }
        
        var label: Image {
            Image( "\(rawValue.capitalized)Icon" )
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
            case .triangles:
                icon = try container.decode( TrianglesIcon.self, forKey: .icon )
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
            case .triangles:
                try container.encode( icon as! TrianglesIcon, forKey: .icon )
            case .elimination:
                try container.encode( icon as! EliminationIcon, forKey: .icon )
            }
        }
        
        var position: Point { icon.position }
        var id: UUID { UUID() }

        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle ).cgPoint
            let width = CGFloat( puzzle.blockWidth )
            return CGRect( x: center.x - width / 2, y: center.y - width / 2, width: width, height: width )
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
            let extent = icon.extent( puzzle: self )
            icon.icon.draw( in: extent, context: context )
            if let wrapped = type.wrap( point: icon.position, puzzle: self )?.cgPoint {
                icon.icon.draw( in: extent.move( to: wrapped ), context: context )
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
