//
//  OptionsView.swift
//  AmDm AI
//
//  Created by Anton on 03/07/2024.
//

import SwiftUI

//struct OptionsView: View {
//    @Binding var hideLyrics: Bool
//    var initialValue: Int
//    var onChangeValue: (Int,Int) -> Void
//    @State private var value = 0
//    @State private var stepDisplay: String = "original"
//    private let step = 1
//    private let range = -10...10
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 50) {
//            VStack {
//                Text("Transpose")
//                
//                Stepper(value: $value, in: range, step: step, label: {})
//                    .labelsHidden()
//                
//                VStack {
//                    Text(" \(stepDisplay) ")
//                        .fontWeight(.semibold)
//                        .padding(5)
//                        .background(Color.gray10)
//                }
//                .frame(width: 140)
//            }
//            
//            VStack {
//                Text("Hide lyrics")
//                Toggle("", isOn: $hideLyrics)
//                    .labelsHidden()
//            }
//
//        }
//        .padding(.horizontal, 50)
//        .padding(.vertical, 20)
//        .onChange(of: value) { oldValue, newValue in
//            stepDisplay = getLabel(value)
//            onChangeValue(oldValue, newValue)
//        }
//        .onAppear {
//            value = initialValue
//            stepDisplay = getLabel(initialValue)
//        }
//    }
//    
//    func getLabel(_ value: Int) -> String {
//        var label: String = ""
//        let direction = stepDisplay != "orginal" ? (value < 0 ? "steps down" : (value > 0 ? "steps up" : "")) : ""
//
//        if value % 2 == 0 {
//            label = value == 0 ? "original" : String(abs(Int(value / 2)))
//        } else {
//            label = abs(value) == 1 ? NSLocalizedString("\u{00BD}", comment: "1/2") : (String(abs(Int(value / 2))) + NSLocalizedString("\u{00BD}", comment: "1/2"))
//        }
//        return "\(label) \(direction)"
//    }
//}

struct OptionsView: View {
    @Binding var hideLyrics: Bool
    var initialValue: Int
    var onChangeValue: (Int,Int) -> Void
    @State private var value = 0
    @State private var stepDisplay: String = "original"
    private let step = 1
    private let range = -10...10
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack {
                Toggle("Hide lyrics:", isOn: $hideLyrics)
            }
            .frame(width: 250)

            Spacer()

            HStack {
                Button {
                    value = value < 10 ? value + 1 : value
                } label: {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(value == 10 ? .secondaryText : .white)
                        .frame(width: 30, height: 30)
                }
                .disabled(value == 10)
                
                VStack(spacing: 0) {
                    Text("Transpose chords:")
                    VStack {
                        Text(" \(stepDisplay) ")
                            .fontWeight(.semibold)
                            .padding(5)
                            .background(Color.gray10)
                    }
                    .frame(width: 140)
                }
                .padding(.horizontal, 30)
                
                Button {
                    value = value > -10 ? value - 1 : value
                } label: {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(value == -10 ? .secondaryText : .white)
                        .frame(width: 30, height: 30)
                }
                .disabled(value == -10)
            }
            
            Spacer()
        }
        .onChange(of: value) { oldValue, newValue in
            stepDisplay = getLabel(value)
            onChangeValue(oldValue, newValue)
        }
        .onAppear {
            value = initialValue
            stepDisplay = getLabel(initialValue)
        }
    }
    
    private func getLabel(_ value: Int) -> String {
        var label: String = ""
        let direction = stepDisplay != "orginal" ? (value < 0 ? "steps down" : (value > 0 ? "steps up" : "")) : ""

        if value % 2 == 0 {
            label = value == 0 ? "original" : String(abs(Int(value / 2)))
        } else {
            label = abs(value) == 1 ? NSLocalizedString("\u{00BD}", comment: "1/2") : (String(abs(Int(value / 2))) + NSLocalizedString("\u{00BD}", comment: "1/2"))
        }
        return "\(label) \(direction)"
    }

}

struct TranspositionAds: View {
    var body: some View {
        VStack {
            Text("Chords transposition")
        }
    }
}
