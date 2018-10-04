//
//  FoodTruck.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 5/15/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import MapKit

class FoodTruck: NSObject {
    let location: CLLocation
    let name: String
    let address: String
    let time: String
    let day: String
    let imageURL: String
    let foodType: String
    let truckID: String
    var likes: Int?
    var date: String?
    var showOnMap: Bool?
    var currentlyOpen: Bool?
    
    init(truckID: String, foodType: String, longitude: Double, latitude: Double, name: String, address: String, time: String, day: String, imageURL: String, showOnMap: Bool? = false, likes: Int = 0, date: String? = nil, currentlyOpen: Bool? = false) {
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.name = name
        self.address = address
        self.time = time
        self.day = day
        self.imageURL = imageURL
        self.foodType = foodType
        self.showOnMap = showOnMap
        self.truckID = truckID
        self.likes = likes
        self.date = date
        self.currentlyOpen = currentlyOpen
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any],
            let addressResult = dict["address"] as? String,
            let nameResult = dict["name"] as? String,
            let timeResult = dict["time"] as? String,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double,
            let day = dict["day"] as? String,
            let imageURL = dict["image_url"] as? String,
            let foodType = dict["food_type"] as? String,
            let truckID = dict["truck_id"] as? String,
            let dateResult = dict["date"] as? String
        else { return nil }
        
        self.name = nameResult
        self.time = timeResult
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.day = day
        self.imageURL = imageURL
        self.foodType = foodType
        self.address = addressResult
        self.truckID = truckID
        self.showOnMap = false
        self.currentlyOpen = false
        self.date = dateResult
        
    }
    
}

extension FoodTruck: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    var title: String? {
        get {
            return name
        }
    }
    var street: String? {
        get {
            return address
        }
    }
    var openTime: String? {
        get {
            return time
        }
    }
    var logo: String? {
        get {
            return imageURL
        }
    }
    var isCurrentlyOpen: Bool? {
        get {
            return currentlyOpen
        }
    }
    var createAnnotation: Bool? {
        get {
            return showOnMap
        }
    }
    var type: String? {
        get {
            return foodType
        }
    }
    var ID: String? {
        get {
            return truckID
        }
    }
}
