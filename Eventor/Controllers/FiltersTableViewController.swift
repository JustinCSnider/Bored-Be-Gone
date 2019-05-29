//
//  FiltersTableViewController.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

protocol FilterSwitchDelegate {
    func createQuery() -> [String : String]
}

class FiltersTableViewController: UITableViewController, FilterSwitchDelegate {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var isStatePickerHidden = true
    
    //========================================
    //MARK: - Table View Data Source
    //========================================

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Table view cell amount is based on category amount plus one for the state cell at the top
        return FilterController.shared.categories.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        //Sets first cell to state cell and the rest to filter cells
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! StateTableViewCell
            
        } else {
            //Setting up filtercell
            let filterCell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableViewCell

            //Setting text for categorylabel and setting the delegate so createQuery can be called at necessary time
            filterCell.categoryLabel.text = FilterController.shared.categories[indexPath.row - 1]
            filterCell.delegate = self
            
            //Setting cell to filtercell
            cell = filterCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44)
        let largeCellHeight = CGFloat(200)
        
        //Set cell height based on whether it is the statecell and it's been selected or not
        switch(indexPath) {
        case [0,0]:
            return isStatePickerHidden ? normalCellHeight : largeCellHeight
            
        default: return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath) {
        case [0,0]:
            //Grabbing current table view cell
            let currentCell = tableView.cellForRow(at: indexPath) as! StateTableViewCell
            
            //Setting up determining boolean and changing stateLabel text color
            isStatePickerHidden = !isStatePickerHidden
            currentCell.stateLabel.textColor = isStatePickerHidden ? .black : tableView.tintColor
            
            //Setting up category cells and query values
            if isStatePickerHidden {
                setUpCategories(currentCell)
            }
            
            //Updating cells
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            //Grabbing current table view cell
            let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! StateTableViewCell
            
            //Changing stateLabel text color
            firstCell.stateLabel.textColor = .black
            
            //Setting up category cells and query values
            setUpCategories(firstCell)
            
            //Setting up variable for logic based functionality
            isStatePickerHidden = true
            
            //Updating cells
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    func createQuery() -> [String : String] {
        //Creates initial query
        var query = [
            "region" : (tableView.visibleCells[0] as! StateTableViewCell).stateLabel.text ?? "",
            "category" : ""
        ]
        
        //Fills query with all available categories for that specific location
        for i in self.tableView.visibleCells {
            if let currentCell = i as? FilterTableViewCell, currentCell.filterSwitch.isOn {
                query["category"]?.append("\(currentCell.categoryLabel.text ?? ""),")
            }
        }
        
        //Removing extra comma at the end of the category string
        if query["category"]?.last == "," {
            query["category"]?.removeLast()
        }
        
        return query
    }
    
    func setUpCategories(_ currentCell: StateTableViewCell) {
        FilterController.shared.grabCategories((currentCell.stateLabel.text ?? "")) { (categories) in
            //Unwrapping categories
            guard let categories = categories else { return }
            
            //Setting variables
            FilterController.shared.categories = categories
            DispatchQueue.main.async {
                self.tableView.reloadData()
                EventorController.shared.setQuery(self.createQuery())
            }
            
            //Setting up variable for logic based functionality
            FilterController.shared.filterPageUsed = true
            EventorController.shared.resetCurrentEventIndex()
        }
    }

}
