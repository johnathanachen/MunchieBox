//
//  FlavorCollectionViewCell.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/18/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit

class FlavorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet var cellBackgroundColor: UIView!
    
    override func layoutSubviews() {
        cellBackgroundColor.setUpRadius(roundness: 8)
    }
}

