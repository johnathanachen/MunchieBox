//
//  HomeMapViewController.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 4/30/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.


import UIKit
import MapKit
import SwiftyUserDefaults
import GeoFire
import FirebaseDatabase
import Kingfisher
import CoreMotion
import RxSwift
import Hero


class MapViewController: UIViewController, RecommendDelegate {
    
    // MARK: - INJECTIONS
    internal let foodCategory = FoodCategory.sharedInstance
    
    // MARK: VARIABLES
    let bag = DisposeBag()
    var longitudeForAppleMaps: CLLocationDegrees?
    var latitudeForAppleMaps: CLLocationDegrees?
    var locationNameForMaps: String?
    var geofireRef: DatabaseReference?
    var geoFire: GeoFire?
    
    var truckObjects:[FoodTruck] = []
    
    var locationManager: CLLocationManager?
    var userCurrentLat: Double?
    var userCurrentLong: Double?
    var selectedLat: Double?
    var selectedLong: Double?
    var userLocation: CLLocation? {
        didSet {
            let zoomLocation = CLLocationCoordinate2DMake((locationManager?.location?.coordinate.latitude)!, (locationManager?.location?.coordinate.longitude)!)
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(zoomLocation, span)
            let adjustedRegion: MKCoordinateRegion? = mapView?.regionThatFits(region)
            mapView.setRegion(adjustedRegion!, animated: false)
            
            if truckObjects.count == 0 {
                requestMapData(radius: 35, location: (locationManager?.location)!)
            }
            
        }
    }
    
    // MARK: OUTLETS
    @IBOutlet var exploreView: UIView!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var menuContainer: UIView!
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewBlack: UIView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet var constraintMenuLeft: NSLayoutConstraint!
    @IBOutlet var constraintMenuWidth: NSLayoutConstraint!
    @IBOutlet var gestureScreenEdgePan: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var recommendHeader: HeaderView!
    @IBOutlet weak var exploreButton: UIButton!
    
    
    // MARK: ACTIONS
    @IBAction func pressReSearchAreaButton(_ sender: UIButton) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
   
        let center = findCenterPoint()
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        requestMapData(radius: 35, location: location)
//        fetchFromFirebase(lat: center.latitude, long: center.longitude)
        
        let api = MunchieAPI.sharedInstance
        
        api.hasResult.subscribe({ (result) in
            if result.element == false {
                
                let alert = UIAlertController(title: "hmmm no results", message: "try searching a different area", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        })
    
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        presentFlavorViewController()
   
    }
    
    @IBAction func gestureTapOnViewBlack(_ sender: Any) {
        
        mapView.removeOverlays(mapView.overlays)
        truckObjects.removeAll()
        
        // FETCH FROM USER LOCATION
//        fetchFromFirebase(lat: (locationManager?.location?.coordinate.latitude)!, long: (locationManager?.location?.coordinate.longitude)!)
    }
    
    @IBAction func pressDirectionsButton(sender: UIButton) {
    
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(userLocation?.coordinate.latitude),\(userLocation?.coordinate.longitude)&zoom=14&views=traffic&q=\(selectedLat!),\(selectedLong!)")!, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Unable to Locate", message: "Google maps not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        
    }
    

    // MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        menuContainer.isHidden = true
        
        let api = MunchieAPI.sharedInstance
        let mapListResult = api.mapList
        
        setupExploreButton()
        
        mapListResult.subscribe(onNext: { (result) in
            
                self.truckObjects = result
            
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(self.truckObjects)
            
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
             
            }, onDisposed: {
                
            }).disposed(by: self.bag)
        
        headerView.delegate = self
        recommendHeader.layer.cornerRadius = 5
        recommendHeader.layer.masksToBounds = true
        
        self.mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()

        // Side menu starting contraints
        constraintMenuLeft.constant = -constraintMenuWidth.constant
        
        viewBlack.alpha = 0
        viewBlack.isHidden = true


        // FETCH NEARBY TRUCKS IF MAPS WAS SELECTED BEFORE CATEGORIES
        
   
    }
    
    
    // MARK: METHODS
    func requestMapData(radius: Double, location: CLLocation) {
        let api = MunchieAPI.sharedInstance
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        foodCategory.resetBuckets()
        
        api.fetchTrucksWithinUserRadius(location: location, radius: radius) {
            list in
            
            api.fetchLikesFor(truck: list) {
                result in
                
                OperationTimeConversion().checkIfTruckIsOpen(foodTrucks: result) {
                    result in
                    
                    self.mapView.addAnnotations(result)
                    
                }
            }
        }
    }
    
    
    func setupExploreButton() {
        exploreView.layer.cornerRadius = 5
        exploreView.clipsToBounds = true
        exploreView.layer.shadowColor = UIColor.gray.cgColor
        exploreView.layer.shadowRadius = 3.0
        exploreView.layer.shadowOpacity = 0.7
        exploreView.layer.shadowOffset = CGSize(width: 2, height: 2)
        exploreView.layer.masksToBounds = false

    }

    
    func findCenterPoint() -> CLLocationCoordinate2D {
        var screenCenterPoint: CGPoint = mapView.center
        var mapCenterPoint: CLLocationCoordinate2D = mapView.convert(screenCenterPoint, toCoordinateFrom: view)
        return mapCenterPoint
 
    }
    

    func hideHeader() {
        UIView.animate(withDuration: 0.01) {
            self.headerView.isHidden = true
        }
        exploreView.isHidden = false
        menuContainer.isHidden = true
     
    }

    
    func showHeader() {
        UIView.animate(withDuration: 0.3) {
            self.headerView.isHidden = false
            if self.headerView.frame.origin.y < 250 {
                self.headerView.frame.origin.y += 310
            }
            self.exploreView.isHidden = true
        }
        
    }
    
    func showRecommendButton() {
        recommendHeader.isHidden = false
    }
    
    func presentFlavorViewController() {
        let flavorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlavorViewController") as! FlavorViewController
        flavorViewController.hero.isEnabled = true
        flavorViewController.hero.modalAnimationType = .push(direction: .right)
        let navController = UINavigationController(rootViewController: flavorViewController)
        if #available(iOS 11.0, *) {
            navController.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navController.navigationBar.barTintColor = .white

        Hero.shared.cancel(animate: false)
        self.hero.replaceViewController(with: navController)
        
      
    }
    
    func openAppleMapForDirection() {
        
        let latitude: CLLocationDegrees =  Double(latitudeForAppleMaps!)
        let longitude: CLLocationDegrees = Double(longitudeForAppleMaps!)
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationNameForMaps!
        mapItem.openInMaps(launchOptions: options)
    }
}

