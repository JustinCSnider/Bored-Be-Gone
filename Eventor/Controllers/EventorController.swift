//
//  EventorController.swift
//  Eventor
//
//  Created by Justin Snider on 2/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import CoreLocation

class EventorController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = EventorController()
    private var events = [Event]()
    private var currentEvent = Event()
    private var currentEventIndex = 0
    private var currentURLString = "https://api.predicthq.com/v1/events/"
    
    //========================================
    //MARK: - Network Methods
    //========================================
    
    func grabEvents(completion: (([Event]?) -> Void)? = nil) {
        guard let url = URL(string: currentURLString) else {
            print("Bad URL")
            return
        }
        
        NetworkController.performNetworkRequest(for: url, accessToken: "L3KQkKTpvMPFkoBaMhF1CcD5KCRiQ2") { (data, error) in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            var results = [Event]()
            
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            
            if let events = try? decoder.decode(Events.self, from: data) {
                
                if let nextURLString = events.next {
                    self.currentURLString = nextURLString
                } else {
                    self.currentURLString = "https://api.predicthq.com/v1/events/"
                }

                var descriptEvents = events.results
                
                for i in descriptEvents {
                    if i.eventDescription == "", let eventIndex = descriptEvents.firstIndex(of: i) {
                        descriptEvents.remove(at: eventIndex)
                    }
                }
                results = descriptEvents
            }
            
            if let completion = completion {
                completion(results)
            }
        }
    }
    
    //========================================
    //MARK: - Getters and Setters
    //========================================
    
    func getCurrentEvent() -> Event? {
        if (currentEventIndex + 1) > events.count {
            currentEventIndex = 0
            return nil
        }
        currentEvent = events[currentEventIndex]
        currentEventIndex += 1
        return currentEvent
    }
    
    func setEvents(events: [Event]) {
        self.events = events
    }
    
    func getEvents() -> [Event] {
        return events
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    func getAddressFromLatLon(withLatitude lat: Double, andLongitude lon: Double, completion: ((String) -> Void)? = nil) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        var addressString = ""
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    if let completion = completion {
                        completion(addressString)
                    }
                }
        })
    }
    
    //========================================
    //MARK: - Data Persistence Methods
    //========================================
    
    func saveToPersistentStorage() {
        do {
            try Stack.context.save()
        } catch {
            Stack.context.rollback()
        }
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid date: " + string)
        }
        return date
    }
}
