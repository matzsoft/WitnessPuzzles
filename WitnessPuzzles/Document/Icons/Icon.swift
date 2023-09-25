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
    var color: Color { get }
    func draw( in rect: CGRect, context: CGContext )
}


extension WitnessPuzzlesDocument {
    enum IconType: String, CaseIterable, Identifiable, Codable {
        case square, star, triangles, elimination, tetris
        var id: String { rawValue }
        
        var label: Image {
            Image( "\(rawValue.capitalized)Icon" )
        }
    }

    struct IconInfo {
        var color: Color
        var iconType: IconType
        var trianglesCount: TrianglesCount
        var tetrisClassIndex: Int
        var tetrisShapeIndex: [Int]
        var tetrisRotation: TetrisRotations
        var tetrisNegated: Bool
        
        func replacing(
            color: Color? = nil, iconType: IconType? = nil, trianglesCount: TrianglesCount? = nil,
            tetrisClassIndex: Int? = nil, tetrisShapeIndex: Int? = nil,
            tetrisRotation: TetrisRotations? = nil, tetrisNegated: Bool? = nil
        ) -> IconInfo {
            var copy = self
            
            if let color = color { copy.color = color }
            if let iconType = iconType { copy.iconType = iconType }
            if let trianglesCount = trianglesCount { copy.trianglesCount = trianglesCount }
            if let tetrisClassIndex = tetrisClassIndex { copy.tetrisClassIndex = tetrisClassIndex}
            if let tetrisShapeIndex = tetrisShapeIndex {
                copy.tetrisShapeIndex[copy.tetrisClassIndex] = tetrisShapeIndex }
            if let tetrisRotation = tetrisRotation { copy.tetrisRotation = tetrisRotation }
            if let tetrisNegated = tetrisNegated { copy.tetrisNegated = tetrisNegated }
            
            return copy
        }
    }
    
    struct Icon: PuzzleItem, Hashable, Codable {
        let position: Point
        let type: IconType
        let icon: any IconItem
        
        var id: UUID { UUID() }

        init( position: Point, type: WitnessPuzzlesDocument.IconType, icon: any IconItem ) {
            self.position = position
            self.type = type
            self.icon = icon
        }
        
        enum CodingKeys: CodingKey {
            case position
            case type
            case icon
        }

        init( from decoder: Decoder ) throws {
            let container = try decoder.container( keyedBy: CodingKeys.self )
            position = try container.decode( Point.self, forKey: .position )
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
            case .tetris:
                icon = try container.decode( TetrisIcon.self, forKey: .icon )
            }
        }
        
        func encode( to encoder: Encoder ) throws {
            var container = encoder.container( keyedBy: CodingKeys.self )
            try container.encode( position, forKey: .position )
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
            case .tetris:
                try container.encode( icon as! TetrisIcon, forKey: .icon )
            }
        }
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let center = position.puzzle2user( puzzle: puzzle ).cgPoint
            let width = CGFloat( puzzle.blockWidth )
            return CGRect( x: center.x - width / 2, y: center.y - width / 2, width: width, height: width )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Icon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isBlock && puzzle.isConnected( point: position )
        }

        static func ==( lhs: Icon, rhs: Icon ) -> Bool {
            lhs.type == rhs.type && lhs.position == rhs.position
        }
        
        func hash( into hasher: inout Hasher ) {
            hasher.combine( type )
            hasher.combine( icon )
        }
        
        static func image( size: CGFloat, info: IconInfo ) -> Image {
            let extent = CGRect( x: 0, y: 0, width: size, height: size )
            let context = CGContext(
                data: nil, width: Int( size ), height: Int( size ), bitsPerComponent: 16, bytesPerRow: 0,
                space: CGColorSpace( name: CGColorSpace.sRGB )!,
                bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.premultipliedLast.rawValue ).rawValue
            )!
            
            context.clear( extent )
            switch info.iconType {
            case .square:
                let icon = SquareIcon( color: info.color )
                icon.draw( in: extent, context: context )
            case .star:
                let icon = StarIcon( color: info.color )
                icon.draw( in: extent, context: context )
            case .triangles:
                let icon = TrianglesIcon( info: info )
                icon.draw( in: extent, context: context )
            case .elimination:
                let icon = EliminationIcon( color: info.color )
                icon.draw( in: extent, context: context )
            case .tetris:
                let icon = TetrisIcon( info: info )
                icon.draw( in: extent, context: context )
            }
            
            return Image( context.makeImage()!, scale: 1, label: Text( verbatim: "" ) )
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
        return icons.contains { point == $0.position }
    }
    
    func isIconPositionOK( point: Point ) -> Bool {
        return Icon.isValid( position: point, puzzle: self )
    }
    
    mutating func removeIcon( point: Point ) -> Void {
        icons = icons.filter { $0.position != point }
    }
}
