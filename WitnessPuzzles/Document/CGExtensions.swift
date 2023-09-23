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

extension WitnessPuzzlesDocument {
    struct Point: Equatable, Hashable, Codable {
        let x: Int
        let y: Int
        
        init( _ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
        
        func puzzle2user( puzzle: WitnessPuzzlesDocument ) -> Point {
            let x = x * ( puzzle.lineWidth + puzzle.blockWidth ) / 2 + puzzle.lineWidth / 2
            let y = y * ( puzzle.lineWidth + puzzle.blockWidth ) / 2 + puzzle.lineWidth / 2
            return Point( x, y )
        }
        
        var isBlock:        Bool { ( x & y & 1 ) == 1 }
        var isPath:         Bool { ( x & y & 1 ) == 0 }
        var isIntersection: Bool { ( ( x | y ) & 1 ) == 0 }
        var isLine:         Bool { ( ( x ^ y)  & 1 ) == 1 }
        var isHorizontal:   Bool { isLine && y.isMultiple( of: 2 ) }
        var isVertical:     Bool { isLine && x.isMultiple( of: 2 ) }
        var cgPoint:        CGPoint { CGPoint( x: x, y: y ) }
        
        func isPuzzleSpace( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( x ) && puzzle.validSymbolY.contains( y )
        }
        
        static func +( _ lhs: Point, _ rhs: Point ) -> Point {
            Point( lhs.x + rhs.x, lhs.y + rhs.y )
        }
    }
    
    func neighbor( of point: Point, in direction: Direction ) -> Point {
        let normal = point + direction.vector
        
        switch type {
        case .rectangle:
            return normal
        case .cylinder:
            if normal.x == validSymbolX.lowerBound - 1 { return Point( validSymbolX.upperBound, normal.y ) }
            if normal.x == validSymbolX.upperBound + 1 { return Point( validSymbolX.lowerBound, normal.y ) }
            return normal
        }
    }
    
    func isConnected( point: Point ) -> Bool {
        guard point.isPuzzleSpace( puzzle: self ) else { return false }
        if missings.contains( where: { point == $0.position } ) { return false }
        if point.isLine { return true }
        
        let lines = [
            neighbor( of: point, in: .north ), neighbor( of: point, in: .east ),
            neighbor( of: point, in: .south ), neighbor( of: point, in: .west )
        ].filter { line in
            !line.isPuzzleSpace( puzzle: self ) || missings.contains { line == $0.position }
        }
        
        if point.isBlock && !lines.isEmpty { return false }
        if point.isIntersection && lines.count == 4 { return false }
        return true
    }
    
    func toPuzzleSpace( from view: CGPoint ) -> Point {
        let context = getContext()
        let user = context.convertToUserSpace( view )
        let resolution = Double( lineWidth + blockWidth ) / 2
        let offset = Double( lineWidth ) / 2
        let x = Int( ( ( user.x - offset ) / resolution ).rounded() )
        let y = Int( ( ( user.y - offset ) / resolution ).rounded() )
        
        return Point( x, y )
    }
    
    
    enum Direction: String, CaseIterable, Identifiable, Codable {
        case north, northeast, east, southeast, south, southwest, west, northwest
        
        var id: String { rawValue }
        
        var vector: Point {
            switch self {
            case .north:     return Point( 0, 1 )
            case .northeast: return Point( 1, 1 )
            case .east:      return Point( 1, 0 )
            case .southeast: return Point( 1, -1 )
            case .south:     return Point( 0, -1 )
            case .southwest: return Point( -1, -1 )
            case .west:      return Point( -1, 0 )
            case .northwest: return Point( -1, 1 )
            }
        }
        
        var label: Image {
            switch self {
            case .north:     return Image( systemName: "arrow.up" )
            case .northeast: return Image( systemName: "arrow.up.right" )
            case .east:      return Image( systemName: "arrow.right" )
            case .southeast: return Image( systemName: "arrow.down.right" )
            case .south:     return Image( systemName: "arrow.down" )
            case .southwest: return Image( systemName: "arrow.down.left" )
            case .west:      return Image( systemName: "arrow.left" )
            case .northwest: return Image( systemName: "arrow.up.left" )
            }
        }
        
        var components: [Direction] {
            switch self {
            case .north, .east, .south, .west:
                return [self]
            case .northeast:
                return [ .north, .east ]
            case .southeast:
                return [ .south, .east ]
            case .southwest:
                return [ .south, .west ]
            case .northwest:
                return [ .north, .west ]
            }
        }
    }
}


extension CGRect {
    func move( to point: CGPoint ) -> CGRect {
        offsetBy(dx: point.x - minX, dy: point.y - minY )
    }
}
