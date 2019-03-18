//
//  StateTableViewCell.swift
//  Eventor
//
//  Created by Justin Snider on 3/15/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var statePickerView: UIPickerView!
    @IBOutlet weak var stateLabel: UILabel!
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func awakeFromNib() {
        super.awakeFromNib()
        statePickerView.delegate = self
        statePickerView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //========================================
    //MARK: - Picker View Data Source and Delegate Methods
    //========================================
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FilterController.shared.stateList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return FilterController.shared.stateList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateLabel.text = FilterController.shared.stateList[row]
    }

}
