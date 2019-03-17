//
//  EventorController.swift
//  Eventor
//
//  Created by Justin Snider on 2/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import CoreLocation
import Network
import CoreData

class EventorController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = EventorController()
    private var events: [Event] = []
    private var likedEvents: [Event] = []
    private var currentEvent: Event?
    private var currentEventIndex = 0
    private var currentURLString: String? = "https://api.predicthq.com/v1/events/"
    private var searchQuery = [String : String]()
    
    //========================================
    //MARK: - Network Methods
    //========================================
    
    func grabEvents(completion: (([Event]?) -> Void)? = nil) {
        
        if currentURLString != nil {
            for i in searchQuery.keys {
                if let searchQueryValue = searchQuery[i] {
                    if currentURLString!.last == "/" {
                        currentURLString!.append("?")
                    } else {
                        currentURLString?.append("&")
                    }
                    currentURLString!.append("\(i)=\(searchQueryValue)")
                }
            }
        } else if let completion = completion {
            completion(nil)
            
            currentURLString = "https://api.predicthq.com/v1/events/"
            
            return
        }
        
        guard let url = URL(string: currentURLString!) else {
            print("Bad URL")
            return
        }
        
        NetworkController.performNetworkRequest(for: url, accessToken: "L3KQkKTpvMPFkoBaMhF1CcD5KCRiQ2") { (data, error) in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            let group = DispatchGroup()
            var results = [Event]()
            
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            
            if let events = try? decoder.decode(Events.self, from: data) {
                
                if let nextURLString = events.next {
                    self.currentURLString = nextURLString
                } else {
                    self.currentURLString = nil
                }

                var descriptEvents = events.results
                
                for i in descriptEvents {
                    if i.eventDescription == "", let eventIndex = descriptEvents.firstIndex(of: i) {
                        descriptEvents.remove(at: eventIndex)
                        Stack.context.delete(i)
                    } else {
                        group.enter()
                        self.getAddressFromLatLon(withLatitude: i.latitude, andLongitude: i.longitude, completion: { (location) in
                            i.location = location
                            group.leave()
                        })
                        group.wait()
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
    
    //Current event methods
    
    func getCurrentEvent() -> Event? {
        return currentEvent
    }
    
    func getNextEvent() -> Event? {
        if (currentEventIndex + 1) > events.count {
            currentEventIndex = 0
            return nil
        }
        currentEvent = events[currentEventIndex]
        currentEventIndex += 1
        return currentEvent
    }
    
    func resetCurrentEventIndex() {
        currentEventIndex = 0
    }
    
    //General events methods
    
    func setEvents(events: [Event]) {
        self.events = events
    }
    
    func getEvents() -> [Event] {
        return events
    }
    
    func resetEvents() {
        for i in events {
            var eventIsPresent = false
            //Checks if any events in the events array are liked events
            for j in likedEvents {
                if i == j {
                    eventIsPresent = true
                }
            }
            //If an event in the events array is a liked event then it isn't deleted off the context
            if !eventIsPresent {
                Stack.context.delete(i)
            }
        }
        events.removeAll()
    }
    
    //Liked events methods
    
    func addLikedEvent(event: Event) {
        likedEvents.append(event)
    }
    
    func removeLikedEvent(event: Event) {
        if let eventIndex = likedEvents.firstIndex(of: event) {
            likedEvents.remove(at: eventIndex)
        }
    }
    
    func getLikedEvents() -> [Event] {
        return likedEvents
    }
    
    //Query methods
    
    func setQuery(_ query: [String : String]) {
        self.searchQuery = query
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
    
    func fetchLikedEvents() {
        let eventFetchRequest = NSFetchRequest<Event>(entityName: Event.entityName)
        
        do {
            self.likedEvents = try Stack.context.fetch(eventFetchRequest)
        } catch {
            print("Unable to fetch data from the context")
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
