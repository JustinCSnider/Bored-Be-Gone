//
//  FilterController.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

struct FilterController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = FilterController()
    var categories = [String]()
    let stateList: [String] = [
        "Alabama",
        "Alaska",
        "Arizona",
        "Arkansas",
        "California",
        "Colorado",
        "Connecticut",
        "Delaware",
        "Florida",
        "Georgia",
        "Hawaii",
        "Idaho",
        "Illinois",
        "Indiana",
        "Iowa",
        "Kansas",
        "Kentucky",
        "Louisiana",
        "Maine",
        "Maryland",
        "Massachusetts",
        "Michigan",
        "Minnesota",
        "Mississippi",
        "Missouri",
        "Montana",
        "Nebraska",
        "Nevada",
        "New Hampshire",
        "New Jersey",
        "New Mexico",
        "New York",
        "North Carolina",
        "North Dakota",
        "Ohio",
        "Oklahoma",
        "Oregon",
        "Pennsylvania",
        "Rhode Island",
        "South Carolina",
        "South Dakota",
        "Tennessee",
        "Texas",
        "Utah",
        "Vermont",
        "Virginia",
        "Washington",
        "West Virginia",
        "Wisconsin",
        "Wyoming",
    ]
    
    
    //========================================
    //MARK: - Network Methods
    //========================================
    
    func grabCategories(_ state: String, completion: (([String]?) -> Void)? = nil) {
        guard let url = URL(string: "https://api.predicthq.com/v1/events/count/?region=\(state)") else {
            print("Bad URL")
            return
        }
        
        NetworkController.performNetworkRequest(for: url, accessToken: "L3KQkKTpvMPFkoBaMhF1CcD5KCRiQ2") { (data, error) in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            var results = [String]()
            
            if let categories = try? decoder.decode(Categories.self, from: data) {
                results = Array(categories.categories.keys)
            }
            
            if let completion = completion {
                completion(results)
            }
        }
    }
    
}
