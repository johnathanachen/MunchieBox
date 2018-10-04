//
//  MenuItem.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/7/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation


class MenuItem: NSObject {
    let name: String
    let price: String
    let imageURL: String
    let itemDescription: String
    let customerLikes: Int
    let item_id: String
    let truck_id: String
    
    init(name: String, price: String, imageURL: String, itemDescription: String, customerLikes: Int, item_id: String, truck_id: String) {
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.itemDescription = itemDescription
        self.customerLikes = customerLikes
        self.item_id = item_id
        self.truck_id = truck_id
    }
}
