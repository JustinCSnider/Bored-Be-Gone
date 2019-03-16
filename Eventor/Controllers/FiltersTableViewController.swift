//
//  FiltersTableViewController.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class FiltersTableViewController: UITableViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var isStatePickerHidden = true

    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //========================================
    //MARK: - Table View Data Source
    //========================================

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterController.shared.categories.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! StateTableViewCell
            
        } else {
            let filterCell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableViewCell

            filterCell.categoryLabel.text = FilterController.shared.categories[indexPath.row - 1]
            
            cell = filterCell
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44)
        let largeCellHeight = CGFloat(200)
        
        switch(indexPath) {
        case [0,0]:
            return isStatePickerHidden ? normalCellHeight : largeCellHeight
            
        default: return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath) {
        case [0,0]:
            isStatePickerHidden = !isStatePickerHidden
            
            let currentCell = tableView.cellForRow(at: indexPath) as! StateTableViewCell
            
            currentCell.stateLabel.textColor = isStatePickerHidden ? .black : tableView.tintColor
            
            if isStatePickerHidden {
                FilterController.shared.grabCategories((currentCell.stateLabel.text ?? "")) { (categories) in
                    guard let categories = categories else { return }
                    FilterController.shared.categories = categories
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            isStatePickerHidden = true
            
            let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! StateTableViewCell
            
            firstCell.stateLabel.textColor = .black
            
            FilterController.shared.grabCategories((firstCell.stateLabel.text ?? "")) { (categories) in
                guard let categories = categories else { return }
                FilterController.shared.categories = categories
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

}
