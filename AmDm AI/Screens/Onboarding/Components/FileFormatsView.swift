//
//  FileFormatsView.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct FileFormatsView: View {
    var width: CGFloat
    private var fileFormatWidth: CGFloat
    
    init(width: CGFloat) {
        self.width = width
        self.fileFormatWidth = width / 6
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width - fileFormatWidth + 4, height: 40)
                .border(.gray30, width: 1)
            
            HStack(spacing: 0) {
                Text("MP3")
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: fileFormatWidth, height: 40)
                Rectangle()
                    .foregroundColor(.gray30)
                    .frame(width: 1, height: 40)
                Text("MPeg4")
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: fileFormatWidth, height: 40)
                Rectangle()
                    .foregroundColor(.gray30)
                    .frame(width: 1, height: 40)
                Text("M4A")
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: fileFormatWidth, height: 40)
                Rectangle()
                    .foregroundColor(.gray30)
                    .frame(width: 1, height: 40)
                Text("WAV")
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: fileFormatWidth, height: 40)
                Rectangle()
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: 1, height: 40)
                Text("And more")
                    .foregroundColor(.gray30)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(width: fileFormatWidth, height: 40)
                Rectangle()
                    .foregroundColor(.gray30)
                    .frame(width: 1, height: 40)
            }
        }
    }
}
