//         FILE: StarIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/15/23 4:40 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct StarIcon: IconItem, Codable, Equatable, Hashable {
        let color: Color
        
        func draw( in rect: CGRect, context: CGContext ) -> Void {
            let iconRect = CGRect( x: -0.25, y: -0.25, width: 0.5, height: 0.5 )
            
            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
            context.scaleBy( x: rect.width, y: rect.height )
            context.setFillColor( color.cgColor! )
            context.fill( [ iconRect ] )
            context.rotate( by: Double.pi / 4 )
            context.fill( [ iconRect ] )
            context.restoreGState()
        }
    }
    
    mutating func addStarIcon( point: Point, color: Color ) -> Void {
        guard isIconPositionOK( point: point ) else { return }
        
        if Icon.isValid( position: point, puzzle: self ) {
            icons.insert( Icon( position: point, type: .star, icon: StarIcon( color: color ) ) )
        }
    }
}
