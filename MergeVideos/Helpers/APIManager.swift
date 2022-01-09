//
//  APIManager.swift
//  PlantMaintenance
//
//  Created by Mubashir on 27/09/2017.
//  Copyright © 2017 Rolustech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster
class APIManager: NSObject {
    
    class func requestGETURL(_ strURL: String, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void) {
        debugPrint(strURL);
        Alamofire.request(strURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            
            if response.result.isSuccess {
                let dict = response.result.value!
                let dictOptimized = dict as! NSDictionary
                success(dictOptimized)
            }
            if response.result.isFailure {
                let error : Error = response.result.error!
                failure(error)
            }
        })
    }
    
    class func requestPOSTURL(_ strURL: String,_ params: NSDictionary, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void) {
        debugPrint(strURL);
        debugPrint(params);
        Alamofire.request(strURL, method: .post, parameters: params as? [String:Any], encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

            if response.result.isSuccess {
                let dict = response.result.value!
                let dictOptimized = dict as! NSDictionary
                success(dictOptimized)
            }
            if response.result.isFailure {
                let error : Error = response.result.error!
                failure(error)
            }
        }
    }
    
    class func requestPOSTFormData(_ requestURL: URL,_ videoData: Data ,_ params: NSDictionary, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void) {
        debugPrint(requestURL);
        debugPrint(params);
//        let imageData = try? Data(contentsOf: fileURL)
        
        let URL = try! URLRequest(url: requestURL, method: .post, headers: nil)
        Alamofire.upload( multipartFormData: { multipartFormData in
            for (key, value) in params {
                
                let strValue = value as! String
                multipartFormData.append(strValue.data(using: .utf8)!, withName: key as! String)
            }
            
            multipartFormData.append(videoData, withName: "video", fileName: "newvideo.mov", mimeType: "video/mov")
        },
        with: URL,
        encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress {
                    p in
                   /* if let currentToast = ToastCenter.default.currentToast {
                        currentToast.cancel()
                    }else{
                        let toast =   Toast(text:"\(Units(bytes: p.completedUnitCount).getReadableUnit()) out of \(Units(bytes: p.totalUnitCount).getReadableUnit())", duration: 4)
                        toast.show()
                    }*/
                    debugPrint("Completed Upload: \(Units(bytes: p.totalUnitCount).getReadableUnit())")
                    debugPrint("Total Size: \(Units(bytes: p.completedUnitCount).getReadableUnit())")

                }
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let dict = response.result.value!
                        let dictOptimized = dict as! NSDictionary
                        success(dictOptimized)
                    }
                    else if response.result.isFailure {
                        let error : Error = response.result.error!
                        failure(error)
                    }
                }
            case .failure(let encodingError):
                failure(encodingError)
            }
        })
    }
    
    class func requestPUTURL(_ strURL: String,_ params: NSDictionary, _ pmSiteId:String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
//        var appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//        if (appVersion == nil) {
//            appVersion = "1.0.0"
//        }
//
//        var headers : HTTPHeaders = [
//            "X-Api-Version": kAppVersion,
//            "Content-Type":"application/json;charset=utf-8",
//            "X-Requested-With": "XMLHttpRequest",
//            ]
//
//        Alamofire.request(strURL, method: .put, parameters: params as? [String:Any], encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
//
//            if response.result.isSuccess {
//                let resJson = JSON(response.result.value!)
//                success(resJson)
//            }
//            if response.result.isFailure {
//                let error : Error = response.result.error!
//                failure(error)
//            }
//        }
    }
    
    class func requestPOSTFinalVideoURL(_ strURL: String,_ params: NSDictionary, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void) {
//        let headers : HTTPHeaders = [
//                    "Content-Type":"application/json;charset=utf-8",
//                    ]
//        debugPrint("mail call")
//        debugPrint(params)
       
        
        
        Alamofire.request(strURL, method: .post, parameters: params as? [String: Any], encoding: JSONEncoding.default, headers: [:]).responseJSON { (response:DataResponse<Any>) in

            if response.result.isSuccess {
                let dict = response.result.value!
                let dictOptimized = dict as! NSDictionary
                success(dictOptimized)
            }
            if response.result.isFailure {
                let error : Error = response.result.error!
                failure(error)
            }
        }
        
        
        
    }
}
struct Platform {

    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

}
public struct Units {

    public let bytes: Int64

    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }

    public var megabytes: Double {
        return kilobytes / 1_024
    }

    public var gigabytes: Double {
        return megabytes / 1_024
    }

    public init(bytes: Int64) {
        self.bytes = bytes
    }

    public func getReadableUnit() -> String {

        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}
