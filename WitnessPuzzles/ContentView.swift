//         FILE: ContentView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

struct ContentView: View {
    @Binding var document: WitnessPuzzlesDocument

    var body: some View {
        Image( nsImage: document.image )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( document: .constant( WitnessPuzzlesDocument() ) )
    }
}
