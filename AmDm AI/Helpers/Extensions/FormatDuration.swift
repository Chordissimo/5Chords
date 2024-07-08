//
//  FormatDuration.swift
//  AmDm AI
//
//  Created by Anton on 07/07/2024.
//

import Foundation

extension String {
    func getYoutubeDuration() -> Int {
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var h = 0, m = 0, s = 0
        
        if components.count > 0 {
            if components.count == 3 {
                h = (Int(components[0]) ?? 0) * 60 * 60
                m = (Int(components[1]) ?? 0) * 60
                s = Int(components[0]) ?? 0
            } else if components.count == 2 {
                m = (Int(components[0]) ?? 0) * 60
                s = Int(components[1]) ?? 0
            } else {
                s = Int(components[1]) ?? 0
            }
        }
        
        return h + m + s
    }
}
