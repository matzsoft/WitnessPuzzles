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

struct Point: Codable {
    let x: Int
    let y: Int
    
    init( _ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

// Adapted from https://gist.github.com/peterfriese/bb2fc5df202f6a15cc807bd87ff15193
//
//  Color+Codable.swift
//  FirestoreCodableSamples
//
//  Created by Peter Friese on 18.03.21.
//

// Inspired by https://cocoacasts.com/from-hex-to-uicolor-and-back-in-swift
// Make Color codable. This includes support for transparency.
// See https://www.digitalocean.com/community/tutorials/css-hex-code-colors-alpha-values
extension Color: Codable {
    init( hex: String ) {
        let rgba = hex.toRGBA
        
        self.init( .sRGBLinear, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.alpha )
    }
    
    public init( from decoder: Decoder ) throws {
        let container = try decoder.singleValueContainer()
        
        self.init( hex: try container.decode( String.self ) )
    }
    
    public func encode( to encoder: Encoder ) throws {
        var container = encoder.singleValueContainer()
        try container.encode( toHex )
    }
    
    var toHex: String? {
        return toHex()
    }
    
    func toHex( alpha: Bool = false ) -> String? {
        guard let components = cgColor?.components, components.count >= 3 else { return nil }
        
        let r = ( components[0] * 255 ).rounded()
        let g = ( components[1] * 255 ).rounded()
        let b = ( components[2] * 255 ).rounded()
        let a = components.count < 4 ? 255.0 : ( components[3] * 255 ).rounded()
        
        if alpha { return String( format: "%02lX%02lX%02lX%02lX", r, g, b, a ) }
        return String( format: "%02lX%02lX%02lX", r, g, b )
    }
}

extension String {
    var toRGBA: ( r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat ) {
        let trimmed = self.trimmingCharacters( in: .whitespacesAndNewlines )
        let hexSanitized = trimmed.replacingOccurrences( of: "#", with: "" )
        let length = hexSanitized.count
        var rgb: UInt64 = 0

        Scanner( string: hexSanitized ).scanHexInt64( &rgb )
        
        if length == 6 {
            let r = CGFloat( ( rgb & 0xFF0000 ) >> 16 ) / 255.0
            let g = CGFloat( ( rgb & 0x00FF00 ) >>  8 ) / 255.0
            let b = CGFloat(   rgb & 0x0000FF )         / 255.0
            return ( r, g, b, 1 )
        }  else if length == 8 {
            let r = CGFloat( ( rgb & 0xFF000000 ) >> 24 ) / 255.0
            let g = CGFloat( ( rgb & 0x00FF0000 ) >> 16 ) / 255.0
            let b = CGFloat( ( rgb & 0x0000FF00 ) >>  8 ) / 255.0
            let a = CGFloat(   rgb & 0x000000FF )         / 255.0
            return ( r, g, b, a )
        }
        
        return ( 0, 0, 0, 1 )
    }
}
