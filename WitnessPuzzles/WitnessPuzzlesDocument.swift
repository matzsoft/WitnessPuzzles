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

struct WitnessPuzzlesDocument: FileDocument, Codable {
    enum PuzzleType: String, CaseIterable, Codable { case rectangle = "Rectangle", cylinder = "Cylinder" }
    
    struct Finish: Codable {
        let location: Point
        let direction: Direction
        
        func convertedLocation( puzzle: WitnessPuzzlesDocument ) -> Point {
            let converted = puzzle.convert( symbol: location )
            let offset = direction.finishOffset( distance: puzzle.lineWidth / 2, extra: 1 )
            return Point( converted.x + offset.x, converted.y + offset.y )
        }
    }
    
    var width = 5
    var height = 5
    var type = PuzzleType.rectangle
    var starts = [ Point(0,0) ]
    var finishes = [ Finish( location: Point( 10, 10 ), direction: .northeast ) ]
    var background = Color( hex: "#23180A" )
    var foreground = Color( red: 1, green: 1, blue: 1, opacity: 1 )

    var lineWidth = 4
    var blockWidth = 8
    var padding = 2
    var scaleFactor = CGFloat( 12.5 )
    
    var startRadius: Int { lineWidth }
    var finishRadius: Int { lineWidth / 2 }
    var baseHeight: Int { ( height + 1 ) * lineWidth + height * blockWidth }
    var baseWidth: Int {
        switch type {
        case .rectangle: return ( width + 1 ) * lineWidth + width * blockWidth
        case .cylinder:  return width * ( lineWidth + blockWidth )
        }
    }

    var validSymbolX: Range<Int> {
        switch type {
        case .rectangle: return 0 ..< ( 2 * width + 1 )
        case .cylinder:  return 0 ..< ( 2 * width )
        }
    }
    var validSymbolY: Range<Int> { 0 ..< ( 2 * height ) }
    
    init() { }

    static var readableContentTypes: [UTType] { [ .json ] }
    static var writableContentTypes: [UTType] { [ .json, .png ] }

    init( configuration: ReadConfiguration ) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self = try JSONDecoder().decode( WitnessPuzzlesDocument.self, from: data )
    }
    
    func fileWrapper( configuration: WriteConfiguration ) throws -> FileWrapper {
        switch configuration.contentType {
        case .json:
            let data = try JSONEncoder().encode( self )
            return .init( regularFileWithContents: data )
        case .png:
            let cicontext = CIContext()
            let ciimage = CIImage( cgImage: image )
            guard let data = cicontext.pngRepresentation(
                of: ciimage,
                format: .RGBA16,
                colorSpace: CGColorSpace( name: CGColorSpace.extendedLinearSRGB )!
            ) else { return FileWrapper() }
            return .init( regularFileWithContents: data )
        default:
            fatalError( "Unsopportd content type \(configuration.contentType)" )
        }
    }
    
    var image: CGImage {
        let userWidth = {
            switch type {
            case .rectangle: return CGFloat( baseWidth + 2 * padding + extraLeft() + extraRight() )
            case .cylinder:  return CGFloat( baseWidth )
            }
        }()
        let userHeight = CGFloat( baseHeight + 2 * padding + extraBottom() + extraTop() )
        let imageWidth = Int( userWidth * scaleFactor )
        let imageHeight = Int( userHeight * scaleFactor )
        
        let context = CGContext(
            data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 16, bytesPerRow: 0,
            space: CGColorSpace( name: CGColorSpace.sRGB )!,
            bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.noneSkipLast.rawValue ).rawValue
        )!

        context.scaleBy( x: CGFloat( scaleFactor ), y: CGFloat( scaleFactor ) )
        context.beginPath()
        context.addRect( CGRect(
            origin: CGPoint( x: 0, y: 0 ),
            size: CGSize( width: userWidth, height: userHeight ) )
        )
        context.setFillColor( background.cgColor! )
        context.fillPath()

        context.setFillColor( foreground.cgColor! )
        context.beginPath()
        switch type {
        case .rectangle: drawRectangle( context: context )
        case .cylinder:  drawCylinder( context: context )
        }

        drawStarts( context: context )
        drawFinishes( context: context )
        context.fillPath()

        return context.makeImage()!
    }
    
    var nsImage: NSImage {
        let image = image
        return NSImage( cgImage: image, size: NSSize( width: image.width, height: image.height ) )
    }

    func extraLeft() -> Int {
        let startExtra = max( starts.map { startRadius - convert( symbol: $0 ).x }.max() ?? 0, 0 )
        let finishMax = finishes.map { finishRadius - $0.convertedLocation( puzzle: self ).x }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraBottom() -> Int {
        let startExtra = max( starts.map { startRadius - convert( symbol: $0 ).y }.max() ?? 0, 0 )
        let finishMax = finishes.map { finishRadius - $0.convertedLocation( puzzle: self ).y }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraRight() -> Int {
        let startsMax = starts.map { convert( symbol: $0 ).x + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseWidth, 0 )
        let finishMax = finishes.map { $0.convertedLocation( puzzle: self ).x + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseWidth, 0 )
        
        return startExtra + finishExtra
    }

    func extraTop() -> Int {
        let startsMax = starts.map { convert( symbol: $0 ).y + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseHeight, 0 )
        let finishMax = finishes.map { $0.convertedLocation( puzzle: self ).y + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseHeight, 0 )
        
        return startExtra + finishExtra
    }

    func drawRectangle( context: CGContext ) -> Void {
        let cornerRadius = CGFloat( lineWidth / 2 )
        context.translateBy( x: CGFloat( padding + extraLeft() ), y: CGFloat( padding + extraBottom() ) )

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
    }
    
    func drawCylinder( context: CGContext ) -> Void {
        let leftWidth = 3 * lineWidth / 4
        let rightWidth = lineWidth / 4
        
        context.translateBy( x: CGFloat( -rightWidth ), y: CGFloat( padding + extraBottom() ) )
        context.setFillColor( foreground.cgColor! )
        context.beginPath()
        
        context.addRect( CGRect( x: rightWidth, y: 0, width: leftWidth, height: baseHeight ) )
        context.addRect( CGRect(
            x: ( lineWidth + blockWidth ) * width, y: 0, width: rightWidth, height: baseHeight ) )

        for col in 1 ..< width {
            context.addRect( CGRect(
                x: ( lineWidth + blockWidth ) * col, y: 0, width: lineWidth, height: baseHeight ) )
        }

        for row in 0 ... height {
            context.addRect( CGRect(
                x: 0, y: ( lineWidth + blockWidth ) * row, width: baseWidth, height: lineWidth ) )
        }
    }
    
    func convert( symbol: Point ) -> Point {
        let x = symbol.x * ( lineWidth + blockWidth ) / 2 + lineWidth / 2
        let y = symbol.y * ( lineWidth + blockWidth ) / 2 + lineWidth / 2
        return Point( x, y )
    }
    
    func drawStarts( context: CGContext ) -> Void {
        for start in starts {
            let drawing = convert( symbol: start )
            context.addEllipse( in: CGRect(
                x: drawing.x - startRadius, y: drawing.y - startRadius,
                width: 2 * startRadius, height: 2 * startRadius
            ) )
            if start.x == 0 && type == .cylinder {
                let drawing = convert(symbol: Point( 2 * width, start.y ) )
                context.addEllipse( in: CGRect(
                    x: drawing.x - startRadius, y: drawing.y - startRadius,
                    width: 2 * startRadius, height: 2 * startRadius
                ) )
            }
        }
    }

    func drawFinishes( context: CGContext ) -> Void {
        for finish in finishes {
            let user = finish.convertedLocation( puzzle: self )
            context.saveGState()
            context.translateBy( x: CGFloat( user.x ), y: CGFloat( user.y ) )
            context.addEllipse( in: CGRect(
                x: -finishRadius, y: -finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            
            let angle = finish.direction.finishAngle
            context.rotate( by: angle )
            context.addRect( CGRect(
                x: -finishRadius, y: -2 * finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            context.restoreGState()
        }
    }
    
    func isValid( start: Point ) -> Bool {
        validSymbolX.contains( start.x ) && validSymbolY.contains( start.y )
    }
    
    func isValid( finish: Finish ) -> Bool {
        let validX = validSymbolX
        let validY = validSymbolY
        
        switch ( finish.location.x, finish.location.y ) {
        case ( validX.lowerBound, validY ): return true
        case ( validX.upperBound, validY ): return true
        case ( validX, validY.lowerBound ): return true
        case ( validX, validY.upperBound ): return true
        default: return false
        }
    }
    
    mutating func adjustDimensions( type: PuzzleType, width: Int, height: Int ) -> Void {
        self.type = type
        self.width = width
        self.height = height
        
        starts = starts.filter { isValid( start: $0 ) }
        finishes = finishes.filter { isValid( finish: $0 ) }
    }
    
    mutating func adjustDrawing( lineWidth: Int, blockWidth: Int ) -> Void {
        self.lineWidth = lineWidth
        self.blockWidth = blockWidth
        
        starts = starts.filter { isValid( start: $0 ) }
        finishes = finishes.filter { isValid( finish: $0 ) }
    }
}
