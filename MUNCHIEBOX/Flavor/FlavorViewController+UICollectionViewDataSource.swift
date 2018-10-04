//
//  FlavorViewController+UICollectionViewDataSource.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/19/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//


import UIKit
import CoreLocation

extension FlavorViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FlavorCollectionViewCell
        
        cell.foodImage.image = rows[indexPath.row].image

        if self.filteredFlavors.count == 8 {
            let flavors = self.filteredFlavors[indexPath.row]
            if flavors.isEmpty {
                cell.cellBackgroundColor.backgroundColor = UIColor.inactiveGray
                cell.foodImage.alpha = 0.5
                cell.isUserInteractionEnabled = false
            } else {
                cell.cellBackgroundColor.backgroundColor = UIColor.themeRed
                cell.foodImage.alpha = 1
                cell.isUserInteractionEnabled = true
            }
        }


        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? FlavorCollectionViewCell
        
        let selection = filteredFlavors[indexPath.row]
        let api = MunchieAPI.sharedInstance
     
        api.mapList.onNext(selection)
        
        let mapViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as UIViewController
        
        self.present(mapViewController, animated: true, completion: nil)
        
    }
    
}

extension FlavorViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
        
    }
}

