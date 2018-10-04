//
//  Burger.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/24/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation

class FoodCategory: NSObject {
    
    var categoryList = [[FoodTruck]]()
    var asian = [FoodTruck]()
    var burger = [FoodTruck]()
    var fries = [FoodTruck]()
    var hotdog = [FoodTruck]()
    var pizza = [FoodTruck]()
    var chicken = [FoodTruck]()
    var taco = [FoodTruck]()
    var sushi = [FoodTruck]()
    var available: Bool?

    let asyncQueue = DispatchQueue(label: "asyncQueue", attributes: .concurrent, target: nil)
    
    static let sharedInstance: FoodCategory = {
        let instance = FoodCategory()
        
        return instance
    }()
    
    func set(_ foodTruck: FoodTruck, to list: [String]) {
        
        asyncQueue.async(flags: .barrier) {
            
            if list.contains("asian") {
                self.asian.append(foodTruck)
            }
            if list.contains("burger") {
                self.burger.append(foodTruck)
            }
            if list.contains("fries") {
                self.fries.append(foodTruck)
            }
            if list.contains("hotdog") {
                self.hotdog.append(foodTruck)
            }
            if list.contains("pizza") {
                self.pizza.append(foodTruck)
            }
            if list.contains("chicken") {
                self.chicken.append(foodTruck)
            }
            if list.contains("taco") {
                self.taco.append(foodTruck)
            }
            if list.contains("hotdog") {
                self.hotdog.append(foodTruck)
            }
          
        }
    }
    
    func retrieveCategoryList() -> [[FoodTruck]]? {
        var result: [[FoodTruck]]? = nil
        asyncQueue.sync {
            result = [burger,fries,asian,chicken,pizza,hotdog,sushi,taco]
        }
        return result
    }
    
    func resetBuckets() {
        categoryList.removeAll()
        asian.removeAll()
        burger.removeAll()
        fries.removeAll()
        hotdog.removeAll()
        pizza.removeAll()
        chicken.removeAll()
        taco.removeAll()
        sushi.removeAll()
    }
    
    
    init(available: Bool = false){
        self.available = available
    }
}
