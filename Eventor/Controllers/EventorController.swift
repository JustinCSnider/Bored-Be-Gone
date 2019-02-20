//
//  EventorController.swift
//  Eventor
//
//  Created by Justin Snider on 2/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

class EventorController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = EventorController()
    var events = [Event]()
    
    //========================================
    //MARK: - Network Methods
    //========================================
    
    func grabEvents(completion: (([Event]?) -> Void)? = nil) {
        guard let url = URL(string: "https://api.predicthq.com/v1/events/") else {
            print("Bad URL")
            return
        }
        
        NetworkController.performNetworkRequest(for: url, accessToken: "L3KQkKTpvMPFkoBaMhF1CcD5KCRiQ2") { (data, error) in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            var results = [Event]()
            
            if let events = try? decoder.decode(Events.self, from: data) {
                results = events.results
            }
            
            if let completion = completion {
                completion(results)
            }
        }
    }
    
    //========================================
    //MARK: - Data Persistence Methods
    //========================================
    
    func saveToPersistentStorage() {
        do {
            try Stack.context.save()
        } catch {
            Stack.context.rollback()
        }
    }
}
