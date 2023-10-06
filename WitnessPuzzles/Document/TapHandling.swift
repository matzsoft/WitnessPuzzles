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
    mutating func processTap( state: GuiState, iconInfo: IconInfo ) -> Bool {
        switch state.selectedTool {
        case nil:
            break
        case .starts:
            if startExists( point: state.location ) {
                removeStart( point: state.location )
            } else if isStartPositionOK( point: state.location ) {
                addStart( point: state.location )
            } else {
                return false
            }
        case .finishes:
            return false
        case .gaps:
            if gapExists( point: state.location ) {
                removeGap( point: state.location )
            } else if isGapPositionOK( point: state.location ) {
                addGap( point: state.location )
            } else {
                return false
            }
        case .missings:
            if missingExists( point: state.location ) {
                removeMissing( point: state.location )
            } else if isMissingPositionOK( point: state.location ) {
                addMissing( point: state.location )
            } else {
                return false
            }
        case .hexagons:
            if hexagonExists( point: state.location ) {
                removeHexagon( point: state.location )
            } else if isHexagonPositionOK( point: state.location ) {
                addHexagon( point: state.location, info: iconInfo )
            } else {
                return false
            }
        case .icons:
            if iconExists( point: state.location ) {
                removeIcon( point: state.location )
            } else if isIconPositionOK( point: state.location ) {
                addIcon( point: state.location, info: iconInfo )
            } else {
                return false
            }
        }
        
        return true
    }
}
