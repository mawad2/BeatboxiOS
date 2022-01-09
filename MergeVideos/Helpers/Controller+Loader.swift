//
//  Controller+Loader.swift
//  OneTable
//
//  Created by Arbab Ali Khan on 07/09/2017.
//  Copyright © 2017 OneTableLLC. All rights reserved.
//

import Foundation
import UIKit
var indicator = MaterialLoadingIndicator()


extension UIViewController {
    
    func addLoader(withTransition shouldAddTransision:Bool) {
        
        var isLoaderAdded = false
        
        let window :UIWindow = UIApplication.shared.keyWindow!
        for loader in window.subviews{
            if loader.tag == kLOADER_TAG {
                isLoaderAdded = true
                break
            }
        }
        
        if !(isLoaderAdded) {
            
            var viewHeight = 50
            var loaderBackgroundColor = UIColor.clear
            if (shouldAddTransision)  {
                viewHeight = 100
                loaderBackgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            }
            let viewRect = CGRect(x: 0, y: 0, width: 150, height: viewHeight)
            let viewLoader = UIView(frame: viewRect)
            viewLoader.layer.cornerRadius = 5.0
            viewLoader.layer.masksToBounds = true
            viewLoader.backgroundColor = loaderBackgroundColor
            
            indicator = MaterialLoadingIndicator(frame: CGRect(x: viewLoader.center.x - 15, y: 10, width: 30, height: 30))
            viewLoader.addSubview(indicator)
            
            if (shouldAddTransision) {
                let lblRect = CGRect(x: 10, y: viewHeight - 50, width: Int(viewRect.width)-20, height: 50)
                let lblLoader = UILabel(frame: lblRect)
                lblLoader.font = UIFont(name: kFontOpenSansRegular, size: 13.0)
                lblLoader.text = "Please wait..."
                lblLoader.tag = 100
                lblLoader.numberOfLines = 0
                lblLoader.textAlignment = .center
                lblLoader.lineBreakMode = .byWordWrapping
                viewLoader.addSubview(lblLoader)
            }
            
            let window :UIWindow = UIApplication.shared.keyWindow!
            let xAxis = (window.bounds.width/2)
            let yAxis = (window.bounds.height/2) - 15
            viewLoader.center = CGPoint(x: xAxis, y: yAxis)
            viewLoader.tag = kLOADER_TAG
            window.addSubview(viewLoader)
            window.bringSubview(toFront: viewLoader)
            indicator.startAnimating()
            
            window.isUserInteractionEnabled = false
        }
    }
    
    func removeLoader() {
        self.performSelector(onMainThread: #selector(self.removeMaterialLoader), with: nil, waitUntilDone: true)
    }
    
    
    @objc private func removeMaterialLoader() {
        indicator.stopAnimating()
        let window :UIWindow = UIApplication.shared.keyWindow!
        for loader in window.subviews{
            if loader.tag == kLOADER_TAG {
                loader.removeFromSuperview()
            }
        }
        
        window.isUserInteractionEnabled = true
    }
    
    func changeTheLoaderText(withTitle strTitle:String) {
        
        let window :UIWindow = UIApplication.shared.keyWindow!
        for loader in window.subviews {
            if (loader.tag == kLOADER_TAG){
                if let lblLoader = loader.viewWithTag(100){
                    let loadingLabel = lblLoader as! UILabel
                    loadingLabel.text = strTitle
                    break
                }
            }
        }
    }
}
