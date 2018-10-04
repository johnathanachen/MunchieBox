//
//  FlavorViewController.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/18/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import Kingfisher
import Hero
import FirebaseAuth

enum FoodType: String {
    case burger, fries, asian, chicken, pizza, hotdog, sushi, taco
    
    var selection: String {
        switch self {
        case .asian: return "asian"
        case .burger: return "burger"
        case .fries: return "fries"
        case .hotdog: return "hotdog"
        case .chicken: return "chicken"
        case .taco: return "taco"
        case .pizza: return "pizza"
        case .sushi: return "sushi"
        }
    }
    
    var bucket: [FoodTruck] {
        switch self {
        case .asian: return FoodCategory.sharedInstance.asian
        case .burger: return FoodCategory.sharedInstance.burger
        case .fries: return FoodCategory.sharedInstance.fries
        case .hotdog: return FoodCategory.sharedInstance.hotdog
        case .chicken: return FoodCategory.sharedInstance.chicken
        case .taco: return FoodCategory.sharedInstance.taco
        case .pizza: return FoodCategory.sharedInstance.pizza
        case .sushi: return FoodCategory.sharedInstance.sushi
        }
    }
    
}

enum Row {
    case burger, fries, asian, chicken, pizza, hotdog, sushi, taco
    
    var image: UIImage {
        switch self {
        case .burger: return UIImage(named: "hamburger")!
        case .fries: return UIImage(named: "fries")!
        case .asian: return UIImage(named: "asian")!
        case .chicken: return UIImage(named: "chicken")!
        case .pizza: return UIImage(named: "pizza")!
        case .hotdog: return UIImage(named: "hotdog")!
        case .sushi: return UIImage(named: "sushi")!
        case .taco: return UIImage(named: "taco")!
        }
    }
}


class FlavorViewController: UIViewController {
    
    private enum State {
        case closeDistance
        case midDistance
        case furthestDistance
    }
    
    private var distanceState: State = .midDistance {
        didSet {
            switch distanceState {
            case .closeDistance:
                activateDistanceButton(button: closestDistance)
                deactivateDistanceButton(button: midDistance)
                deactivateDistanceButton(button: furthestDistance)
            case .midDistance:
                activateDistanceButton(button: midDistance)
                deactivateDistanceButton(button: closestDistance)
                deactivateDistanceButton(button: furthestDistance)
            case .furthestDistance:    
                activateDistanceButton(button: furthestDistance)
                deactivateDistanceButton(button: closestDistance)
                deactivateDistanceButton(button: midDistance)
            }
        }
    }
    
    // MARK: - INJECTIONS
    internal let foodCategory = FoodCategory.sharedInstance
    
    // MARK: - VARIABLES
    var locationManager: CLLocationManager?
    let rows: [Row] = [.burger, .fries, .asian, .chicken, .pizza, .hotdog, .sushi, .taco]
    let bag = DisposeBag()
    var foodTypeList = Set<String>()
    var imageURLList = Set<String>()
    var filteredFlavors = [[FoodTruck]]()
    
    private var userCenterLocation: CLLocation?
    
    // MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var loadingGIF: UIImageView!
    @IBOutlet var closestDistance: UIButton!
    @IBOutlet var midDistance: UIButton!
    @IBOutlet var furthestDistance: UIButton!
    
    // MARK: - ACTIONS
    @IBAction func mapButton(_ sender: UIBarButtonItem) {
        let mapViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as UIViewController
        self.present(mapViewController, animated: true, completion: nil)
    }
    @IBAction func pressCloseDistance(sender: UIButton) {
        distanceState = .closeDistance
        requestFlavorData(radius: 8.04)
    }
    @IBAction func pressMidDistance(sender: UIButton) {
        distanceState = .midDistance
        requestFlavorData(radius: 32.18)
    }
    @IBAction func pressFurthestDistance(sender: UIButton) {
        distanceState = .furthestDistance
        requestFlavorData(radius: 56.32)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(Auth.auth().currentUser!.uid)
        setupLoadingSpinner()
        setupLocationManager()
        setupButtons()
        setupCollectionViewLayout()
        
        requestFlavorData(radius: 56.327)
    }
    
    
    // MARK: - METHODS
    func requestFlavorData(radius: Double) {
        let api = MunchieAPI.sharedInstance
    
        foodCategory.resetBuckets()
        
        api.fetchTrucksWithinUserRadius(location: userCenterLocation!, radius: radius) {
            list in
   
            api.fetchLikesFor(truck: list) {
                result in
                
                OperationTimeConversion().checkIfTruckIsOpen(foodTrucks: result) {
                    result in
                    
                    self.distributeTrucksForUserSelection(foodTrucks: result) {
                        
                        self.findPopulatedCategories() {
                            self.collectionView.reloadData()
                            self.collectionView.reloadInputViews()
                            self.collectionView.isHidden = false
                            self.loadingGIF.isHidden = true
                        }
                    }
                }
                
                
            }
        }
    }
    
    func setupLoadingSpinner() {
        loadingGIF.loadGif(asset: "yellow_fox")
        loadingGIF.isHidden = false
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()
        userCenterLocation = CLLocation(latitude: (locationManager?.location?.coordinate.latitude)!, longitude: (locationManager?.location?.coordinate.longitude)!)
        
    }
    
    func activateDistanceButton(button: UIButton) {
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.themeRed.cgColor
        button.backgroundColor = UIColor.themeRed
        button.setTitleColor(UIColor.white, for: .normal)
        button.setUpRadius(roundness: 5)
    }
    func deactivateDistanceButton(button: UIButton) {
        button.layer.borderWidth = 3
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.inactiveGray, for: .normal)
        button.layer.borderColor = UIColor.inactiveGray.cgColor
        button.setUpRadius(roundness: 5)
    }
    
    func setupButtons() {
        closestDistance.layer.borderWidth = 3
        closestDistance.layer.borderColor = UIColor.inactiveGray.cgColor
        closestDistance.setUpRadius(roundness: 5)
        
        midDistance.layer.borderWidth = 3
        midDistance.layer.borderColor = UIColor.themeRed.cgColor
        midDistance.backgroundColor = UIColor.themeRed
        midDistance.setTitleColor(UIColor.white, for: .normal)
        midDistance.setUpRadius(roundness: 5)
        
        furthestDistance.layer.borderWidth = 3
        furthestDistance.layer.borderColor = UIColor.inactiveGray.cgColor
        furthestDistance.tintColor = UIColor.inactiveGray
        furthestDistance.setUpRadius(roundness: 5)
    }
    
    func setupCollectionViewLayout() {
        let width = (view.frame.size.width - 60) / 2
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    func checkIfTruckIsOpen(foodTrucks: [FoodTruck], completion: @escaping ([FoodTruck]) -> Void) {
        let conversion = OperationTimeConversion()
        let dg = DispatchGroup()
        var checkedTrucks = [FoodTruck]()
        
        for truck in foodTrucks {
            dg.enter()
            let time = truck.time
            let weekday = truck.day
            let date = truck.date
            
            let doesDateMatch = conversion.doesDynamicScheduleMatch(truck: date!)
            let doesWeekdayMatch = conversion.doesStaticWeekdayMatch(truck: weekday)
            let isWithinOperationTime = conversion.isCurrentTimeWithinTruckHours(truck: time)
            
            if doesDateMatch == true {
                truck.showOnMap = true
            }
            
            if doesWeekdayMatch == true {
                truck.showOnMap = true
            }
            
            if isWithinOperationTime == true {
                truck.currentlyOpen = true
            }
            
            checkedTrucks.append(truck)
            dg.leave()
        }
        
        dg.notify(queue: .main, execute: {
            completion(checkedTrucks)
        })
        
    }
    
    func distributeTrucksForUserSelection(foodTrucks: [FoodTruck], completion: @escaping () -> Void) {
        
        let dg = DispatchGroup()

        for truck in foodTrucks {
            dg.enter()
            if truck.showOnMap == true {
                let list = truck.foodType.components(separatedBy: ",")
                foodCategory.set(truck, to: list)
            }
            dg.leave()
        }
        
        dg.notify(queue: .main, execute: {
            completion()
        })

    }

    func findPopulatedCategories(completion: @escaping () -> Void) {

        filteredFlavors = foodCategory.retrieveCategoryList()!
        completion()

    }
    
    
    
    
    
    

}




