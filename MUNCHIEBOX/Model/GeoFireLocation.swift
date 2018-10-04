//
//  GeoFireLocation.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/19/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import MapKit

class GeoFireLocation: NSObject {
    let location: CLLocation
    let truckID: String
    
    init(truckID: String, longitude: Double, latitude: Double) {
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.truckID = truckID
    }
    
    init?(snapshot: DataSnapshot) {
        guard let truckID = snapshot.childSnapshot(forPath: "truck_id").value! as? String else { return nil }
        guard let latitude = snapshot.childSnapshot(forPath: "latitude").value! as? Double else { return nil }
        guard let longitude = snapshot.childSnapshot(forPath: "longitude").value! as? Double else { return nil }
       
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.truckID = truckID

    }
}

