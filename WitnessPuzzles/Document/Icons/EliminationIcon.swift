//         FILE: EliminationIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/16/23 5:13 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct EliminationIcon: IconItem, Codable, Equatable, Hashable {
        let color: Color
        
        func draw( in rect: CGRect, context: CGContext ) {
            let iconWidth = 27.0 / 220
            let iconRect = CGRect( x: -iconWidth / 2, y: 0, width: iconWidth, height: 2 * iconWidth )

            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
            context.scaleBy( x: rect.width, y: rect.height )
            context.setFillColor( color.cgColor! )
            context.fill( [ iconRect ] )
            context.rotate( by: 2 * Double.pi / 3 )
            context.fill( [ iconRect ] )
            context.rotate( by: 2 * Double.pi / 3 )
            context.fill( [ iconRect ] )
            context.restoreGState()
        }
    }
    
    mutating func addEliminationIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            let newIcon = EliminationIcon( color: color )
            icons.insert( Icon( position: point, type: .elimination, icon: newIcon ) )
        }
    }
}
