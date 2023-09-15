//         FILE: Icon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 5:30 PM

import Foundation
import SwiftUI

protocol IconType {
    var color: Color { get }
}


extension WitnessPuzzlesDocument {
    enum Icon: CaseIterable, Hashable, Codable {
        case square( SquareIcon )
        
        var id: UUID { UUID() }
        static var allCases: [WitnessPuzzlesDocument.Icon] {
            [ .square( SquareIcon( position: Point( 1, 1 ), color: .black ) ) ]
        }

        func hash( into hasher: inout Hasher ) {
            switch self {
            case .square( let icon ):
                hasher.combine( icon )
            }
        }
        
        var position: Point {
            switch self {
            case .square( let icon ): return icon.position
            }
        }
        
        var color: Color {
            switch self {
            case .square( let icon ): return icon.color
            }
        }
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            position.puzzle2user( puzzle: puzzle )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            Icon.isValid( position: position, puzzle: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            position.isPuzzleSpace( puzzle: puzzle ) && position.isBlock
        }
        
        func draw( puzzle: WitnessPuzzlesDocument, context: CGContext ) -> Void {
            switch self {
            case .square( let icon ): icon.draw( puzzle: puzzle, context: context )
            }
        }
        
        func move( to: Point ) -> Icon {
            switch self {
            case .square( let icon ): return Icon.square( icon.move( to: to ) )
            }
        }
    }

    func drawIcons( context: CGContext ) -> Void {
        for icon in icons {
            icon.draw( puzzle: self, context: context )
            if type.needsWrap( point: icon.position, puzzle: self ) {
                let newPosition = Point( validSymbolX.upperBound + 1, icon.position.y )
                let moved = icon.move( to: newPosition )
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
