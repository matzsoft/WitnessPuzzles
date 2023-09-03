//         FILE: Gap.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/2/23 10:05 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Gap: Codable {
        let position: Point
        
        func location( puzzle: WitnessPuzzlesDocument ) -> Point {
            puzzle.convert( symbol: position )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            puzzle.validSymbolX.contains( position.x ) && puzzle.validSymbolY.contains( position.y )
                && ( ( ( position.x ^ position.y ) & 1 ) == 1 )
        }
    }

    func drawGaps( context: CGContext ) -> Void {
        for gap in gaps {
            let user = gap.location( puzzle: self )
            context.saveGState()
            context.beginPath()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            context.scaleBy( x: CGFloat( lineWidth ) / 2, y: CGFloat( lineWidth ) / 2 )
            context.setFillColor( background.cgColor! )
            context.fill( [ CGRect( x: -1, y: -1, width: 2, height: 2 ) ] )
            context.restoreGState()
        }
    }

    mutating func toggleGap( viewPoint: CGPoint ) -> Void {
        let context = getContext()
        setOrigin( context: context )
        let userPoint = convert( user: context.convertToUserSpace( viewPoint ) )
        let newGap = Gap( position: userPoint )
        
        guard newGap.isValid( puzzle: self ) else {
            NSSound.beep();
            return
        }

        if gaps.contains( where: { $0.position == userPoint } ) {
            gaps = gaps.filter { $0.position != userPoint }
        } else {
            gaps.append( newGap )
        }
    }
}
