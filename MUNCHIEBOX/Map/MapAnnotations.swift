//
//  MapAnnotations.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/3/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import MapKit
import SwiftyUserDefaults
import RxSwift

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            
            return nil
        }
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = false
        }
        
        // Close or Open pin Config
        if let annotationView = annotationView {
            // Configure pins here
            let trucksAnnotation = annotation as? FoodTruck
           
            // PIN STYLE FOR ANNOTAIONS
            if trucksAnnotation?.showOnMap == true {
                if trucksAnnotation?.currentlyOpen == true {
                    annotationView.image = UIImage(named: "open-pins")
                } else if trucksAnnotation?.currentlyOpen == false {
                    annotationView.image = UIImage(named: "closed-pins")
                }
            }
        }
        
        return annotationView
    }
    
    // MARK: SETUP HEADER VIEW
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        menuContainer.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
            self.recommendHeader.isHidden = false
        })
        
        let trucksAnnotation = view.annotation as? FoodTruck
        let truckName = trucksAnnotation?.name
        let address = trucksAnnotation?.address
        let openTime = trucksAnnotation?.time
        let imageURL = trucksAnnotation?.imageURL ?? "logo"
        guard let truckID = trucksAnnotation?.ID else { return }
        let likes = trucksAnnotation?.likes
        
        observeMenuItemIDs(truckID: truckID)
        
        selectedLat = trucksAnnotation?.coordinate.latitude
        selectedLong = trucksAnnotation?.coordinate.longitude
        
        directionsButton.isHidden = false
        
        // Set OPEN/CLOSE time color
        if trucksAnnotation?.currentlyOpen == true {
            // Green
            headerView.timeLabel.textColor = UIColor.openGreen

        } else {
            // Red
            headerView.timeLabel.textColor = UIColor.redNotOpen
        
        }
        
        
        if let url = URL(string: imageURL) {
            headerView.imageView.kf.setImage(with: url)
            headerView.imageView.layer.cornerRadius = headerView.imageView.frame.height/2
            headerView.imageView.layer.masksToBounds = true
        }
        
        headerView.titleLabel.text = truckName ?? "loading..."
        headerView.titleLabel.adjustsFontSizeToFitWidth = true
        headerView.streetLabel.text = address ?? "loading..."
        headerView.streetLabel.adjustsFontSizeToFitWidth = true
        headerView.timeLabel.text = openTime ?? "loading..."
        
        
        
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            
            return
        } else {
   
            // SELECTED PINS IMAGE
            if trucksAnnotation?.currentlyOpen == true {
                view.image = UIImage(named: "selected-open-pins")
            } else if trucksAnnotation?.currentlyOpen == false {
                view.image = UIImage(named: "selected-closed-pins")
            }
            
   
       
        }
        
        // 2
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        //        calloutView.starbucksName.text = "example"
        
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.70)
        calloutView.layer.cornerRadius = 8
        calloutView.layer.masksToBounds = true
        calloutView.heatsCountLabel.text = String(likes!)
        calloutView.truckID = truckID
        calloutView.likesCount = likes
        trucksAnnotation?.likes = likes! + 1
        view.addSubview(calloutView)
       
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        
        let sourceLocation = CLLocation(latitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!)
        let destinationLocation = CLLocation(latitude: (trucksAnnotation?.coordinate.latitude)!, longitude: (trucksAnnotation?.coordinate.longitude)!)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        direction.calculate { [weak self] (response, error) in
            if error == nil {
                
                // reset route overlay
                if mapView.overlays.count > 0 {
                    self?.mapView.removeOverlays((self?.mapView.overlays)!)
                }
                
                let route = response?.routes.first
                self?.mapView.add((route?.polyline)!)
                
            }
        }
        
        
        showHeader()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        hideHeader()
        
        recommendHeader.isHidden = true
        directionsButton.isHidden = true
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            
            return
        } else {
            
            
            let trucksAnnotation = view.annotation as? FoodTruck
            
            
            if trucksAnnotation?.currentlyOpen == true {
                // Green
                view.image = UIImage(named: "open-pins")
            } else {
                // Red
                view.image = UIImage(named: "closed-pins")
            }
            
            
        }
        
        // REMOVE CALLOUT
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
        
        
    }
    
    // MARK: METHODS
    
    func observeMenuItemIDs(truckID: String) {
        // FETCH MENU ITEMS
        let api = MunchieAPI.sharedInstance
        
        var menuItemIDListResult = api.menuItemIDListResult
        menuItemIDListResult.removeAll()
        
        let menuItems = api.fetchMenuItemID(truckID: truckID)
        menuItems.subscribe(onNext: { (result) in
            for id in result {
                menuItemIDListResult.append(id)
            }
            
            
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            
            // hide menu if no menu items, for temp yard solution
            if menuItemIDListResult.count == 0 {
                self.menuContainer.isHidden = true
            } else {
                self.menuContainer.isHidden = false
            }
            
            let truckIDAndMenuIDs: [Any] = [truckID, menuItemIDListResult]
            
            api.finishFetchingMenuID.onNext(truckIDAndMenuIDs)
            
        }).disposed(by: bag)

        
    }
    
}
