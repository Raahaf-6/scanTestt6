//
//  ScanEntity.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import SwiftData
import Foundation

@Model
class ScanEntity {
    @Attribute(.unique) var id: UUID
    var content: String
    var date: Date
    
    init(content: String, date: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.date = date
    }
}
