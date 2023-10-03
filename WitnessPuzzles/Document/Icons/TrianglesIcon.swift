//         FILE: TrianglesIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/17/23 9:39 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    enum TrianglesCount: Int, CaseIterable, Identifiable, Codable {
        case one = 1, two, three
        var id: Int { rawValue }
    }
    
    struct TrianglesIcon: IconItem, Codable, Equatable, Hashable {
        let color: Color
        let count: TrianglesCount
        
        init( color: Color, count: TrianglesCount ) {
            self.color = color
            self.count = count
        }
        
        init( info: IconInfo) {
            color = info.color
            count = info.trianglesCount
        }
        
        func draw( in rect: CGRect, context: CGContext ) {
            let stepSize = rect.width / 10
            let iconTop = CGPoint( x: 0, y: 2 * sqrt( 3 ) / 3 )
            let iconLeft = CGPoint( x: -1, y: -2 * sqrt( 3 ) / 6 )
            let iconRight = CGPoint( x: 1, y: -2 * sqrt( 3 ) / 6 )

            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
            context.scaleBy( x: stepSize, y: stepSize )
            context.setFillColor( color.cgColor! )
            context.beginPath()

            func drawOne( xOffset: CGFloat ) {
                context.translateBy( x: xOffset, y: 0 )
                context.addLines( between: [ iconTop, iconLeft, iconRight ] )
                context.translateBy( x: -xOffset, y: 0 )
            }
            
            switch count {
            case .one:
                drawOne( xOffset: 0 )
            case .two:
                drawOne( xOffset: -2 )
                drawOne( xOffset: 2 )
            case .three:
                drawOne( xOffset: -3 )
                drawOne( xOffset: 0 )
                drawOne( xOffset: 3)
            }
            
            context.fillPath()
            context.restoreGState()
        }
    }
}
