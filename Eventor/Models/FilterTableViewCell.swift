//
//  FilterTableViewCell.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var delegate: FilterSwitchDelegate?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func filterSwitchTapped(_ sender: UISwitch) {
        //Changing text color to show whether a filter is on or off
        if sender.isOn == false {
            categoryLabel.textColor = .lightGray
        } else {
            categoryLabel.textColor = .black
        }
        //Used to set query up after changing filters
        delegate?.createQuery()
    }
    
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
