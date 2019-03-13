//
//  DetailViewController.swift
//  Eventor
//
//  Created by Justin Snider on 3/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var selectedEvent: Event?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting up labels
        titleLabel.adjustsFontSizeToFitWidth = true
        detailLabel.sizeToFit()
        
        if let selectedEvent = selectedEvent {
            //Setting up date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d', at 'h:mm a"
            
            //Setting up date formatter
            let date = dateFormatter.string(from: selectedEvent.startTime)
            
            titleLabel.text = selectedEvent.title
            detailLabel.text = "Date: \(date) \nLocation: \(selectedEvent.location) \n\n\(selectedEvent.eventDescription)"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Setting up a bottom border for the event title
        if titleLabel.layer.sublayers == nil {
            titleLabel.addBorder(side: .Bottom, thickness: 2, color: UIColor.black)
        }
    }

}
