//
//  MenuPopupViewController.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/24/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import FirebaseAuth

class MenuPopupViewController: UIViewController {

    
    // MARK: VARIABLES
    var customerID: String? = Auth.auth().currentUser?.uid
    let bag = DisposeBag()
    var menuItemListResult = [MenuItem]()
    let api = MunchieAPI.sharedInstance
    
    
    // MARK: OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundView?.backgroundColor = UIColor.clear
        menuItemListResult.removeAll()
    
        let fetchMenuIDNotification = api.finishFetchingMenuID
        fetchMenuIDNotification.subscribe({ (result) in
           
            
            self.observeMenuItemObjectList(truckID: result.element![0] as! String, menuIDs: result.element![1] as! [String])
            
        }).disposed(by: self.bag)

    }
    
    // MARK: METHODS
    func observeMenuItemObjectList(truckID: String, menuIDs: [String]) {
        
        api.createMenuItemObjects(truckID: truckID, IDList: menuIDs)
            .subscribe(onNext: { (result) in
//                print(result)
                self.menuItemListResult = result

            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
//                print("count", self.menuItemListResult.count)
                self.collectionView.reloadData()
                self.collectionView.reloadInputViews()
            }).disposed(by: self.bag)
    }
    

}

extension MenuPopupViewController: UICollectionViewDelegate, UICollectionViewDataSource, CellSubclassDelegate {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuItemListResult.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuPopupItemCollectionViewCell
        let cusomterLikes = String(menuItemListResult[indexPath.row].customerLikes)
        let imageURL = menuItemListResult[indexPath.row].imageURL
        let url = URL(string: imageURL)
        cell.menuPicture.kf.setImage(with: url)
        cell.heatCountLabel.text = cusomterLikes
        cell.itemLabel.text = menuItemListResult[indexPath.row].name
        cell.truckID = menuItemListResult[indexPath.row].truck_id
        cell.itemID = menuItemListResult[indexPath.row].item_id

        cell.delegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView?.cellForItem(at: indexPath) as! MenuPopupItemCollectionViewCell
        
        

    }
    
    func buttonTapped(cell: MenuPopupItemCollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
      
            return
        }
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        let convertStringNumber = Int(cell.heatCountLabel.text!)
        let menuID = cell.itemID
        let finalValue = convertStringNumber! + 1
        
        api.incrementMenuItemHeatCount(customerID: customerID!, truckID: cell.truckID!, menuItemID: menuID!, itemID: cell.itemID!, likes: finalValue) {
            result in
            if result == false {
                cell.heatCountLabel.text = String(finalValue)
                feedbackGenerator.notificationOccurred(.success)
            } else {
                feedbackGenerator.notificationOccurred(.error)
            }
        }
 
        
        cell.reloadInputViews()

    }
    
}
