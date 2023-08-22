//         FILE: WitnessPuzzlesApp.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 8/22/23 2:06 PM

import SwiftUI

@main
struct WitnessPuzzlesApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: WitnessPuzzlesDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
