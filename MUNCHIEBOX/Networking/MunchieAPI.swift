//
//  FlavorAPI.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/18/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase
import GeoFire
import RxSwift
import RxCocoa

enum Query {
    case customerIDs, foodTrucks, geoLocs, menus, schedules, customerLikes
    
    var param: String {
        switch self {
        case .customerIDs: return "HOU_Customer_ID"
        case .foodTrucks: return "HOU_Food_Trucks"
        case .geoLocs: return "HOU_GeoLocs"
        case .menus: return "HOU_Menus"
        case .schedules: return "HOU_Schedules"
        case .customerLikes: return "HOU_Customer_Likes"
        }
    }
}

class MunchieAPI {
    
    // MARK: VARIABLES
    static let sharedInstance: MunchieAPI = {
        let instance = MunchieAPI()
        
        return instance
    }()
    
    let ref = Database.database().reference()
    
    let bag = DisposeBag()
    let flavorList = PublishSubject<String>()
    let foodTypeList = PublishSubject<[String]>()
    let imageURLList = PublishSubject<String>()

    let menuItemIDList = PublishSubject<String>()
    var menuItemIDListResult = [String]()
    
    let mapList = ReplaySubject<[FoodTruck]>.create(bufferSize: 2)
    
    let finishFetchingMenuID = PublishSubject<[Any]>()
    
    let truckRadiusList = PublishSubject<FoodTruck>()
    var annotationTruckID: String?
    
    let hasResult = PublishSubject<Bool>()

    
    // MARK: METHODS
    func fetchTruckIDs(completion: @escaping ([String]) -> Void) {
        self.ref.child(Query.foodTrucks.param).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            let dg = DispatchGroup()
            let enumerator = snapshot.children
            var list = [String]()

            while let rest = enumerator.nextObject() as? DataSnapshot {
                dg.enter()
                list.append(rest.key)
                dg.leave()
            }
            
            dg.notify(queue: .main, execute: {
                completion(list)
            })
      
        }
    }
    
    func fetchFlavorCategories(truckIDs: [String], completion: @escaping ([String]) -> Void) {
        
        let dg = DispatchGroup()
        var list = [String]()
        
        for id in truckIDs {
            dg.enter()
            self.ref.child(Query.foodTrucks.param).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let foodType = snapshot.childSnapshot(forPath: "food_type").value!
                list.append(foodType as! String)
                dg.leave()
            })
        }
        
        dg.notify(queue: .main, execute: {
            completion(list)
        })
        
    }
    
    
    /**
     Search for all food trucks around the area based on user location
     
     Calling this method returns a list of nearby food trucks
     
     */
    
    func fetchTrucksWithinUserRadius(location: CLLocation, radius: Double, completion: @escaping ([FoodTruck]) -> Void) {
        let geofireRef: DatabaseReference? = self.ref.child(Query.geoLocs.param)
        let geoFire: GeoFire? = GeoFire(firebaseRef: geofireRef!)
        var truckList = [FoodTruck]()
        
        if let circleQuery = geoFire?.query(at: location, withRadius: radius) {
            _ = circleQuery.observe(.keyEntered) { (key, location) in                self.ref.child(Query.geoLocs.param).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let foodTruck = FoodTruck(snapshot: snapshot) {
                        truckList.append(foodTruck)
    
                    }
                    // FOR WHEN THERE ARE RESULTS ARE RETURNED
                    circleQuery.observeReady {
                        completion(truckList)
                    }
                })
            }
            // FOR WHEN NO RESULTS ARE RETURNED
            circleQuery.observeReady {
                completion(truckList)
            }
        }
    }
    
    func fetchLikesFor(truck: [FoodTruck], completion: @escaping ([FoodTruck]) -> Void) {
        let dg = DispatchGroup()
        
        for truck in truck {
            dg.enter()
            self.ref.child(Query.foodTrucks.param).child(truck.truckID).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            let likes = snapshot.childSnapshot(forPath: "customer_likes").value!
            truck.likes = likes as! Int
            

            dg.leave()
            
            }
        }
        
        dg.notify(queue: .main, execute: {
            completion(truck)
        })
    }
    
    

    
    // 1 MENU ITEMS
    func fetchMenuItemID(truckID: String) -> Observable<Set<String>> {
        return Observable.create { (observer) -> Disposable in
            
            let ref = Database.database().reference()
            ref.child(Query.menus.param).child(truckID).observe(.value) { (snapshot: DataSnapshot) in
                
                let enumerator = snapshot.children
                var list = Set<String>()
                
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    list.insert(rest.key)
                    
                }
                    observer.onNext(list)
                    observer.onCompleted()
                
            }
            
            return Disposables.create()
        }
    }
    

    // 2 MENU ITEMS
    func createMenuItemObjects(truckID: String, IDList: [String]) -> Observable<[MenuItem]> {
        return Observable.create { (observer) -> Disposable in

            let ref = Database.database().reference()
            var menuItemObjectList = [MenuItem]()
            var count = 0
            let numberInList = IDList.count
            
            for id in IDList {

            ref.child(Query.menus.param).child(truckID).child(id).observe(.value, with: { (snapshot) in

                let name = snapshot.childSnapshot(forPath: "name").value!
                let imageURL = snapshot.childSnapshot(forPath: "image_url").value!
                let itemDescription = snapshot.childSnapshot(forPath: "description").value!
                let price = snapshot.childSnapshot(forPath: "price").value!
                let customerLikes = snapshot.childSnapshot(forPath: "customer_likes").value!
                let truckID = snapshot.childSnapshot(forPath: "truck_id").value!
                let itemID = snapshot.childSnapshot(forPath: "item_id").value!

                let menuItem = MenuItem(name: name as! String, price: price as! String, imageURL: imageURL as! String, itemDescription: itemDescription as! String, customerLikes: customerLikes as! Int, item_id: itemID as! String, truck_id: truckID as! String)

                menuItemObjectList.append(menuItem)
                
                count += 1
                if count == numberInList {
                    observer.onNext(menuItemObjectList)
                    observer.onCompleted()
                }
            })
        }

            
            return Disposables.create()
        }
    }
    
    func incrementMenuItemHeatCount(customerID: String, truckID: String, menuItemID: String, itemID: String, likes: Int, completion: @escaping (Bool) -> Void) {
        
        checkIfMenuItemIsAlreadyVoted(customerID: customerID, truckID: truckID, menuID: menuItemID) {
            result in
            if result == true {
                // already voted
                completion(true)
            } else {
                let ref = Database.database().reference()
                ref.child(Query.menus.param).child(truckID).child(itemID).updateChildValues(["customer_likes": likes])
                
                // add truckID this list of voted trucks
                ref.child(Query.customerLikes.param).child(customerID).child("menu_items").updateChildValues([menuItemID: "true"])
                
                completion(false)
            }
        }
    
        
    }
    
    func incrementTruckHeatCount(customerID: String, truckID: String, likes: Int, completion: @escaping (Bool) -> Void) {
        
        checkIfTruckIsAlreadyVoted(customerID: customerID, truckID: truckID) {
            result in
            if result == true {
                // already voted
                completion(true)
            } else {
                let ref = Database.database().reference()
                ref.child(Query.foodTrucks.param).child(truckID).updateChildValues(["customer_likes": likes])
                
                // add truckID this list of voted trucks
                ref.child(Query.customerLikes.param).child(customerID).child("trucks").updateChildValues([truckID: "true"])
                
                completion(false)
            }
        }
        
    }
    
    func fetchTruckHeatCount(truckID: String) -> Observable<Int> {
        
        return Observable.create { (observer) -> Disposable in
            
            let ref = Database.database().reference()
            ref.child(Query.foodTrucks.param).child(truckID).observe(.value) { (snapshot: DataSnapshot) in
                
                
                let likes = snapshot.childSnapshot(forPath: "customer_likes").value!
                observer.onNext(likes as! Int)
                observer.onCompleted()
                
            }
            return Disposables.create()
        }
    }
    
    func checkIfTruckIsAlreadyVoted(customerID: String, truckID: String, completion: @escaping (Bool) -> Void) {
        self.ref.child(Query.customerLikes.param).child(customerID).child("trucks").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            if snapshot.childSnapshot(forPath: truckID).exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfMenuItemIsAlreadyVoted(customerID: String, truckID: String, menuID: String, completion: @escaping (Bool) -> Void) {
        self.ref.child(Query.customerLikes.param).child(customerID).child("menu_items").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            if snapshot.childSnapshot(forPath: menuID).exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }


    
    
}





