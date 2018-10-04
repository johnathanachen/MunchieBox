//
//  HeaderView.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 5/17/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import UIKit
import CoreMotion
import MapKit
import SwiftyUserDefaults

protocol RecommendDelegate: class {
    func showRecommendButton()
}

class HeaderView: UIView, NibView {
    
    weak var delegate: RecommendDelegate?

    var headerIsOpen: Bool = false
    
    @IBOutlet var mainHeaderView: UIView!
    @IBOutlet private weak var backgroundContainerView: UIView!
    @IBOutlet weak var headerContainterView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var arrowDownButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var streetLabel: UILabel!
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("ok")
    }
    
    func showButton() {
        delegate?.showRecommendButton()
    }
 
    @IBAction func headerPressArea(_ sender: UIButton) {
        
        showButton()
        
        if headerIsOpen {
            closeHeader()
        } else {
            openHeader()
        }
        
    }
    
    
    
    func openHeader() {
        if headerContainterView.frame.size.height < 160 {
            
            
            // Expand header
            UIView.animate(withDuration: 0.20) {
                self.headerContainterView.frame.size.height += 80
            }
            
            // Move menu and like button down
            UIView.animate(withDuration: 0.75, delay: 0.05, usingSpringWithDamping: 0.35, initialSpringVelocity: 0, options: [], animations: {
                self.likeButton.frame.origin.y += 13
                self.menuButton.frame.origin.y += 13
            }, completion: nil)
            
            // Unhide menu and like button
            UIView.animate(withDuration: 0.25, delay: 5.0, options: [.transitionCrossDissolve], animations: {
                self.likeButton.isHidden = false
                self.menuButton.isHidden = false
            }, completion: nil)
            
            // Turn arrow pointing down
            UIView.animate(withDuration: 0.25, animations: {
                self.arrowDownButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 0.999))
            })
            menuButton.isEnabled = true
            headerIsOpen = true
        }
    }
    
    func closeHeader() {
        
        if headerContainterView.frame.size.height >= 160 {
            
            // Shrink header
            UIView.animate(withDuration: 0.25) {
                self.headerContainterView.frame.size.height -= 80
            }
            
            // Move menu and like button up
            UIView.animate(withDuration: 0.75, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                self.likeButton.frame.origin.y -= 13
                self.menuButton.frame.origin.y -= 13
            }, completion: nil)
            
            
            // Hide menu and like button
            UIView.animate(withDuration: 0.25, delay: 5.0, options: [.transitionCrossDissolve], animations: {
                self.likeButton.isHidden = true
                self.menuButton.isHidden = true
            }, completion: nil)
        }
        
        // Turn arrow pointing up
        UIView.animate(withDuration: 0.25, animations: {
            self.arrowDownButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        })
    
        headerIsOpen = false
    }

    
    /// Core Motion Manager
    private let motionManager = CMMotionManager()
    
    /// Shadow View
    private weak var shadowView: UIView?
    
    /// Inner Margin
    private static let kInnerMargin: CGFloat = 20.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        headerContainterView.layer.cornerRadius = 14.0

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        headerContainterView.layer.cornerRadius = 14.0
        


    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadow()
    }
    
    // MARK: - Shadow
    
    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: HeaderView.kInnerMargin,
                                              y: HeaderView.kInnerMargin,
                                              width: bounds.width - (2 * HeaderView.kInnerMargin),
                                              height: bounds.height - (2 * HeaderView.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        
        // Roll/Pitch Dynamic Shadow
        //        if motionManager.isDeviceMotionAvailable {
        //            motionManager.deviceMotionUpdateInterval = 0.02
        //            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
        //                if let motion = motion {
        //                    let pitch = motion.attitude.pitch * 10 // x-axis
        //                    let roll = motion.attitude.roll * 10 // y-axis
        //                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
        //                }
        //            })
        //        }
        self.applyShadow(width: CGFloat(0.0), height: CGFloat(0.0))
    }
    
    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 14.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.15
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }
    
}
