//         FILE: Finish.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/1/23 11:15 AM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    struct Finish: PuzzleItem {
        let position: Point
        let direction: Direction
        
        static let circleRect = CGRect( x: -1, y: -1, width: 2, height: 2 )
        static let stemRect = CGRect( x: -1, y: -2, width: 2, height: 2 )
        
        func extent( puzzle: WitnessPuzzlesDocument ) -> CGRect {
            let location = position.puzzle2user( puzzle: puzzle )
            let offset = offset( distance: puzzle.lineWidth / 2, extra: 1 )
            let center = ( location + offset ).cgPoint
            let radius = CGFloat( puzzle.finishRadius )
            
            return CGRect(
                x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius
            )
        }
        
        func isValid( puzzle: WitnessPuzzlesDocument ) -> Bool {
            guard puzzle.isConnected( point: position ) else { return false }
            return Finish.validDirection( from: position, direction: direction, in: puzzle )
        }
        
        static func isValid( position: Point, puzzle: WitnessPuzzlesDocument ) -> Bool {
            guard puzzle.isConnected( point: position ) else { return false }
            return Finish.validDirections( for: position, in: puzzle ) != nil
        }

        var angle: Double {
            switch direction {
            case .north:     return 0 * Double.pi / 4
            case .northeast: return 7 * Double.pi / 4
            case .east:      return 6 * Double.pi / 4
            case .southeast: return 5 * Double.pi / 4
            case .south:     return 4 * Double.pi / 4
            case .southwest: return 3 * Double.pi / 4
            case .west:      return 2 * Double.pi / 4
            case .northwest: return 1 * Double.pi / 4
            }
        }
        
        func offset( distance: Int, extra: Int ) -> Point {
            let vector = direction.vector
            switch direction {
            case .north, .east, .south, .west:
                return Point( vector.x * ( distance + extra ), vector.y * ( distance + extra ) )
            case .northeast, .southeast, .southwest, .northwest:
                return Point( vector.x * distance, vector.y * distance )
            }
        }
        
        static func validDirection(
            from: Point, direction: Direction, in puzzle: WitnessPuzzlesDocument
        ) -> Bool {
            let destination = puzzle.neighbor( of: from, in: direction )

            switch true {
            case from.isLine:
                guard destination.isBlock else { return false }
                guard destination.isPuzzleSpace( puzzle: puzzle ) else { return true }
                return !puzzle.isConnected( point: destination )
            case from.isIntersection:
                if destination.isLine {
                    guard destination.isPuzzleSpace( puzzle: puzzle ) else { return true }
                    return puzzle.missings.contains { destination == $0.position }
                }
                if puzzle.isConnected( point: destination ) { return false }
                let components = direction.components.filter { componentDirection in
                    let line = puzzle.neighbor( of: from, in: componentDirection )
                    if !line.isPuzzleSpace( puzzle: puzzle ) { return true }
                    return puzzle.missings.contains { line == $0.position }
                }
                return components.count != 1
            default:
                return false
            }
        }
        
        static func validDirections( for point: Point, in puzzle: WitnessPuzzlesDocument ) -> [Direction]? {
            guard point.isPuzzleSpace( puzzle: puzzle ) else { return nil }
            if puzzle.missings.contains( where: { point == $0.position } ) { return nil }
            
            let acceptable = {
                switch true {
                case point.isVertical:
                    return [Direction]( [ .east, .west ] ).filter {
                        Finish.validDirection( from: point, direction: $0, in: puzzle )
                    }
                case point.isHorizontal:
                    return [Direction]( [ .north, .south ] ).filter {
                        Finish.validDirection( from: point, direction: $0, in: puzzle )
                    }
                case point.isIntersection:
                    return Direction.allCases.filter {
                        Finish.validDirection( from: point, direction: $0, in: puzzle )
                    }
                default:
                    return []
                }
            }()
            
            return acceptable.isEmpty ? nil : acceptable
        }
    }

    func drawFinishes( context: CGContext ) -> Void {
        func draw( finish: Finish ) {
            let extent = finish.extent( puzzle: self )
            context.saveGState()
            context.translateBy( x: extent.midX, y: extent.midY )
            context.scaleBy( x: extent.width / 2, y: extent.height / 2 )
            context.addEllipse( in: Finish.circleRect )
            
            context.rotate( by: finish.angle )
            context.addRect( Finish.stemRect )
            context.restoreGState()
        }
        
        context.saveGState()
        context.setFillColor( foreground.cgColor! )
        context.beginPath()

        for finish in finishes {
            draw( finish: finish )
            if let wrapped = type.wrap( point: finish.position, puzzle: self ) {
                draw( finish: Finish( position: wrapped, direction: finish.direction ) )
            }
        }
        context.fillPath()
        context.restoreGState()
    }
    
    func finishExists( point: Point ) -> Bool {
        return finishes.contains { point == $0.position }
    }
    
    func isFinishPositionOK( point: Point ) -> Bool {
        return Finish.isValid( position: point, puzzle: self ) &&
                !starts.contains { point == $0.position } &&
                !gaps.contains { point == $0.position } &&
                !missings.contains { point == $0.position }
    }
    
    mutating func removeFinish( point: Point ) -> Void {
        finishes = finishes.filter { $0.position != point }
    }

    mutating func addFinish( point: Point, direction: Direction ) -> Void {
        let newFinish = Finish( position: point, direction: direction )
        
        if newFinish.isValid( puzzle: self ) {
            finishes.insert( newFinish )
        }
    }
}
