//         FILE: IconView.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/12/23 8:05 PM

import SwiftUI

struct IconView: View {
    @Binding var info: WitnessPuzzlesDocument.IconInfo

    var body: some View {
        VStack {
            ColorPicker( "Color", selection: $info.color )
            Divider()
            Picker( "Icon Type", selection: $info.iconType ) {
                ForEach( WitnessPuzzlesDocument.IconType.allCases ) {
                    let infoCopy = info.replacing( iconType: $0 )
                    WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                }
            }.pickerStyle( .segmented )
            if info.iconType == .triangles {
                VStack {
                    Picker( "Triangles Count", selection: $info.trianglesCount ) {
                        ForEach( WitnessPuzzlesDocument.TrianglesCount.allCases ) {
                            let infoCopy = info.replacing( trianglesCount: $0 )
                            WitnessPuzzlesDocument.Icon.image( size: 25, info: infoCopy ).tag( $0 )
                        }
                    }.pickerStyle( .segmented )
                }
            }
            if info.iconType == .tetris {
                TetrisView( info: $info )
            }
        }
        .frame( alignment: .center )
        .padding( 20 )
    }
}
