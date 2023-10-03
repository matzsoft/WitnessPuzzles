//         FILE: HexagonView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/2/23 7:05 PM

import SwiftUI

struct HexagonView: View {
    @Binding var info: WitnessPuzzlesDocument.IconInfo

    var body: some View {
        ColorPicker( "Color", selection: $info.color )
        .frame( alignment: .center )
        .padding( 20 )
    }
}
