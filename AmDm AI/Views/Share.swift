//
//  Share.swift
//  AmDm AI
//
//  Created by Anton on 03/04/2024.
//

import SwiftUI

struct Share: View {
    let label: String
    let content: String
    
    var body: some View {
        ActionButton(systemImageName: "square.and.arrow.up", title: label) {
            shareButton(content)
        }.frame(width: 18)
    }
}

func shareButton(_ content: String) {
    let activityController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
    
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    
    windowScene?.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
}

#Preview {
    Share(label: "Share...", content: "Chords by AmDm AI")

}
