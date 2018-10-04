//
//  MapViewController+MapDatasource.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/20/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if userLocation == nil {
            userLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
    
    // ROUTE OVERLAY
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 30/255, green: 138/255, blue: 252/255, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
    

}

