//
//  ScannedText.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import SwiftData
import Foundation

struct ScanData: Identifiable {
    var id = UUID()
    
    let content: String
    init(content: String) {
        self.content = content
    }
}
