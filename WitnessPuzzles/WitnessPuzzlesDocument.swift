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
    var starts = [ Point(2,2) ]
    var finishes = [ Point(64,64) ]
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
            size: CGSize( width: userWidth, height: userWidth ) )
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
        let startExtra = max( starts.map { startRadius - $0.x }.max() ?? 0, 0 )
        let finishExtra = max( finishes.map { finishRadius - $0.x }.max() ?? 0, 0 )
        
        return startExtra + finishExtra
    }

    func extraBottom() -> Int {
        let startExtra = max( starts.map { startRadius - $0.y }.max() ?? 0, 0 )
        let finishExtra = max( finishes.map { finishRadius - $0.y }.max() ?? 0, 0 )
        
        return startExtra + finishExtra
    }

    func extraRight() -> Int {
        let startExtra = max( ( starts.map { $0.x + startRadius }.max() ?? 0 ) - baseWidth, 0 )
        let finishExtra = max( ( finishes.map { $0.x + finishRadius }.max() ?? 0 ) - baseWidth, 0 )
        
        return startExtra + finishExtra
    }

    func extraTop() -> Int {
        let startExtra = max( ( starts.map { $0.y + startRadius }.max() ?? 0 ) - baseHeight, 0 )
        let finishExtra = max( ( finishes.map { $0.y + finishRadius }.max() ?? 0 ) - baseHeight, 0 )
        
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
    
    func drawStarts( context: CGContext ) -> Void {
        for start in starts {
            context.addEllipse( in: CGRect(
                x: start.x - startRadius, y: start.y - startRadius,
                width: 2 * startRadius, height: 2 * startRadius
            ) )
        }
    }

    func drawFinishes( context: CGContext ) -> Void {
        for finish in finishes {
            context.saveGState()
            context.translateBy( x: CGFloat( finish.x ), y: CGFloat( finish.y ) )
            context.addEllipse( in: CGRect(
                x: -finishRadius, y: -finishRadius,
                width: 2 * finishRadius, height: 2 * finishRadius
            ) )
            
            let angle = {
                switch ( ( finish.x, finish.y ) ) {
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
                    fatalError( "Unsopported finish location (\(finish.x),\(finish.y))")
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
    
    func isValid( start: Point ) -> Bool {
        let begin = lineWidth / 2
        let endx  = width * ( lineWidth + blockWidth ) + lineWidth / 2
        let endy  = height * ( lineWidth + blockWidth ) + lineWidth / 2
        let increment = lineWidth + blockWidth
        
        let validX = {
            switch type {
            case .rectangle: return Set( stride( from: begin, through: endx, by: increment ) )
            case .cylinder:  return Set( stride( from: begin, to: endx, by: increment ) )
            }
        }()
        let validY = Set( stride( from: begin, through: endy, by: increment ) )
        
        return validX.contains( start.x ) && validY.contains( start.y )
    }
    
    func isValid( finish: Point ) -> Bool {
        switch ( finish.x, finish.y ) {
        case ( 0, 0 ), ( 0, baseHeight ), ( baseWidth, baseHeight ), ( baseWidth, 0 ): return true
        default: break
        }
        
        let begin = lineWidth / 2
        let endx  = width * ( lineWidth + blockWidth ) + lineWidth / 2
        let endy  = height * ( lineWidth + blockWidth ) + lineWidth / 2
        let increment = lineWidth + blockWidth
        
        let validX = {
            switch type {
            case .rectangle: return Set( stride( from: begin, through: endx, by: increment ) )
            case .cylinder:  return Set( stride( from: begin, to: endx, by: increment ) )
            }
        }()
        let validY = Set( stride( from: begin, through: endy, by: increment ) )
        
        if ( finish.y == -1 || finish.y == baseHeight + 1 ) {
            return validX.contains( finish.x )
        }
        
        if ( type == .rectangle && ( finish.x == -1 || finish.x == baseWidth + 1 ) ) {
            return validY.contains( finish.y )
        }
        
        return false
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
