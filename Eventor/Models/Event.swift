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
    
    static var entityName: String { return "Event" }
    
    enum CodingKeys: String, CodingKey {
        case title
        case eventDescription = "description"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: NSEntityDescription.entity(forEntityName: Event.entityName, in: Stack.context)!, insertInto: Stack.context)
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try valueContainer.decode(String.self, forKey: CodingKeys.title)
        self.eventDescription = try valueContainer.decode(String.self, forKey: CodingKeys.eventDescription)
    }
}

struct Events: Decodable {
    let results: [Event]
}
