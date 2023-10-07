//         FILE: SquareIcon.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/15/23 12:19 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct SquareIcon: IconItem, Codable, Equatable, Hashable {
        let color: Color
        
        func draw( in rect: CGRect, context: CGContext, alpha: CGFloat ) {
            let cornerRadius = 0.125
            let iconRect = CGRect( x: -0.25, y: -0.25, width: 0.5, height: 0.5 )

            context.saveGState()
            context.translateBy( x: rect.midX, y: rect.midY )
            context.scaleBy( x: rect.width, y: rect.height )
            context.setFillColor( color.cgColor!.copy( alpha: alpha )! )
            context.beginPath()
            context.addPath(
                CGPath(
                    roundedRect: iconRect, cornerWidth: cornerRadius,
                    cornerHeight: cornerRadius, transform: nil
                )
            )
            context.fillPath()
            context.restoreGState()
        }
    }
}
