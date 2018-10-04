//
//  PhoneVerificationViewController.swift
//  MBTrucks
//
//  Created by Johnathan Chen on 6/21/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyUserDefaults
import Hero

class PhoneVerificationViewController: UIViewController {
    
    let phoneNumber = Defaults[.userPhoneNumber]
    var userType: String?
    
    // MARK: OUTLETS
    @IBOutlet weak var loadingGIF: UIImageView!
    @IBOutlet weak var blackBackground: UIView!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var secureView: UIView!
    
    @IBAction func reSendCode(_ sender: UIButton) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("error")
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
        }
    }
    
    // MARK: ACTIONS
    @IBAction func loginButton(_ sender: UIButton) {
        
        loadingGIF.isHidden = false
        blackBackground.isHidden = false
        
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: code.text!)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
            } else {
                //                print("Phone number: \(String(describing: user?.user.phoneNumber))")
                let userInfo = user?.user.providerData[0]
                //                print("Provider ID: \(String(describing: userInfo?.providerID))")
                
                // CHECK IF UID EXIST IN "HOU_Truck_ID"
                let ref = Database.database().reference()
                ref.child(Query.customerIDs.param).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChild(Auth.auth().currentUser!.uid) {
                        
//                        self.presentFlavorViewController()
                        self.presentMapViewController()
                        
                        Defaults[.sessionToken] = true
                        
                    } else {
                        
                        ref.child(Query.customerIDs.param).child(Auth.auth().currentUser!.uid).setValue(["city": "houston"])
                        
                        ref.ref.child(Query.customerLikes.param).child("\(Auth.auth().currentUser!.uid)/menu_items").setValue(["init": "init"], withCompletionBlock: { (error, snapshot) in
                            ref.ref.child(Query.customerLikes.param).child("\(Auth.auth().currentUser!.uid)/trucks").updateChildValues(["init": "init"])
                        })
                        
//                        self.presentFlavorViewController()
                        self.presentMapViewController()
                        
                        Defaults[.sessionToken] = true
                        
                    }
                })
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingGIF.loadGif(asset: "yellow_fox")
        secureView.layer.cornerRadius = 5.0
        code.layer.cornerRadius = 5.0
    }
    
    func presentFlavorViewController() {
        let flavorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlavorViewController") as! FlavorViewController
        flavorViewController.hero.isEnabled = true
        flavorViewController.hero.modalAnimationType = .push(direction: .left)
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
    
    // TEMP
    func presentMapViewController() {
        let mapViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as UIViewController
        self.present(mapViewController, animated: true, completion: nil)
    }
    
    
    
    
}

