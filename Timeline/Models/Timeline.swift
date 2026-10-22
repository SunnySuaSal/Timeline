//
//  Timeline.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//

import Foundation
import SwiftData

@Model
final class Timeline {
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \TimelineEvent.timeline)
    var events: [TimelineEvent] = []
    
    init(name: String){
        self.name = name
        self.createdAt = .now
    }
}
