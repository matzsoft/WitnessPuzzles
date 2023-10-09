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
            if guiState.findingDirection {
                if guiState.location != guiState.origin &&
                    guiState.directions.contains( guiState.location )
                {
                    if let direction = Direction( from: guiState.origin, to: guiState.location ) {
                        addFinish( point: guiState.origin, direction: direction )
                        return guiState.replacing( findingDirection: false )
                    }
                }
                return nil
            }
            
            if finishExists( point: guiState.location ) {
                removeFinish( point: guiState.location )
                return guiState
            }
            return nil
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
    
    func processHover( guiState: GuiState ) -> GuiState {
        switch guiState.selectedTool {
        case .finishes:
            if finishes.contains( where: { $0.position == guiState.location } ) {
                return guiState.replacing( findingDirection: false )
            }
            if guiState.findingDirection {
                if guiState.location == guiState.origin              { return guiState }
                if guiState.directions.contains( guiState.location ) { return guiState }
                return guiState.replacing( findingDirection: false )
            }
            if !isFinishPositionOK( point: guiState.location ) {
                return guiState
            }
            if let directions = Finish.validDirections( for: guiState.location, in: self ) {
                let positons = Set( directions.map { guiState.location + $0.vector } )
                return guiState.replacing(
                    findingDirection: true, origin: guiState.location, directions: positons
                )
            }
            return guiState.replacing( findingDirection: false )
        default:
            return guiState
        }
    }
}
