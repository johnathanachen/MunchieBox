//
//  MenuPopupItemCollectionViewCell.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/24/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol CellSubclassDelegate: class {
    func buttonTapped(cell: MenuPopupItemCollectionViewCell)
}

class MenuPopupItemCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: CellSubclassDelegate?
    
    // MARK: VARIABLES
    var truckID: String? = nil
    var itemID: String? = nil


    // MARK: OUTLETS
    @IBOutlet var menuPicture: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var heatsBgView: UIView!
    @IBOutlet var heatCountLabel: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var heatsButtonPressableArea: UIButton!
    @IBOutlet weak var heatsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heatsWidthConstraint: NSLayoutConstraint!
    

    override func layoutSubviews() {
        
        setupCornerRadius()
        
        heatsHeightConstraint.constant = menuPicture.frame.height / 3
        heatsWidthConstraint.constant = menuPicture.frame.width / 2.5
        
    }
    
    // MARK: METHODS
    func setupCornerRadius() {
        menuPicture.contentMode = .scaleAspectFill
        menuPicture.layer.cornerRadius = 8
        menuPicture.clipsToBounds = true
        
        heatsBgView.layer.cornerRadius = 12
        heatsBgView.clipsToBounds = true
    }
    
    // MARK: ACTIONS
    @IBAction func pressHeatButton(sender: UIButton) {
        
        self.delegate?.buttonTapped(cell: self)

    }
}
