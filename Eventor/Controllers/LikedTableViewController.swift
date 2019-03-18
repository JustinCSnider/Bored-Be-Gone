//
//  FavoritesTableViewController.swift
//  Eventor
//
//  Created by Justin Snider on 3/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit
import CoreData

class LikedTableViewController: UITableViewController {
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //========================================
    //MARK: - Table View Data Source
    //========================================

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventorController.shared.getLikedEvents().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likedCellIdentifier", for: indexPath)
        
        //Setting up convience variables for getting data
        let eventorController = EventorController.shared
        let currentLikedEvent = eventorController.getLikedEvents()[indexPath.row]
        
        //Setting up date formatter for using start time as the detail text label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d', at 'h:mm a"
        
        //Setting cell labels
        cell.textLabel?.text = currentLikedEvent.title
        cell.detailTextLabel?.text = dateFormatter.string(from: currentLikedEvent.startTime)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Setting up convience variable
            let eventorController = EventorController.shared
            
            //Removing current event from all necessary data areas
            Stack.context.delete(eventorController.getLikedEvents()[indexPath.row])
            EventorController.shared.removeLikedEvent(event: eventorController.getLikedEvents()[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //========================================
    //MARK: - Navigation methods
    //========================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? DetailViewController, let selectedEventIndex = tableView.indexPathForSelectedRow?.row {
            //Grabbing current selected event and setting detail views event
            let selectedEvent = EventorController.shared.getLikedEvents()[selectedEventIndex]
            destination.selectedEvent = selectedEvent
        }
    }

}
