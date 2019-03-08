//
//  NetworkController.swift
//  Eventor
//
//  Created by Justin Snider on 2/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

struct NetworkController {
    
    static func performNetworkRequest(for url: URL, accessToken: String?, completion: ((Data?, Error?) -> Void)? = nil) {
        
        var request = URLRequest(url: url)
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let completion = completion {
                
                completion(data, error)
            }
        }
        dataTask.resume()
    }
}
