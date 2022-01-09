//
//  CameraPermissions.swift
//  BeatBox
//
//  Created by Shahriyar Ahmed on 20/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPermissions: NSObject {

    typealias CompletionClosure = (_ permission_Status: String) -> Void
    var myCompletion: CompletionClosure?
    
    static let permissionInstance : CameraPermissions = {
        let instance = CameraPermissions()
        return instance
    }()
    
    func checkForCameraPermissions(completion:@escaping CompletionClosure) {
        
        self.myCompletion = completion
        if Platform.isSimulator {
            self.myCompletion!("1")
            return;
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            self.myCompletion!("0")
            debugPrint("Denied, request permission from settings")
        case .restricted:
            self.myCompletion!("0")
            debugPrint("Restricted, device owner must approve")
        case .authorized:
            self.myCompletion!("1")
            debugPrint("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.myCompletion!("1")
                    debugPrint("Permission granted, proceed")
                } else {
                    self.myCompletion!("0")
                    debugPrint("Permission denied")
                }
            }
        }
    }
}
