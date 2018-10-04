//
//  RequestPhonePinViewController.swift
//  MBTrucks
//
//  Created by Johnathan Chen on 6/21/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyUserDefaults
import CoreLocation
import Hero

class RequestPhonePinViewController: UIViewController {
    
    @IBOutlet weak var loadingGIF: UIImageView!
    @IBOutlet weak var blackBackgroundView: UIView!
    
    private var numberString = "+1"
    
    @IBOutlet weak var flagBgView: UIView!
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var cityQuestionsLabel: UILabel!
    @IBOutlet weak var notInCityView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var greyBgColor: UIView!
    
    // MARK: @IBActions
    @IBAction func numberButton(_ sender: UIButton) {
        if sender.tag != -1 {
            let numberPressed = sender.tag
            numberString.append(String(numberPressed))
            phoneNumberField.text = numberString
            phoneNumberField.reloadInputViews()
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        if numberString.count > 0 {
            numberString.removeLast()
        }
        phoneNumberField.text = numberString
        phoneNumberField.reloadInputViews()
    }
    
    
    @IBAction func sendCode(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Phone number", message: "Is this your phone number \n \(phoneNumberField.text!)", preferredStyle: .alert)
        
        Defaults[.userPhoneNumber] = phoneNumberField.text!
        
        if phoneNumberField.text! == "+11112223333" {
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumberField.text!, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    
                    print("error: \(String(describing: error?.localizedDescription))")
                    
                } else {
                    
                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authVID")
                    self.performSegue(withIdentifier: "sendCode", sender: Any?.self)
                }
            }
        } else {
            
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumberField.text!, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    
                    print("error: \(String(describing: error?.localizedDescription))")
                    
                } else {
                    
                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authVID")
                    self.performSegue(withIdentifier: "sendCode", sender: Any?.self)
                    
                    self.numberString = "+1"
                    self.phoneNumberField.text = self.numberString
                    self.phoneNumberField.reloadInputViews()
                    self.blackBackgroundView.isHidden = true
                    self.loadingGIF.isHidden = true
                    
                }
                
            }
            
            //            print(phoneNumberField.text)
            
            
        }
        
        
        
        loadingGIF.isHidden = false
        blackBackgroundView.isHidden = false
        
        
        
        
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        
        if Defaults[.sessionToken] == true {
//            self.presentFlavorViewController()
            self.presentMapViewController()
        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingGIF.loadGif(asset: "yellow_fox")
        
        phoneNumberField.text = numberString
        phoneNumberField.reloadInputViews()
        
        phoneNumberField.inputView = UIView()
        flagBgView.layer.cornerRadius = 5.0
        phoneNumberField.layer.cornerRadius = 5.0
        
        
        
    }
    
    // MARK: METHODS
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

