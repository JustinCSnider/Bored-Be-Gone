//
//  ViewController.swift
//  Eventor
//
//  Created by Justin Snider on 2/11/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    //Swipe and tap animation properties
    private var eventViewTopSpaceConstraint = NSLayoutConstraint()
    private var eventViewBottomSpaceConstraint = NSLayoutConstraint()
    private var divisor: CGFloat!
    private var eventViewTapped = false
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    //Event View outlets
    @IBOutlet weak var eventView: EventView!
    @IBOutlet weak var eventViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var eventViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventScrollView: UIScrollView!
    
    //Tap Gesture outlets
    @IBOutlet var eventViewRecognizer: UITapGestureRecognizer!
    @IBOutlet var homeViewRecognizer: UITapGestureRecognizer!
    
    //Event details outlets
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet var eventDescriptionHeightConstraint: NSLayoutConstraint!
    
    //Loading events outlets
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    //Swipe functionality outlets
    @IBOutlet weak var thumbImageView: UIImageView!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        if sender == eventViewRecognizer {
            //Setting up programmatic top and bottom constraints
            eventViewTopSpaceConstraint = eventView.topAnchor.constraint(lessThanOrEqualTo: self.view.topAnchor, constant: 120)
            eventViewBottomSpaceConstraint = eventView.bottomAnchor.constraint(greaterThanOrEqualTo: self.view.bottomAnchor, constant: -170)
            
            //Animating constraints and shadow offsets for event view along with deactivating conflicting constraints
            animateConstraints(withDuration: 0.5, inActive: [eventViewTopSpaceConstraint, eventViewBottomSpaceConstraint], active: [eventViewHeightConstraint, eventDescriptionHeightConstraint], stayingActive: [eventViewLeadingConstraint, eventViewTrailingConstraint], changingTo: 16)
            
            //Setting and animating the width and height of the bottom border for eventTitleLabel
            animateLabelBorder(withDuration: 0.5, for: eventTitleLabel)
            
            //Animating shadowPath to new eventView location
            animateShadowPath(withDuration: 0.5,for: eventView, shadowOpacity: nil, shadowOpacityDuration: nil)
            
            eventViewRecognizer.isEnabled = false
            homeViewRecognizer.isEnabled = true
            eventScrollView.isUserInteractionEnabled = true
            eventViewTapped = true
        } else if sender == homeViewRecognizer {
            
            //Animating constraints and shadow offsets for event view along with deactivating conflicting constraints
            animateConstraints(withDuration: 0.5, inActive: [eventViewHeightConstraint, eventDescriptionHeightConstraint], active: [eventViewTopSpaceConstraint, eventViewBottomSpaceConstraint], stayingActive: [eventViewLeadingConstraint, eventViewTrailingConstraint], changingTo: 67.5)
            
            //Setting and animating the width and height of the bottom border for eventTitleLabel
            animateLabelBorder(withDuration: 0.5, for: eventTitleLabel)
            
            //Animating shadowPath to new eventView location
            animateShadowPath(withDuration: 0.5, for: eventView, shadowOpacity: nil, shadowOpacityDuration: nil)
            
            eventViewRecognizer.isEnabled = true
            homeViewRecognizer.isEnabled = false
            eventScrollView.isUserInteractionEnabled = false
            eventViewTapped = false
        }
    }
    
    @IBAction func panEventView(_ sender: UIPanGestureRecognizer) {
        //Setting variables for rotation animation
        let point = sender.translation(in: view)
        let xFromCenter = self.eventView.center.x - view.center.x
        
        //Animating rotation and scale
        self.eventView.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        let scale = min(100/abs(xFromCenter), 1)
        self.eventView.transform = CGAffineTransform(rotationAngle: (xFromCenter/divisor)).scaledBy(x: scale, y: scale)
        if xFromCenter > 0 {
            thumbImageView.image = UIImage(named: "ThumbUp")
            thumbImageView.tintColor = UIColor.green
        } else {
            thumbImageView.image = UIImage(named: "ThumbDown")
            thumbImageView.tintColor = UIColor.red
        }
        
        //Setting thumbImageView alpha based on position
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        
        //Ran when the user is done swiping
        if sender.state == UIGestureRecognizer.State.ended {
            
            if self.eventView.center.x < 75 {
                UIView.animate(withDuration: 0.3, animations: {
                    //Animating event view away
                    self.eventView.center = CGPoint(x: self.eventView.center.x - 200, y: self.eventView.center.y)
                    self.eventView.alpha = 0
                }, completion: {(finished) in
                    //Setting event view up for animation
                    self.postSwipeSetUp()
                    
                    //Setting event view up for new event
                    let eventorController = EventorController.shared
                    if let nextEvent = eventorController.getNextEvent() {
                        //Setting up date formatter
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMM d', at 'h:mm a"
                        
                        //Setting up date string
                        let date = dateFormatter.string(from: nextEvent.startTime)
                        
                        //Setting up labels
                        self.eventTitleLabel.text = nextEvent.title
                        self.eventDescriptionLabel.text = "Date: \(date) \nLocation: \(nextEvent.location) \n\n\(nextEvent.eventDescription)"
                    } else {
                        //Grabbing events and showing loading animations
                        self.startLoadingEvents()
                    }
                    
                    //Animating view back into place
                    UIView.animate(withDuration: 0.5, animations: {
                        self.eventView.alpha = 1
                        self.eventView.transform = .identity
                    })
                    self.view.layoutIfNeeded()
                    
                    self.animateLabelBorder(withDuration: 0.5, for: self.eventTitleLabel)
                    
                    self.animateShadowPath(withDuration: 0.25, for: self.eventView, shadowOpacity: 0.5, shadowOpacityDuration: 0.75)
                    
                })
                return
            } else if self.eventView.center.x > (view.frame.width - 75) {
                UIView.animate(withDuration: 0.3, animations: {
                    //Animating event view away
                    self.eventView.center = CGPoint(x: self.eventView.center.x + 200, y: self.eventView.center.y)
                    self.eventView.alpha = 0
                }, completion: {(finished) in
                    //Setting event view up for animation 
                    self.postSwipeSetUp()
                    
                    //Adding current event to the likedTableViewController
                    let eventorController = EventorController.shared
                    eventorController.addLikedEvent(event: eventorController.getCurrentEvent()!)
                    
                    //Setting event view up for new event
                    if let nextEvent = eventorController.getNextEvent() {
                        //Setting up date formatter
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMM d', at 'h:mm a"
                        
                        //Setting up date string
                        let date = dateFormatter.string(from: nextEvent.startTime)
                        
                        //Setting up labels
                        self.eventTitleLabel.text = nextEvent.title
                        self.eventDescriptionLabel.text = "Date: \(date) \nLocation: \(nextEvent.location) \n\n\(nextEvent.eventDescription)"
                    } else {
                        //Grabbing events and showing loading animations
                        self.startLoadingEvents()
                    }
                    
                    
                    //Animating view back into place
                    UIView.animate(withDuration: 0.5, animations: {
                        self.eventView.alpha = 1
                        self.eventView.transform = .identity
                    })
                    self.view.layoutIfNeeded()
                    
                    self.animateLabelBorder(withDuration: 0.5, for: self.eventTitleLabel)
                    
                    self.animateShadowPath(withDuration: 0.25, for: self.eventView, shadowOpacity: 0.5, shadowOpacityDuration: 0.75)
                    
                })
                return
            }
            
            //Animate view back into place if they didn't fully swipe the view away
            UIView.animate(withDuration: 0.2) {
                self.eventView.center = self.view.center
                self.thumbImageView.alpha = 0
                self.eventView.transform = .identity
            }
        }
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        eventTitleLabel.adjustsFontSizeToFitWidth = true
        
        //Setting divisor for animations
        divisor = (view.frame.width / 2) / 0.61
        
        //Fetching Liked Events
        EventorController.shared.fetchLikedEvents()
        
        //Grabbing events and showing loading animations
        startLoadingEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Setting up a bottom border for the event title
        if eventTitleLabel.layer.sublayers == nil {
            eventTitleLabel.addBorder(side: .Bottom, thickness: 2, color: UIColor.black)
        }
        
        //Grabbing events and showing loading animations if filters were changed
        if FilterController.shared.filterPageUsed {
            startLoadingEvents()
            FilterController.shared.filterPageUsed = false
        }
        
    }
    
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    private func startLoadingEvents() {
        //Setting up all things related to loading
        self.eventTitleLabel.text = "Loading Events"
        self.loadingActivityIndicator.alpha = 1.0
        self.eventDescriptionLabel.alpha = 0.0
        
        //Starting activity Indicator
        self.loadingActivityIndicator.startAnimating()
        
        //Setting up variables for grabbing events
        let eventorController = EventorController.shared
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d', at 'h:mm a"
        
        //Grabbing Events from the API
        eventorController.grabEvents { (events) in
            guard let events = events else {
                //If no events were pulled set all things up to inform user
                DispatchQueue.main.async {
                    self.eventTitleLabel.text = "No more events available"
                    self.eventDescriptionLabel.text = "Change your filters if you want to see more"
                    self.eventDescriptionLabel.alpha = 1.0
                    self.loadingActivityIndicator.alpha = 0.0
                    self.loadingActivityIndicator.stopAnimating()
                }
                self.eventView.isUserInteractionEnabled = false
    
                return
            }
            //If events were pulled set up UI
            eventorController.setEvents(events: events)
            let nextEvent = eventorController.getNextEvent()!
            let date = dateFormatter.string(from: nextEvent.startTime)
            DispatchQueue.main.async {
                self.eventTitleLabel.text = nextEvent.title
                self.eventDescriptionLabel.text = "Date: \(date) \nLocation: \(nextEvent.location) \n\n\(nextEvent.eventDescription)"
                self.eventDescriptionLabel.alpha = 1.0
                self.loadingActivityIndicator.alpha = 0.0
                self.loadingActivityIndicator.stopAnimating()
                self.eventView.isUserInteractionEnabled = true
            }
        }
    }
    
    private func postSwipeSetUp() {
        //Setting up pre-animation scale, location, and alpha
        self.eventView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        self.eventView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.eventView.layer.shadowPath = UIBezierPath(roundedRect: self.eventView.frame, cornerRadius: self.eventView.layer.cornerRadius).cgPath
        self.eventView.layer.shadowOpacity = 0
        self.thumbImageView.alpha = 0
        
        //Setting up constraints and recognizers if needed
        if self.eventViewTapped {
            NSLayoutConstraint.deactivate([self.eventViewTopSpaceConstraint, self.eventViewBottomSpaceConstraint])
            NSLayoutConstraint.activate([self.eventViewHeightConstraint, self.eventDescriptionHeightConstraint])
            self.eventViewLeadingConstraint.constant = 67.5
            self.eventViewTrailingConstraint.constant = 67.5
            self.eventViewRecognizer.isEnabled = true
            self.homeViewRecognizer.isEnabled = false
            self.eventScrollView.isUserInteractionEnabled = false
        }
    }
    
    //========================================
    //MARK: - Animation Methods
    //========================================
    
    private func animateConstraints(withDuration duration: TimeInterval, inActive: [NSLayoutConstraint], active: [NSLayoutConstraint], stayingActive currentConstraints: [NSLayoutConstraint]?, changingTo newValue: CGFloat?) {
        
        NSLayoutConstraint.deactivate(active)
        
        UIView.animate(withDuration: duration) {
            NSLayoutConstraint.activate(inActive)
            if let currentConstraints = currentConstraints, let newValue = newValue {
                for i in currentConstraints {
                    i.constant = newValue
                }
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateShadowPath(withDuration duration: TimeInterval,for view: UIView, shadowOpacity: Float?, shadowOpacityDuration: TimeInterval?) {
        let newShadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        
        let shadowPathAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowPath))
        shadowPathAnimation.fromValue = view.layer.shadowPath
        shadowPathAnimation.toValue = newShadowPath
        shadowPathAnimation.duration = duration
        
        view.layer.shadowPath = newShadowPath
        view.layer.add(shadowPathAnimation, forKey: #keyPath(CALayer.shadowPath))
        
        if let newShadowOpacity = shadowOpacity, let newShadowOpacityDuration = shadowOpacityDuration {
            let shadowOpacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
            shadowOpacityAnimation.fromValue = view.layer.shadowOpacity
            shadowOpacityAnimation.toValue = newShadowOpacity
            shadowOpacityAnimation.duration = newShadowOpacityDuration
            
            view.layer.shadowOpacity = newShadowOpacity
            view.layer.add(shadowOpacityAnimation, forKey: #keyPath(CALayer.shadowOpacity))
        }
        
    }
    
    private func animateLabelBorder(withDuration duration: TimeInterval, for label: UILabel) {
        guard let sublayers = label.layer.sublayers else { return }
        
        let width = label.layer.frame.width
        let height = sublayers[0].frame.height
        
        UIView.animate(withDuration: duration) {
            label.layer.sublayers![0].frame.size = CGSize(width: width, height: height)
        }
    }
}


//Used to add a border line to any side of a label
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
