//
//  Task.swift
//  Smart tasks
//
//  Created by Filip on 26. 9. 2025..
//

import Foundation


struct Task: Codable {
    enum TaskStatus: String, Codable {
        case unresolved = "Unresolved"
        case resolved = "Resolved"
        case cantResolve = "Can't Resolve"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "Title"
        case description = "Description"
        case priority = "Priority"
        case dueDate = "DueDate"
        case targetDate = "TargetDate"
    }
    
    let id: String
    let title: String
    let description: String?
    let priority: Int
    let dueDate: Date?
    let targetDate: Date
    var status: TaskStatus = .unresolved
    var comment: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        priority = try container.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let targetDateString = try container.decode(String.self, forKey: .targetDate)
        targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        
        if let dueDateString = try container.decodeIfPresent(String.self, forKey: .dueDate) {
            dueDate = dateFormatter.date(from: dueDateString)
        } else {
            dueDate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(priority, forKey: .priority)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        try container.encode(dateFormatter.string(from: targetDate), forKey: .targetDate)
        if let dueDate = dueDate {
            try container.encode(dateFormatter.string(from: dueDate), forKey: .dueDate)
        }
    }
}
