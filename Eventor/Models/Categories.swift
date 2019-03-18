//
//  Categories.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

//Used to grab category names for filtersTableViewController
struct Categories: Decodable {
    let categories: [String : Int]
}
