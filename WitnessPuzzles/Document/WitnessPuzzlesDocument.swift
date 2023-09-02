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
    
    var width = 5
    var height = 5
    var type = PuzzleType.rectangle
    var starts = [ Point(0,0) ]
    var finishes = [ Finish( position: Point( 10, 10 ), direction: .northeast ) ]
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
    var userHeight: CGFloat { CGFloat( baseHeight + 2 * padding + extraBottom() + extraTop() ) }
    var userWidth: CGFloat {
        switch type {
        case .rectangle: return CGFloat( baseWidth + 2 * padding + extraLeft() + extraRight() )
        case .cylinder:  return CGFloat( baseWidth )
        }
    }
    var cylinderLeft: Int { 3 * lineWidth / 4 }
    var cylinderRight: Int { lineWidth / 4 }

    var validSymbolX: ClosedRange<Int> {
        switch type {
        case .rectangle: return 0 ... ( 2 * width )
        case .cylinder:  return 0 ... ( 2 * width - 1 )
        }
    }
    var validSymbolY: ClosedRange<Int> { 0 ... ( 2 * height ) }
    
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
    
    func getContext() -> CGContext {
        let imageWidth = Int( userWidth * scaleFactor )
        let imageHeight = Int( userHeight * scaleFactor )
        
        let context = CGContext(
            data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 16, bytesPerRow: 0,
            space: CGColorSpace( name: CGColorSpace.sRGB )!,
            bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.noneSkipLast.rawValue ).rawValue
        )!

        context.scaleBy( x: CGFloat( scaleFactor ), y: CGFloat( scaleFactor ) )
        return context
    }
    
    func setOrigin( context: CGContext ) -> Void {
        switch type {
        case .rectangle:
            context.translateBy( x: CGFloat( padding + extraLeft() ), y: CGFloat( padding + extraBottom() ) )
        case .cylinder:
            context.translateBy( x: CGFloat( -cylinderRight ), y: CGFloat( padding + extraBottom() ) )
        }
    }
    
    var image: CGImage {
        let context = getContext()

        context.beginPath()
        context.addRect( CGRect(
            origin: CGPoint( x: 0, y: 0 ),
            size: CGSize( width: userWidth, height: userHeight ) )
        )
        context.setFillColor( background.cgColor! )
        context.fillPath()

        setOrigin( context: context )
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
        let finishMax = finishes.map { finishRadius - $0.location( puzzle: self ).x }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraBottom() -> Int {
        let startExtra = max( starts.map { startRadius - convert( symbol: $0 ).y }.max() ?? 0, 0 )
        let finishMax = finishes.map { finishRadius - $0.location( puzzle: self ).y }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraRight() -> Int {
        let startsMax = starts.map { convert( symbol: $0 ).x + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseWidth, 0 )
        let finishMax = finishes.map { $0.location( puzzle: self ).x + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseWidth, 0 )
        
        return startExtra + finishExtra
    }

    func extraTop() -> Int {
        let startsMax = starts.map { convert( symbol: $0 ).y + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseHeight, 0 )
        let finishMax = finishes.map { $0.location( puzzle: self ).y + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseHeight, 0 )
        
        return startExtra + finishExtra
    }

    func drawRectangle( context: CGContext ) -> Void {
        let cornerRadius = CGFloat( lineWidth / 2 )

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
        context.addRect( CGRect( x: cylinderRight, y: 0, width: cylinderLeft, height: baseHeight ) )
        context.addRect( CGRect(
            x: ( lineWidth + blockWidth ) * width, y: 0, width: cylinderRight, height: baseHeight ) )

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
    
    func convert( user: CGPoint ) -> Point {
        let resolution = Double( lineWidth + blockWidth ) / 2
        let offset = Double( lineWidth ) / 2
        let x = Int( ( ( user.x - offset ) / resolution ).rounded() )
        let y = Int( ( ( user.y - offset ) / resolution ).rounded() )
        
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
    
    func isValid( start: Point ) -> Bool {
        validSymbolX.contains( start.x ) && validSymbolY.contains( start.y )
            && ( ( start.x & start.y & 1 ) == 0 )
    }
    
    mutating func adjustDimensions( type: PuzzleType, width: Int, height: Int ) -> Void {
        self.type = type
        self.width = width
        self.height = height
        
        starts = starts.filter { isValid( start: $0 ) }
        finishes = finishes.filter { $0.isValid( puzzle: self ) }
    }
    
    mutating func toggleStart( viewPoint: CGPoint ) -> Void {
        let context = getContext()
        setOrigin( context: context )
        let userPoint = convert( user: context.convertToUserSpace( viewPoint ) )
        
        guard isValid( start: userPoint ) else {
            NSSound.beep();
            return
        }

        if starts.contains( where: { $0 == userPoint } ) {
            starts = starts.filter { $0 != userPoint }
        } else {
            starts.append( userPoint )
        }
    }
}
