//
//  ViewController.swift
//  BoredBeGone
//
//  Created by Justin Snider on 2/11/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    private var timer = Timer()
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var eventView: EventView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var dotOneImageView: UIImageView!
    @IBOutlet weak var dotTwoImageView: UIImageView!
    @IBOutlet weak var dotThreeImageView: UIImageView!
    @IBOutlet weak var dotImageStackView: UIStackView!
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        eventTitleLabel.adjustsFontSizeToFitWidth = true
        EventorController.shared.grabEvents { (events) in
            guard let events = events else { return }
            EventorController.shared.events = events
            DispatchQueue.main.async {
                self.eventTitleLabel.text = events[0].title
                self.eventDescriptionLabel.text = events[0].eventDescription
                self.eventDescriptionLabel.alpha = 1.0
                self.dotImageStackView.alpha = 0.0
            }
            self.timer.invalidate()
        }
        if EventorController.shared.events == [] {
            runTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Setting up a bottom border for the event title
        if eventTitleLabel.layer.sublayers == nil {
            eventTitleLabel.addBorder(side: .Bottom, thickness: 2, color: UIColor.black)
        }
        
    }
    
    //========================================
    //MARK: - Loading Methods
    //========================================
    
    @objc private func loadingEvents() {
        if dotOneImageView.image == UIImage(named: "DotFilled") {
            resetDots()
            dotTwoImageView.image = UIImage(named: "DotFilled")
        } else if dotTwoImageView.image == UIImage(named: "DotFilled") {
            resetDots()
            dotThreeImageView.image = UIImage(named: "DotFilled")
        } else if dotThreeImageView.image == UIImage(named: "DotFilled") {
            resetDots()
            dotOneImageView.image = UIImage(named: "DotFilled")
        }
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadingEvents), userInfo: nil, repeats: true)
    }
    
    private func resetDots() {
        dotOneImageView.image = UIImage(named: "Dot")
        dotTwoImageView.image = UIImage(named: "Dot")
        dotThreeImageView.image = UIImage(named: "Dot")
    }
}

extension UILabel {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    func addBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        
        switch side {
        case .Top:
            // Add leftOffset to our X to get start X position.
            // Add topOffset to Y to get start Y position
            // Subtract left offset from width to negate shifting from leftOffset.
            // Subtract rightoffset from width to set end X and Width.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset,
                                                                   height: thickness), color: color)
            self.layer.addSublayer(border)
        case .Right:
            // Subtract the rightOffset from our width + thickness to get our final x position.
            // Add topOffset to our y to get our start y position.
            // Subtract topOffset from our height, so our border doesn't extend past teh view.
            // Subtract bottomOffset from the height to get our end.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                   y: 0 + topOffset, width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        case .Bottom:
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: self.frame.size.height-thickness-bottomOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset, height: thickness), color: color)
            self.layer.addSublayer(border)
        case .Left:
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        }
    }
}

fileprivate func _getOneSidedBorder(frame: CGRect, color: UIColor) -> CALayer {
    let border:CALayer = CALayer()
    border.frame = frame
    border.backgroundColor = color.cgColor
    return border
}
