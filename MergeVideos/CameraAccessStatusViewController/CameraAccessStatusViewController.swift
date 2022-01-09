//
//  CameraAccessStatusViewController.swift
//  BeatBox
//
//  Created by Shahriyar Ahmed on 20/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class CameraAccessStatusViewController: UIViewController {
    @IBOutlet weak var btnSettings: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.perform(#selector(roundOffPreview), with: nil, afterDelay: 0.4)
    }
    
    //MARK: Round Off Layer Preview
    @objc private func roundOffPreview() {
        btnSettings.layer.cornerRadius = 10
        btnSettings.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        CameraPermissions.permissionInstance.checkForCameraPermissions(completion: {(status) in
            if (status == "1") {
                let MainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let navigation = MainStoryBoard.instantiateViewController(withIdentifier: "Navigation") as! UINavigationController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigation
                appDelegate.window?.makeKeyAndVisible()
            }
        })
    }
    
    //MARK: Btn Action Settings Controller
    @IBAction func btnActionSettings(_ sender: Any) {
        
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            self.showAlertWith(strMessage: MSG_SETTINGS_APP)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                debugPrint("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    //MARK: Alert View Delegate Implementation
    private func showAlertWith(strMessage: String) {
        let alert = TMAlert()
        alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: strMessage, presenter: self)
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        for controller in (self.navigationController?.viewControllers)!{
            if (controller is SoundBankViewController) {
                let soundController = controller as! SoundBankViewController
                self.navigationController?.popToViewController(soundController, animated: true)
                break
            }
        }
    }
}
