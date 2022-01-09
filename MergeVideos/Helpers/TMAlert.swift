//
//  SwerveAlert.swift
//  Swerve
//
//  Created by Crewlogix on 2/9/17.
//  Copyright © 2017 origami. All rights reserved.
//

protocol TMAlertDelegate: class {
    func alertOkBtnDidResponded()
    func alertCancelBtnDidResponded()
    func alertSingleOkBtnDidResponded()
}

import UIKit
import Foundation

class TMAlert: NSObject {

    var delegate: TMAlertDelegate? = nil
    
     func showAlertwith(title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let CancelAction = UIAlertAction(title: "NO", style: .default, handler: {(action:UIAlertAction) in
            self.delegate?.alertCancelBtnDidResponded()
        })
        alert.addAction(CancelAction)
        
        let defaultAction = UIAlertAction(title: "YES", style: .default, handler: {(action:UIAlertAction) in
            self.delegate?.alertOkBtnDidResponded()
        })
        alert.addAction(defaultAction)
        
        presenter.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlertwith(title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
            
        })
        alert.addAction(defaultAction)
        presenter.present(alert, animated: true, completion: nil)
    }
    
    func showTMSingleOkAlertWith(Title title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
            self.delegate?.alertSingleOkBtnDidResponded()
        })
        alert.addAction(defaultAction)
        presenter.present(alert, animated: true, completion: nil)
    }
    
}
