//
//  Event.swift
//  Eventor
//
//  Created by Justin Snider on 2/13/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject, Decodable {
    @NSManaged var title: String
    @NSManaged var eventDescription: String
    @NSManaged var startTime: Date
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var location: String
    
    static var entityName: String { return "Event" }
    
    enum CodingKeys: String, CodingKey {
        case title
        case eventDescription = "description"
        case startTime = "start"
        case location
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: NSEntityDescription.entity(forEntityName: Event.entityName, in: Stack.context)!, insertInto: Stack.context)
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        let location = try valueContainer.decode([Double].self, forKey: CodingKeys.location)
        self.title = try valueContainer.decode(String.self, forKey: CodingKeys.title)
        self.eventDescription = try valueContainer.decode(String.self, forKey: CodingKeys.eventDescription)
        self.startTime = try valueContainer.decode(Date.self, forKey: CodingKeys.startTime)
        self.longitude = location[0]
        self.latitude = location[1]
        self.location = ""
    }
}

struct Events: Decodable {
    let results: [Event]
    let next: String?
}

