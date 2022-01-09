//
//  ServerTalker.swift
//  PlantMaintenance
//
//  Created by Arbab Ali Khan on 29/09/2017.
//  Copyright © 2017 Rolustech. All rights reserved.
//

import UIKit

//https://api-dev-rt.overdrive.io
var kTMAPIRootUrlEndPoint = "/api/plantmaintenance"
var kTMAPIRootUrl = ""

import Alamofire

class ServerTalker {

    private var arr_Users = NSMutableArray()
    private var arr_Sites = NSMutableArray()
    private var arr_Plants = NSMutableArray()
    private var arr_InspectionFilters = NSMutableArray()
    private var arr_DefectFilters = NSMutableArray()
    private var arr_Photos = NSMutableArray()
    
    private var syncStartDateAndTime = String()
    private var lastSyncDateAndTime = String()
    var isSyncingInProgress = Bool()
    var alamoFireManager : SessionManager?
    private var nonSyncImagesCount = 0
    
    typealias CompletionClosure = (_ dict_Response: NSDictionary?, _ error: Error?) -> Void
    var myCompletion: CompletionClosure?
    
    typealias ImagesCompletionClosure = (_ arr_Photos: NSMutableArray?,_ error: Error?) -> Void
    var myImagesCompletion: ImagesCompletionClosure?
    
    static let sharedInstance : ServerTalker = {
        let instance = ServerTalker()
        return instance
    }()
    
    
    func createGenreFinalVideo(strRequest: String, params: NSMutableDictionary, completion:@escaping CompletionClosure) {
        self.myCompletion = completion
        self.postLoaderNotification(withLoaderName: "")
        
        APIManager.requestPOSTFinalVideoURL(strRequest, params, success: { (JSONResponse) -> Void in
            debugPrint(strRequest);
            debugPrint(params);
            debugPrint(JSONResponse)

            let dictResponse = JSONResponse as NSDictionary
            let status = String(format: "%@", dictResponse.value(forKey: "result") as! CVarArg)
            if (status == "true" || status == "1" || status.lowercased() == "yes" || status.lowercased() == "success") {
                let dataDict = dictResponse.value(forKey: "data") as! NSDictionary
                self.myCompletion!(dataDict, nil)
            }
            else {
                self.myCompletion!(nil, nil)
            }
        },
        failure: {(error) -> Void in
            debugPrint(error)
            self.isSyncingInProgress = false
            if (self.myCompletion != nil) {
                self.myCompletion!(nil, error)
            }
        })
//        let Url = String(format: strRequest)
//               guard let serviceUrl = URL(string: Url) else { return }
//        let parameterDictionary = ["apiKey" : "YUgHNoLUd765h7YH8Ij5Gg754GvTIVb765GvG6t8U0kWA", "token" : "1", "status": "1ce4a10204c9b2f920ab91d83c5e74c2", "videoName": "Drum&Bass"]
//               var request = URLRequest(url: serviceUrl)
//               request.httpMethod = "POST"
//               request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
//               guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
//                   return
//               }
//               request.httpBody = httpBody
//
//               let session = URLSession.shared
//               session.dataTask(with: request) { (data, response, error) in
//                   if let response = response {
//                       print(response)
//                   }
//                   if let data = data {
//                       do {
//                           let json = try JSONSerialization.jsonObject(with: data, options: [])
//                           print(json)
//                       } catch {
//                           print(error)
//                       }
//                   }
//                   }.resume()
       
        
    }
    
    func fetchAppConfigurations(completion: @escaping CompletionClosure){
        self.myCompletion = completion
        self.postLoaderNotification(withLoaderName: "")
        let strRequest = String(format: "%@/config?apikey=%@", kROOT_API_URL, kAPI_KEY)
        APIManager.requestGETURL(strRequest, success: {
            (JSONResponse) -> Void in
            debugPrint(strRequest);
            debugPrint(JSONResponse)
            
            let dictResponse = JSONResponse as NSDictionary
            let status = String(format: "%@", dictResponse.value(forKey: "result") as! CVarArg)
            if (status == "true" || status == "1" || status.lowercased() == "yes" || status.lowercased() == "success") {
                
                let dataDict = dictResponse.value(forKey: "data") as! NSDictionary
                self.myCompletion!(dataDict, nil)
            }
            else {
                
                self.myCompletion!(nil, nil)
            }
        }) {
            (error) -> Void in
            debugPrint(error)
            self.isSyncingInProgress = false
            if (self.myCompletion != nil) {
                self.myCompletion!(nil, error)
            }
        }
    }
    
    func fetchPreviousVideo(strVideoId: String, completion: @escaping CompletionClosure){
        self.myCompletion = completion
        self.postLoaderNotification(withLoaderName: "")
        let strRequest = String(format: "%@/video/%@?apiKey=%@&token=%@", kROOT_API_URL, strVideoId, kAPI_KEY, kAPI_SESSION_TOKEN)
        APIManager.requestGETURL(strRequest, success: {
            (JSONResponse) -> Void in
            debugPrint(strRequest);
            debugPrint(JSONResponse)
            
            let dictResponse = JSONResponse as NSDictionary
            let status = String(format: "%@", dictResponse.value(forKey: "result") as! CVarArg)
            if (status == "true" || status == "1" || status.lowercased() == "yes" || status.lowercased() == "success") {
                
                let dataDict = dictResponse.value(forKey: "data") as! NSDictionary
                self.myCompletion!(dataDict, nil)
            }
            else {
                
                self.myCompletion!(nil, nil)
            }
        }) {
            (error) -> Void in
            debugPrint(error)
            self.isSyncingInProgress = false
            if (self.myCompletion != nil) {
                self.myCompletion!(nil, error)
            }
        }
    }

    func postVideoChunks(strRequest: String, videoData: Data, params: NSMutableDictionary, completion:@escaping CompletionClosure) -> () {

        self.myCompletion = completion
        
        let convertibleURL = URL(string: strRequest)!
        APIManager.requestPOSTFormData(convertibleURL, videoData, params,
        success: {(dict_response) -> Void in
            debugPrint(convertibleURL);
            debugPrint(params);
            debugPrint(dict_response)
            let videosChunkObject = dict_response as NSDictionary
            let status = String(format: "%@", videosChunkObject.value(forKey: "result") as! CVarArg)
            if (status.lowercased() == "failure" || status == "0" || status == "false"){
                self.myCompletion!(nil, nil)
            }
            else {
                let data_Dict = videosChunkObject.value(forKey: "data") as! NSDictionary
                self.myCompletion!(data_Dict, nil)
            }
        },
        failure: {(error) -> Void in
            debugPrint(error)
            self.myCompletion!(nil, error)
        })
    }
    
    func postFinalVidoeFile(strRequest: String, videoData: Data, params: NSMutableDictionary, completion:@escaping CompletionClosure) -> () {
        
        self.myCompletion = completion
        
        let convertibleURL = URL(string: strRequest)!
        APIManager.requestPOSTFormData(convertibleURL, videoData, params,
        success: {(dict_response) -> Void in
            debugPrint(convertibleURL);
             debugPrint(params);
            debugPrint(dict_response)
            let videosChunkObject = dict_response as NSDictionary
            let status = String(format: "%@", videosChunkObject.value(forKey: "result") as! CVarArg)
            if (status.lowercased() == "failure" || status == "0" || status == "false"){
                self.myCompletion!(nil, nil)
            }
            else {
                self.myCompletion!(videosChunkObject, nil)
            }
        },
        failure: {(error) -> Void in
            debugPrint(error)
            self.myCompletion!(nil, error)
        })
    }
    
    func downloadVideoWithProgress(strVideoUrl: String, strDestinationPath: String, strOriginUrl: String, completion:@escaping CompletionClosure) {
        
        self.myCompletion = completion
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(
            strVideoUrl,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
                debugPrint(progress)
            }).response(completionHandler:{ (DefaultDownloadResponse) in
                
                do {
                    let path =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let documentDirectory = URL(fileURLWithPath: path)
                    let originPath = documentDirectory.appendingPathComponent(strOriginUrl)
                    let destinationPath = documentDirectory.appendingPathComponent(strDestinationPath)
                    
                    let fileManager = FileManager.default
                    if !fileManager.fileExists(atPath: originPath.absoluteString) {
                        try FileManager.default.moveItem(at: originPath, to: destinationPath)
                    }
                    
                    let strDestination = String(format: "%@", destinationPath.absoluteString)
                    let dict = NSMutableDictionary()
                    dict.setValue("success", forKey: "success")
                    dict.setValue(strDestination, forKey: "mediaUrl")
                    self.myCompletion!(dict, nil)
                    
                } catch {
                    debugPrint(error)
                    self.myCompletion!(nil, error)
                }
            })
    }
    
    func createGenreDirectory(strFolderName: String, completion:@escaping CompletionClosure) {
        self.myCompletion = completion
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(strFolderName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath) {
                
                do {
                    try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
                    
                    let dict = NSMutableDictionary()
                    dict.setValue("1", forKey: "success")
                    self.myCompletion!(dict, nil)
                }
                catch let error as NSError {
                    debugPrint(error.localizedDescription);
                    self.myCompletion!(nil, error)
                }
            }
            else {
                let dict = NSMutableDictionary()
                dict.setValue("1", forKey: "success")
                self.myCompletion!(dict, nil)
            }
        }
    }
    
    func checkIfFileExistsAtPath(strFileName: String) -> String {
        
        var strFileURL = ""
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(strFileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                strFileURL = String(format: "%@", filePath as CVarArg)
            }
        }
        
        return strFileURL
    }
    
    
    func showAlertWith(Message strMessage: String) {
        NotificationCenter.default.post(name: .errorSyncingData, object: nil)
    }
    
    private func postLoaderNotification(withLoaderName strLoaderName: String){
    
        let dictLoader = NSMutableDictionary()
        dictLoader.setValue(strLoaderName, forKey: "LoaderText")
        NotificationCenter.default.post(name: .changeLoaderText, object: dictLoader)
    }
    
}

extension Notification.Name {
    static let dataSyncCompleted = Notification.Name(rawValue: "dataSyncCompleted")
    static let errorSyncingData = Notification.Name(rawValue: "errorSyncingData")
    static let changeLoaderText = Notification.Name(rawValue: "changeLoaderText")
    static let updatePhotoId = Notification.Name(rawValue: "updatePhotoId")
}
