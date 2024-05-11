//
//  TunerView.swift
//  AmDm AI
//
//  Created by Anton on 11/05/2024.
//

import SwiftUI

struct TunerView: View {
    @Binding var isTunerPresented: Bool
    @StateObject var conductor = TunerConductor()

    var body: some View {
        VStack {
            HStack {
                ActionButton(imageName: "chevron.left", title: "Back") {
                    isTunerPresented = false
                }
                .frame(height: 18)
                .font(.system(size: 18))
                .padding(.vertical, 10)
                .padding(.horizontal,5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            Spacer()
            HStack {
                Text("Frequency")
                Spacer()
                Text("\(conductor.data.pitch, specifier: "%0.1f")")
            }
            .padding()

            HStack {
                Text("Amplitude")
                Spacer()
                Text("\(conductor.data.amplitude, specifier: "%0.1f")")
            }
            .padding()

            HStack {
                Text("Note Name")
                Spacer()
                Text("\(conductor.data.noteNameWithSharps) / \(conductor.data.noteNameWithFlats)")
            }
            .padding()
            Spacer()
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
