//         FILE: TapHandling.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 10/6/23 2:31 PM

import Foundation
import SwiftUI

extension WitnessPuzzlesDocument {
    mutating func processTap( guiState: GuiState, iconInfo: IconInfo ) -> GuiState? {
        switch guiState.selectedTool {
        case nil:
            break
        case .starts:
            if startExists( point: guiState.location ) {
                removeStart( point: guiState.location )
            } else if isStartPositionOK( point: guiState.location ) {
                addStart( point: guiState.location )
            } else {
                return nil
            }
        case .finishes:
            guard let finish = guiState.finish else { return nil }
            if finishes.contains( where: { $0 == finish } ) {
                removeFinish( point: finish.position )
            } else if finish.isValid( puzzle: self ) {
                addFinish( point: finish.position, direction: finish.direction )
            } else {
                return nil
            }
        case .gaps:
            if gapExists( point: guiState.location ) {
                removeGap( point: guiState.location )
            } else if isGapPositionOK( point: guiState.location ) {
                addGap( point: guiState.location )
            } else {
                return nil
            }
        case .missings:
            if missingExists( point: guiState.location ) {
                removeMissing( point: guiState.location )
            } else if isMissingPositionOK( point: guiState.location ) {
                addMissing( point: guiState.location )
            } else {
                return nil
            }
        case .hexagons:
            if hexagonExists( point: guiState.location ) {
                removeHexagon( point: guiState.location )
            } else if isHexagonPositionOK( point: guiState.location ) {
                addHexagon( point: guiState.location, info: iconInfo )
            } else {
                return nil
            }
        case .icons:
            if iconExists( point: guiState.location ) {
                removeIcon( point: guiState.location )
            } else if isIconPositionOK( point: guiState.location ) {
                addIcon( point: guiState.location, info: iconInfo )
            } else {
                return nil
            }
        }
        
        return guiState
    }
    
    func processHover( guiState: GuiState, viewLocation: CGPoint ) -> GuiState {
        let guiState = guiState.replacing( location: toPuzzleSpace( from: viewLocation ) )

        switch guiState.selectedTool {
        case .finishes:
            return adjustFinish( guiState: guiState, viewLocation: viewLocation )
        default:
            break
        }
        return guiState
    }
    
    func adjustFinish( guiState: GuiState, viewLocation: CGPoint ) -> GuiState {
        if isConnected( point: guiState.location ) { return guiState }
        if let sector = originSector( guiState: guiState, viewLocation: viewLocation ) {
            let origin = guiState.location + sector.vector
            
            if isConnected( point: origin ){
                let direction = Direction( from: origin, to: guiState.location )!
                
                if Finish.validDirection( from: origin, direction: direction, in: self ) {
                    return guiState.replacing( finish: Finish( position: origin, direction: direction ) )
                }
            }
        }
        
        return guiState
    }
    
    func originSector( guiState: GuiState, viewLocation: CGPoint ) -> Direction? {
        let context = getContext()
        let userLocation = context.convertToUserSpace( viewLocation )
        let userCenter = guiState.location.puzzle2user( puzzle: self ).cgPoint

        switch true {
        case guiState.location.isVertical:
            return userLocation.y > userCenter.y ? .north : .south
        case guiState.location.isHorizontal:
            return userLocation.x > userCenter.x ? .east : .west
        case guiState.location.isBlock:
            let xDelta = userLocation.x - userCenter.x
            let yDelta = userLocation.y - userCenter.y
            let x = ( abs( xDelta ) < CGFloat( blockWidth ) / 3 ) ? 0 : Int( xDelta ).signum()
            let y = ( abs( yDelta ) < CGFloat( blockWidth ) / 3 ) ? 0 : Int( yDelta ).signum()
            
            return Direction( from: guiState.location, to: guiState.location + Point( x, y ) )
        default:
            return nil
        }
    }
}
