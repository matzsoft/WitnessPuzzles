//         FILE: SliderViews.swift
//  DESCRIPTION: WitnessPuzzles - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2023 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 9/21/23 12:41 PM

import SwiftUI

struct DoubleSlider: View {
    @Binding var value: CGFloat
    @State var localValue: CGFloat
    let range: ClosedRange<CGFloat>
    let step: Double
    let label: String
    let format: String
    
    init(
        value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: Double,
        label: String, format: String = "%.0f"
    ) {
        self._value = value
        self._localValue = State( initialValue: value.wrappedValue )
        self.range = range
        self.step = step
        self.label = label
        self.format = format
    }
    
    var body: some View {
        VStack {
            Slider( value: $localValue, in: range, step: step ) {
                Text( label )
            } minimumValueLabel: {
                Text( String( format: "%.0f", range.lowerBound ) )
            } maximumValueLabel: {
                Text( String( format: "%.0f", range.upperBound ) )
            } onEditingChanged: { _ in
                value = localValue
            }
            .tint( .black )
            Text( "\(localValue, specifier: format)" )
        }
    }
}
