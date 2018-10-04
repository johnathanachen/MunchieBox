//
//  CustomCalloutView.swift
//  CustomCalloutView
//
//  Created by Malek T. on 3/10/16.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import FirebaseAuth

class CustomCalloutView: UIView {

    var truckID: String? = nil
    var customerID: String? = Auth.auth().currentUser?.uid
    var likesCount: Int? = nil
    @IBOutlet var calloutBgView: UIView!
    @IBOutlet weak var heatsCountLabel: UILabel!
    @IBOutlet weak var annotationHeatButton: UIButton!
    @IBAction func pressAnnotationHeatsArea(_ sender: UIButton) {
        incrementHeat()
        
    }
    
    
    func incrementHeat() {
        let api = MunchieAPI.sharedInstance
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let incrementedLikeCount = self.likesCount! + 1

        api.incrementTruckHeatCount(customerID: customerID!, truckID: self.truckID!, likes: incrementedLikeCount) {
            result in
            if result == false {
                self.heatsCountLabel.text = String(incrementedLikeCount)
                 feedbackGenerator.notificationOccurred(.success)
            } else {
                feedbackGenerator.notificationOccurred(.error)
            }
        }
        
        
        
        
       

        reloadInputViews()
        
    }
    
    
}
