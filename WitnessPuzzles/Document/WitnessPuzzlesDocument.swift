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
    var width  = 5 { didSet { adjustDimensions() } }
    var height = 5 { didSet { adjustDimensions() } }
    var type = PuzzleType.rectangle { didSet { adjustDimensions() } }
    var background = Color( hex: "#23180A" )
    var foreground = Color( red: 1, green: 1, blue: 1, opacity: 1 )
    var starts = Set<Start>( [ Start( position: Point(0,0) ) ] )
    var finishes = Set( [ Finish( position: Point( 10, 10 ), direction: .northeast ) ] )
    var hexagons = Set<Hexagon>()
    var gaps = Set<Gap>()
    var missings = Set<Missing>()
    var icons = Set<Icon>()

    var lineWidth = 4
    var blockWidth = 8
    var padding = 2
    var scaleFactor = CGFloat( 12.5 )
    
    var startRadius: Int { lineWidth }
    var finishRadius: Int { lineWidth / 2 }
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
            let ciimage = CIImage( cgImage: image() )
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
    
    func getContext( fill: Color? = nil ) -> CGContext {
        let userRect = type.userRect( puzzle: self )
        let imageWidth = Int( userRect.width * scaleFactor )
        let imageHeight = Int( userRect.height * scaleFactor )
        
        let context = CGContext(
            data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 16, bytesPerRow: 0,
            space: CGColorSpace( name: CGColorSpace.sRGB )!,
            bitmapInfo: CGBitmapInfo( rawValue: CGImageAlphaInfo.noneSkipLast.rawValue ).rawValue
        )!

        context.scaleBy( x: CGFloat( scaleFactor ), y: CGFloat( scaleFactor ) )
        
        if let fill = fill {
            let fillRect = userRect.offsetBy( dx: -userRect.minX, dy: -userRect.minY )
            context.setFillColor( fill.cgColor! )
            context.fill( [ fillRect ] )
        }
        
        context.translateBy( x: -userRect.minX, y: -userRect.minY )
        return context
    }
    
    func image( guiState: GuiState? = nil, info: IconInfo? = nil ) -> CGImage {
        let context = getContext( fill: background )

        drawPuzzle( context: context, guiState: guiState )
        drawStarts( context: context, guiState: guiState )
        drawFinishes( context: context, guiState: guiState )
        drawGaps( context: context, guiState: guiState )
        drawHexagons( context: context, guiState: guiState, info: info )
        drawIcons( context: context, guiState: guiState, info: info )

        return context.makeImage()!
    }
    
    mutating func adjustDimensions() -> Void {
        starts = starts.filter { $0.isValid( puzzle: self ) }
        finishes = finishes.filter { $0.isValid( puzzle: self ) }
        hexagons = hexagons.filter { $0.isValid( puzzle: self ) }
        gaps = gaps.filter { $0.isValid( puzzle: self ) }
        missings = missings.filter { $0.isValid( puzzle: self ) }
        icons = icons.filter { $0.isValid( puzzle: self ) }
    }
}
