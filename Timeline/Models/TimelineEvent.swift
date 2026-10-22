//
//  TimelineEvent.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//

import Foundation
import SwiftData

@Model
final class TimelineEvent {
    var title: String
    var date: Date
    var notes: String?
    
    var timeline: Timeline?
    
    init(
        title: String,
        date: Date,
        notes: String? = nil
    ) {
        self.title = title
        self.date = date
        self.notes = notes
    }
}
