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
    var width = 5
    var height = 5
    var type = PuzzleType.rectangle
    var background = Color( hex: "#23180A" )
    var foreground = Color( red: 1, green: 1, blue: 1, opacity: 1 )
    var starts = Set<Start>( [ Start( position: Point(0,0) ) ] )
    var finishes = Set( [ Finish( position: Point( 10, 10 ), direction: .northeast ) ] )
    var hexagons = Set<Hexagon>()
    var gaps = Set<Gap>()
    var missings = Set<Missing>()

    var lineWidth = 4
    var blockWidth = 8
    var padding = 2
    var scaleFactor = CGFloat( 12.5 )
    
    var startRadius: Int { lineWidth }
    var finishRadius: Int { lineWidth / 2 }
    var baseHeight: Int { ( height + 1 ) * lineWidth + height * blockWidth }
    var baseWidth: Int { type.baseWidth( puzzle: self ) }
    var userHeight: CGFloat { CGFloat( baseHeight + 2 * padding + extraBottom() + extraTop() ) }
    var userWidth: CGFloat { type.userWidth( puzzle: self ) }
    var validSymbolX: ClosedRange<Int> { type.validPuzzleX( puzzle: self ) }
    var validSymbolY: ClosedRange<Int> { 0 ... ( 2 * height ) }
    var lines: Set<Point> {
        validSymbolX.reduce( into: Set<Point>() ) { set, x in
            validSymbolY.forEach { y in
                if ( x ^ y ) & 1 == 1 { set.insert( Point( x, y ) ) }
            }
        }.subtracting( missings.map { $0.position } )
    }
    
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
        context.translateBy( x: type.xOriginOffset( puzzle: self ), y: CGFloat( padding + extraBottom() ) )
    }
    
    var image: CGImage {
        let context = getContext()

        context.setFillColor( background.cgColor! )
        context.fill( [
            CGRect(  origin: CGPoint( x: 0, y: 0 ), size: CGSize( width: userWidth, height: userHeight ) )
        ])

        setOrigin( context: context )
        type.draw( puzzle: self, context: context )

        drawStarts( context: context )
        drawFinishes( context: context )
        drawGaps( context: context )
        drawHexagons( context: context )

        return context.makeImage()!
    }
    
    var nsImage: NSImage {
        let image = image
        return NSImage( cgImage: image, size: NSSize( width: image.width, height: image.height ) )
    }

    func extraLeft() -> Int {
        let startExtra = max( starts.map { startRadius - $0.location( puzzle: self ).x }.max() ?? 0, 0 )
        let finishMax = finishes.map { finishRadius - $0.location( puzzle: self ).x }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraBottom() -> Int {
        let startExtra = max( starts.map { startRadius - $0.location( puzzle: self ).y }.max() ?? 0, 0 )
        let finishMax = finishes.map { finishRadius - $0.location( puzzle: self ).y }.max() ?? 0
        let finishExtra = max( finishMax, 0 )
        
        return startExtra + finishExtra
    }

    func extraRight() -> Int {
        let startsMax = starts.map { $0.location( puzzle: self ).x + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseWidth, 0 )
        let finishMax = finishes.map { $0.location( puzzle: self ).x + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseWidth, 0 )
        
        return startExtra + finishExtra
    }

    func extraTop() -> Int {
        let startsMax = starts.map { $0.location( puzzle: self ).y + startRadius }.max() ?? 0
        let startExtra = max( startsMax - baseHeight, 0 )
        let finishMax = finishes.map { $0.location( puzzle: self ).y + finishRadius }.max() ?? 0
        let finishExtra = max( finishMax - baseHeight, 0 )
        
        return startExtra + finishExtra
    }
        
    mutating func adjustDimensions( type: PuzzleType, width: Int, height: Int ) -> Void {
        self.type = type
        self.width = width
        self.height = height
        
        starts = starts.filter { $0.isValid( puzzle: self ) }
        finishes = finishes.filter { $0.isValid( puzzle: self ) }
        hexagons = hexagons.filter { $0.isValid( puzzle: self ) }
        gaps = gaps.filter { $0.isValid( puzzle: self ) }
        missings = missings.filter { $0.isValid( puzzle: self ) }
    }
}
