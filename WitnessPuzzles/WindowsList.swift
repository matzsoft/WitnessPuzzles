//         FILE: WindowsList.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 10/1/23 4:45 PM

import Foundation
import SwiftUI

struct WindowsList {
    var list = [ Binding<WitnessPuzzlesDocument> ]()
    
    static var shared = WindowsList()
    
    private init() {}
    
    mutating func add( binding: Binding<WitnessPuzzlesDocument> ) -> Int {
        let id = list.count
        list.append( binding )
        return id
    }
    
    func binding( id: Int ) -> Binding<WitnessPuzzlesDocument> {
        guard list.indices.contains( id ) else { fatalError( "Window id \(id) is invalid." ) }
        return list[id]
    }
}
