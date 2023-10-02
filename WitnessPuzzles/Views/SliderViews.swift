//         FILE: SliderViews.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/21/23 12:41 PM

import SwiftUI

struct IntSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Double>
    let step: Double
    let label: String
    
    var intProxy: Binding<Double> {
        Binding<Double>(
            get: { return Double( value ) },
            set: { value = Int($0) }
        )
    }
    
    var body: some View {
        VStack{
            Slider( value: intProxy, in: range, step: step ) {
                Text( label )
            } minimumValueLabel: {
                Text( String( format: "%.0f", range.lowerBound ) )
            } maximumValueLabel: {
                Text( String( format: "%.0f", range.upperBound ) )
            }
            .tint( .black )
            Text( String( value ) )
        }
    }
}


struct DoubleSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: Double
    let label: String
    
    var body: some View {
        VStack{
            Slider( value: $value, in: range, step: step ) {
                Text( label )
            } minimumValueLabel: {
                Text( String( format: "%.0f", range.lowerBound ) )
            } maximumValueLabel: {
                Text( String( format: "%.0f", range.upperBound ) )
            }
            .tint( .black )
            Text( String( format: "%.1f", value ) )
        }
    }
}
