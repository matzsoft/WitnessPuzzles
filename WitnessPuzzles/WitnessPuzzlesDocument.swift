//         FILE: WitnessPuzzlesDocument.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI
import UniformTypeIdentifiers
import Foundation
import CoreGraphics
import CoreImage

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct WitnessPuzzlesDocument: FileDocument {
    let width = 5
    let height = 5
    let cylinder = false
    let starts = [ (2,2) ]
    let finishes = [ (64,64) ]
    let background = color( from: 0x23180A )
    let foreground = CGColor( red: 1, green: 1, blue: 1, alpha: 1 )

    let lineWidth = 4
    let blockWidth = 8
    let padding = 2
    let scaleFactor = 25
    
    let startRadius: Int
    let finishRadius: Int
    let baseWidth: Int
    let baseHeight: Int

    init() {
        startRadius = lineWidth
        finishRadius = lineWidth / 2
        baseWidth = ( width + 1 ) * lineWidth + width * blockWidth
        baseHeight = ( height + 1 ) * lineWidth + height * blockWidth
    }

    static var readableContentTypes: [UTType] { [.exampleText] }

    init( configuration: ReadConfiguration ) throws {
        guard let data = configuration.file.regularFileContents,
              let _ = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.init()
    }
    
    func fileWrapper( configuration: WriteConfiguration ) throws -> FileWrapper {
        let data = Data()
        return .init( regularFileWithContents: data )
    }
    
    var image: NSImage {
        let cornerRadius = CGFloat( lineWidth / 2 )
        let userWidth = baseWidth + 2 * padding + extraLeft() + extraRight()
        let userHeight = baseHeight + 2 * padding + extraBottom() + extraTop()
        let imageWidth = userWidth * scaleFactor
        let imageHeight = userHeight * scaleFactor
        
        let context = CGContext(
            data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 16, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.noneSkipLast.rawValue ).rawValue
        )!

        context.scaleBy( x: CGFloat( scaleFactor ), y: CGFloat( scaleFactor ) )
        context.translateBy( x: CGFloat( padding + extraLeft() ), y: CGFloat( padding + extraBottom() ) )
        context.beginPath()
        context.addRect( CGRect(
            origin: CGPoint( x: 0, y: 0 ),
            size: CGSize( width: userWidth, height: userWidth ) )
        )
        context.setFillColor( background )
        context.fillPath()

        context.setFillColor( foreground )
        context.beginPath()
        for col in 0 ... width {
            context.addPath(
                CGPath(
                    roundedRect: CGRect(
                        origin: CGPoint( x: ( lineWidth + blockWidth ) * col, y: 0 ),
                        size: CGSize( width: lineWidth, height: baseHeight )
                    ),
                    cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
            )
        }

        for row in 0 ... height {
            context.addPath(
                CGPath(
                    roundedRect: CGRect(
                        origin: CGPoint( x: 0, y: ( lineWidth + blockWidth ) * row ),
                        size: CGSize( width: baseWidth, height: lineWidth )
                    ),
                    cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil )
            )
        }

        drawStarts( context: context )
        drawFinishes( context: context )
        context.fillPath()

        let image = context.makeImage()!
        return NSImage( cgImage: image, size: NSSize( width: image.width, height: image.height ) )
    }

    func extraLeft() -> Int {
        let startExtra = max( starts.map { startRadius - $0.0 }.max() ?? 0, 0 )
        let finishExtra = max( finishes.map { finishRadius - $0.0 }.max() ?? 0, 0 )
        
        return startExtra + finishExtra
    }

    func extraBottom() -> Int {
        let startExtra = max( starts.map { startRadius - $0.1 }.max() ?? 0, 0 )
        let finishExtra = max( finishes.map { finishRadius - $0.1 }.max() ?? 0, 0 )
        
        return startExtra + finishExtra
    }

    func extraRight() -> Int {
        let startExtra = max( ( starts.map { $0.0 + startRadius }.max() ?? 0 ) - baseWidth, 0 )
        let finishExtra = max( ( finishes.map { $0.0 + finishRadius }.max() ?? 0 ) - baseWidth, 0 )
        
        return startExtra + finishExtra
    }

    func extraTop() -> Int {
        let startExtra = max( ( starts.map { $0.1 + startRadius }.max() ?? 0 ) - baseHeight, 0 )
        let finishExtra = max( ( finishes.map { $0.1 + finishRadius }.max() ?? 0 ) - baseHeight, 0 )
        
        return startExtra + finishExtra
    }

    func drawStarts( context: CGContext ) -> Void {
        for start in starts {
            context.addEllipse( in: CGRect(
                x: start.0 - startRadius, y: start.1 - startRadius,
                width: 2 * startRadius, height: 2 * startRadius
            ) )
        }
    }

    func drawFinishes( context: CGContext ) -> Void {
        for finish in finishes {
            context.saveGState()
            context.translateBy( x: CGFloat( finish.0 ), y: CGFloat( finish.1 ) )
            context.addEllipse( in: CGRect(
                x: -finishRadius, y: -finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            
            let angle = {
                switch ( finish ) {
                case ( 0, 0 ):
                    return 3 * Double.pi / 4
                case ( 0, baseHeight ):
                    return 1 * Double.pi / 4
                case ( baseWidth, baseHeight ):
                    return 7 * Double.pi / 4
                case ( baseWidth, 0 ):
                    return 5 * Double.pi / 4
                case ( -1, 1 ..< baseHeight ):
                    return 2 * Double.pi / 4
                case ( 1 ..< baseWidth, baseHeight + 1 ):
                    return 0 * Double.pi / 4
                case ( baseWidth + 1, 1 ..< baseHeight ):
                    return 6 * Double.pi / 4
                case ( 1 ..< baseWidth, -1 ):
                    return 4 * Double.pi / 4
                default:
                    fatalError( "Unsopported finish location (\(finish.0),\(finish.1))")
                }
            }()
            context.rotate( by: angle )
            context.addRect( CGRect(
                x: -finishRadius, y: -2 * finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            context.restoreGState()
        }
    }
}


func color( from hex: Int ) -> CGColor {
    let red = CGFloat( ( hex >> 16 ) & 0xFF )
    let green = CGFloat( ( hex >> 8 ) & 0xFF )
    let blue = CGFloat( hex & 0xFF )
    
    return CGColor( red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1 )
}
