//
//  EventView.swift
//  Eventor
//
//  Created by Justin Snider on 2/14/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

@IBDesignable
class EventView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    override func awakeFromNib() {
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    }
}
