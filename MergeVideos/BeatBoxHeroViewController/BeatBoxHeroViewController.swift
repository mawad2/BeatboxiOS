//
//  BeatBoxHeroViewController.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 05/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Toaster
import PryntTrimmerView
import Photos
import MobileCoreServices

protocol BeatBoxHeroViewControllerDelegate: class {
    func beatBoxVideoPreviewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int)
}

class BeatBoxHeroViewController: UIViewController, TMAlertDelegate, BeatBoxCameraViewControllerDelegate {
    
    @IBOutlet weak var lblCategoryType: UILabel!
    @IBOutlet weak var viewVideoPlayer2: UIView!
    @IBOutlet weak var viewVideoPlayer: VideoPlayerView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var viewMediaButtons: UIView!
    @IBOutlet weak var viewCreateVideo: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    var asset: AVAsset!
    var totalTimeOfSeq : String!
    var mediaURL: URL!
    var isFinalVideoPreview = Bool()
    var shouldPostNewVideo = Bool()
    var strSavedVideoURL = String()
    var strGenreTitle = String()
    private var player: AVPlayer!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    weak var delegate: BeatBoxHeroViewControllerDelegate? = nil
    var musicIndex = Int()
    var dict_PreviousVideoChunk = NSMutableDictionary()
    var soundModel: SoundBankModel!
    var shouldPop = Bool()
    var mergerVideo = false
    var maxDuration : Double = 5
    var video_array :[Video]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (soundModel != nil) {
            debugPrint("soudn genrer name \(soundModel.strMusicGenreSoundName)")
        }else {
            debugPrint("no sound name")
        }
        
        debugPrint("media path \(mediaURL.absoluteString)")
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.blue
        trimmerView.layer.borderWidth = 1
        
        
        
       if let asset = self.asset {
            trimmerView.asset = asset
            trimmerView.delegate = self
            self.addVideoPlayer(with: asset, playerView: viewVideoPlayer2)
        }
        trimmerView.asset = asset
        trimmerView.delegate = self
        self.addVideoPlayer(with: asset, playerView: viewVideoPlayer2)
        
//        self.lblCategoryType.text = self.strGenreTitle
//
//        if (!shouldPostNewVideo && !self.isFinalVideoPreview) {
//
//            debugPrint("first if condition \(shouldPostNewVideo) , \(self.isFinalVideoPreview)")
//            self.viewVideoPlayer.isHidden = false
//            self.viewVideoPlayer2.isHidden = true
//            self.getSnapShot(strVideoURL:mediaURL.absoluteString) // strSavedVideoURL)
//        }
//        else if (!shouldPostNewVideo && self.isFinalVideoPreview){
//            debugPrint("second if condition \(shouldPostNewVideo) , \(self.isFinalVideoPreview)")
//            self.viewVideoPlayer.isHidden = true
//            self.viewVideoPlayer2.isHidden = false
//            self.getSnapShotForLandScapeView(strVideoURL: mediaURL.absoluteString) //strSavedVideoURL)
//            self.perform(#selector(self.getSnapShotForLandScapeView(strVideoURL:)), with: mediaURL.absoluteString, with: 1)
//        }
//        else {
//            debugPrint("third if condition \(shouldPostNewVideo) , \(self.isFinalVideoPreview)")
//            self.viewVideoPlayer.isHidden = false
//            self.viewVideoPlayer2.isHidden = true
//            self.viewCreateVideo.isHidden = true
//            self.viewMediaButtons.isHidden = false
//            self.getSnapShot(strVideoURL: mediaURL.absoluteString)
//        }
    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if (self.shouldPop) {
//            self.shouldPop = false
//            var strMediaURL = String(format: "%@", mediaURL.absoluteString)
//            strMediaURL = strMediaURL.replacingOccurrences(of: "file://", with: "")
//            self.getSnapShot(strVideoURL: strMediaURL)
//        }
//    }
//
//    @objc private func getSnapShot(strVideoURL: String) {
//
//        for view in self.viewVideoPlayer.subviews {
//            view.removeFromSuperview()
//        }
//        debugPrint("video link ", strVideoURL)
//        let imgVideoPreview = UIImageView()
//        let height = ceil(UIScreen.main.bounds.height * 0.64017991)
//        let width = UIScreen.main.bounds.width-50
//        let videoSnapShotRect = CGRect(x: 0, y: 0, width: width, height: height)
//        imgVideoPreview.frame = videoSnapShotRect
//        self.viewVideoPlayer.addSubview(imgVideoPreview)
//        imgVideoPreview.backgroundColor = UIColor.clear
//        var strModifiedVideoURL = String(format: "%@", strVideoURL)
//        if (self.isFinalVideoPreview || Platform.isSimulator) {
//            strModifiedVideoURL = strModifiedVideoURL.replacingOccurrences(of: "file://", with: "")
//        }
//        debugPrint("after updte video \(strModifiedVideoURL)")
//        imgVideoPreview.image = self.videoSnapshot(strVideoURL: strModifiedVideoURL, imageRect: CGSize(width: videoSnapShotRect.width, height: videoSnapShotRect.height)) //strModifiedVideoURL
//        imgVideoPreview.contentMode = .scaleAspectFit
//        imgVideoPreview.clipsToBounds = true
//
//    }
//
//    @objc private func getSnapShotForLandScapeView(strVideoURL: String) {
//        for view in self.viewVideoPlayer2.subviews {
//            view.removeFromSuperview()
//        }
//
//        let width = ceil(UIScreen.main.bounds.height * 0.64017991)
//        let height = UIScreen.main.bounds.width-50
//        let videoSnapShotRect = CGRect(x: 0, y: 0, width: width, height: height)
//        let imgVideoPreview = UIImageView()
//        imgVideoPreview.frame = videoSnapShotRect
//        imgVideoPreview.backgroundColor = UIColor.clear
//        var strModifiedVideoURL = String(format: "%@", strVideoURL)
//        strModifiedVideoURL = strModifiedVideoURL.replacingOccurrences(of: "file://", with: "")
//        imgVideoPreview.image = self.videoSnapshot(strVideoURL: strModifiedVideoURL, imageRect: CGSize.init(width: videoSnapShotRect.width, height: videoSnapShotRect.height))
//        imgVideoPreview.contentMode = .scaleAspectFit
//        imgVideoPreview.clipsToBounds = true
//        self.viewVideoPlayer2.addSubview(imgVideoPreview)
//
//        self.viewMediaButtons.isHidden = true
//        self.viewCreateVideo.isHidden = false
//
//        self.viewVideoPlayer2.autoresizesSubviews = true
//        self.viewVideoPlayer2.translatesAutoresizingMaskIntoConstraints = false
//        self.viewVideoPlayer2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
//
//        self.perform(#selector(changeOrientationForView), with: nil, afterDelay: 0.1)
//    }
//
//    @objc private func changeOrientationForView() {
//        UIView.animate(withDuration: 0.05, animations:{
//
//            self.viewVideoPlayer2.frame = CGRect(x: self.viewVideoPlayer.frame.origin.x, y: self.viewVideoPlayer.frame.origin.y, width: self.viewVideoPlayer2.frame.size.width, height: self.viewVideoPlayer2.frame.size.height)
//        })
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
         let playerItem = AVPlayerItem(asset: asset)
         player = AVPlayer(playerItem: playerItem)
         
         NotificationCenter.default.addObserver(self, selector: #selector(BeatBoxHeroViewController.itemDidFinishPlaying(_:)),
                                                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
         
         let layer: AVPlayerLayer = AVPlayerLayer(player: player)
         layer.backgroundColor = UIColor.white.cgColor
         layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
           layer.videoGravity = AVLayerVideoGravity.resizeAspect
         playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
         playerView.layer.addSublayer(layer)
       }
       
        @objc func itemDidFinishPlaying(_ notification: Notification) {
          if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
            
          }
        }
    
    
    
    //MARK: Btn Action Play Video
    @IBAction func btnActionPlayVideo(_ sender: Any) {
        
//        if (self.isFinalVideoPreview) {
//            self.perform(#selector(self.transformVideoPreview), with: nil, afterDelay: 0.5)
//        }
//        else {
//            var strMediaURL = String(format: "%@", mediaURL.absoluteString)
//            strMediaURL = strMediaURL.replacingOccurrences(of: "file://", with: "")
//            playVideo(forURL: strMediaURL)
//        }
        
        guard let player = player else { return }

        if !player.isPlaying {
          player.play()
          startPlaybackTimeChecker()
        } else {
          player.pause()

          stopPlaybackTimeChecker()
        }
        
    }
    
    func startPlaybackTimeChecker() {
       
       stopPlaybackTimeChecker()
       playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                       selector:
         #selector(BeatBoxHeroViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
     }
     
     func stopPlaybackTimeChecker() {
       
       playbackTimeCheckerTimer?.invalidate()
       playbackTimeCheckerTimer = nil
     }
    
    
     @objc func onPlaybackTimeChecker() {
       
       guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
         return
       }
       
       let playBackTime = player.currentTime()
       trimmerView.seek(to: playBackTime)
       
       if playBackTime >= endTime {
         player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
         trimmerView.seek(to: startTime)
       }
     }
    
    @IBAction func TrimVideoAction(_ sender: Any) {
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        //print(duration)
        if (duration < maxDuration) {
           let startTime = Float(trimmerView.startTime!.seconds)
            let endTime = Float(trimmerView.endTime!.seconds)
            self.cropVideo(sourceURL1: mediaURL as! NSURL, startTime: startTime, endTime: endTime)
        }else {
           
            let alertController = UIAlertController(title: "Trim video not more than 5 second", message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    
    //Trim Video Function
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
    {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            //print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            //print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                let soundGenerName = soundModel.strMusicGenreSoundName
                //debugPrint("sound name \(soundGenerName)")
                outputURL = outputURL.appendingPathComponent("\(soundGenerName)1.mp4")
                //print("output video name : \(outputURL)")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    //print("exported at \(outputURL)")
                    self.saveToCameraRoll(URL: outputURL as NSURL?)
                    //self.saveVideoToDocumentedDirectory(outputURL: outputURL)
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }}}}
    
    //get current date
    func getCurrentDate() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        //print("current date \(dateString)")
        return dateString
    }
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!) {
        
        do {
            
            let beatBoxModel = BeatBoxModel()
            beatBoxModel.date = getCurrentDate()
            beatBoxModel.genre = strGenreTitle
            beatBoxModel.videoData = "\(String(describing: URL!))"
            beatBoxModel.name = soundModel.strMusicGenreSoundName
            beatBoxModel.musicGenreId = soundModel.strMusicGenreId
            beatBoxModel.musicGenreSoundId = soundModel.strMusicGenreSoundId
            
            let repository = VideoDataRepository()
            repository.createVideo(videoData: beatBoxModel)
            playbackTimeCheckerTimer?.invalidate()
            playbackTimeCheckerTimer = nil
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Cropped video was saved successfully", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
                    self.dismiss(animated: true) {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        } catch {
            print(error.localizedDescription)
        }
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
//        }) { saved, error in
//            if saved {
//                DispatchQueue.main.async {
//                    let alertController = UIAlertController(title: "Cropped video was saved successfully", message: nil, preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.present(alertController, animated: true, completion: nil)
//                }
//
//            }}
        
    }
    
//    @objc private func transformVideoPreview() {
//
//        for view in self.viewVideoPlayer2.subviews {
//            view.removeFromSuperview()
//        }
//
//        var strMediaURL = String(format: "%@", self.strSavedVideoURL)
//        strMediaURL = strMediaURL.replacingOccurrences(of: "file://", with: "")
//        if (FileManager.default.fileExists(atPath: strMediaURL)){
//            playVideo(forURL: strMediaURL)
//        }else{
//            let strMessage = String(format: "Please record your video again, unable to play video")
//            self.showAlertWith(strMessage: strMessage)
//        }
//    }
//
//    private func playVideo(forURL mediaURL: String) {
//
//        let videoURL = URL(fileURLWithPath: mediaURL)
//        let videoPlayer = AVPlayer(url: videoURL)
//        let playerLayer = AVPlayerLayer(player: videoPlayer)
//        if (self.isFinalVideoPreview) {
//            playerLayer.frame = self.viewVideoPlayer2.bounds
//            self.viewVideoPlayer2.layer.addSublayer(playerLayer)
//        }
//        else {
//
//            for view in self.viewVideoPlayer.subviews {
//                view.removeFromSuperview()
//            }
//
//            playerLayer.frame = CGRect(x: 0, y: 0, width: self.viewVideoPlayer.bounds.width, height: self.viewVideoPlayer.bounds.height)
//            self.viewVideoPlayer.layer.addSublayer(playerLayer)
//        }
//        videoPlayer.play()
//    }
//
//    private func videoSnapshot(strVideoURL: String, imageRect: CGSize) -> UIImage? {
//
//        var videoURL: URL? = nil
////        self.strSavedVideoURL = self.strSavedVideoURL.replacingOccurrences(of: "file://", with: "")
//        videoURL = URL(fileURLWithPath: strVideoURL)
//        debugPrint("string url \(strVideoURL),\n  \(videoURL) ")
//        let asset = AVURLAsset(url: videoURL!, options: [:])
//        let generator = AVAssetImageGenerator(asset: asset)
//        generator.appliesPreferredTrackTransform = true
//        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
//
//        do {
//            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
//            let image = UIImage(cgImage: imageRef)
//
//            let rect = CGRect(x: 0, y: 0, width: imageRect.width, height: imageRect.height)
//            UIGraphicsBeginImageContextWithOptions(imageRect, false, 1.0)
//            image.draw(in: rect)
//            let newImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
//            return newImage
//        }
//        catch let error as NSError {
//            debugPrint("Image generation failed with error \(error)")
//            return nil
//        }
//    }

    //MARK: Btn Action Share
    @IBAction func btnActionShare(_ sender: Any) {
        
        if (mergerVideo == true) {
            // delete all the gener
            do {
                    let _ =  try self.deletefiles(video_array: video_array)
            } catch let error {
                self.removeLoader()
                let errorMessage = "Could not merge videos: \(error.localizedDescription)"
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (a) in
                }))
                self.present(alert, animated: true) {() -> Void in }
                    return

            }
            
            //Save video into camera roll
            // pass new merge video to player
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.mediaURL! as URL)
            }) { saved, error in
                if saved {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Merged video was saved successfully", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
                        let beatBoxBoard = UIStoryboard(name: "Main", bundle: nil)
                        let soundBankController = beatBoxBoard.instantiateViewController(withIdentifier: "selectGenreViewController") as! SelectGenreViewController
                            self.navigationController?.pushViewController(soundBankController, animated: true)
                            })
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                            
                                
                            }
                              
                          }}
        }else {
            let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
                           //print(duration)
            if (duration < 5) {
                let startTime = Float(trimmerView.startTime!.seconds)
                let endTime = Float(trimmerView.endTime!.seconds)
                //debugPrint("start point \(startTime), end time \(endTime)")
                self.cropVideo(sourceURL1: mediaURL! as NSURL, startTime: startTime, endTime: endTime)
            }else {
                              
                let alertController = UIAlertController(title: "Trim video not more than 5 second", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }

            //        let videoEditedLocally = self.dict_PreviousVideoChunk.value(forKey: "videoEditedLocally") as! String
            //        if (videoEditedLocally == "1") {
            //            saveVideoToDocumentedDirectory()
            //        }
            //        else {
            //            let strMessage = String(format: "Please record a new %@", soundModel.strMusicGenreSoundName)
            //            self.showAlertWith(strMessage: strMessage)
            //        }
        }
        
    }
    
    //MARK: Delete all file after merge video
    private func deletefiles(video_array: [Video]) throws -> Bool {
               let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
               let url = NSURL(fileURLWithPath: path)
               if let pathComponent = url.appendingPathComponent("output") {
                   for index in 0 ..< video_array.count {
                       let filePathURL = pathComponent.appendingPathComponent("/\(video_array[index].name!)")
                       let filePath = filePathURL.path
                       let fileManager = FileManager.default
                       if fileManager.fileExists(atPath: filePath) {
                        try fileManager.removeItem(atPath: filePath)
                       }
                   }
               }else {
                   self.showAlertWith(strMessage: MSG_UPLOAD_VIDEO)
               }
        
        let repo = VideoDataRepository()
        let result = repo.deleteRecord()
        print("all record deleted \(result)")
        return true
    }

    private func saveVideoToDocumentedDirectory(outputURL : URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.strSavedVideoURL) {
            try? fileManager.removeItem(atPath: self.strSavedVideoURL)
        }

        let genreVideoData = try! Data(contentsOf: mediaURL)
        try? genreVideoData.write(to: URL(fileURLWithPath: self.strSavedVideoURL), options: [])
        self.dict_PreviousVideoChunk.setValue(genreVideoData, forKey: "videoData")
        self.dict_PreviousVideoChunk.setValue(self.strSavedVideoURL, forKey: "mediaUrl")
        self.dict_PreviousVideoChunk.setValue("1", forKey: "videoEditedLocally")

        /*Reset Thumbnail Image */
        let asset = AVURLAsset(url: mediaURL, options: [:])
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            
                let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                let image = UIImage(cgImage: imageRef)

                for view in self.viewVideoPlayer.subviews {
                    view.removeFromSuperview()
                }

                let imgVideoPreview = UIImageView()
                imgVideoPreview.frame = self.viewVideoPlayer.bounds
                imgVideoPreview.contentMode = .scaleAspectFit
                imgVideoPreview.image = image
                self.viewVideoPlayer.addSubview(imgVideoPreview)
            
        }
        catch let error as NSError {
            debugPrint("Image generation failed with error \(error)")
        }

        self.perform(#selector(self.uploadVideoChunk), on: .main, with: nil, waitUntilDone: true)
    }
    
    
    //MARK: POST Video Clips to Cloud
    @objc private func startLoader() {
        self.addLoader(withTransition: true)
    }
    
    @objc private func uploadVideoChunk() {
        
        var strVideoId = "2"
        if (UserDefaults.standard.value(forKey: "videoId") != nil){
            strVideoId = String(format: "%@", UserDefaults.standard.value(forKey: "videoId") as! CVarArg)
        }
        
        self.perform(#selector(startLoader), with: nil, afterDelay: 0.3)
        let params = NSMutableDictionary()
        params.setValue(kAPI_KEY, forKey: "apiKey")
        params.setValue(kAPI_SESSION_TOKEN, forKey: "token")
        params.setValue(strVideoId, forKey: "videoId")
        params.setValue("1", forKey: "status")
        let strMusicGenreSoundId = String(format: "%@", self.dict_PreviousVideoChunk.value(forKey: "musicGenreSoundId") as! CVarArg)
        params.setValue(strMusicGenreSoundId, forKey: "musicGenreSoundId")
        let mediaData = self.dict_PreviousVideoChunk.value(forKey: "videoData") as! Data
        
        var strRequest = ""
        if (self.shouldPostNewVideo) {
            strRequest = String(format: "%@/musicGenreSoundRec", kROOT_API_URL)
        }
        else {
            let chunkVideoId = self.dict_PreviousVideoChunk.value(forKey: "musicGenreSoundRecId") as! String
            strRequest = String(format: "%@/musicGenreSoundRec/edit/%@", kROOT_API_URL, chunkVideoId)
        }
        
        ServerTalker.sharedInstance.postVideoChunks(strRequest: strRequest, videoData: mediaData, params: params, completion: { (dataDict, error) in
            
            self.removeLoader()
            if (error == nil) {
                
                self.dict_PreviousVideoChunk.addEntries(from: dataDict as! [AnyHashable : Any])
                self.dict_PreviousVideoChunk.setValue("0", forKey: "videoEditedLocally")
                let successAlert = TMAlert()
                successAlert.delegate = self
                successAlert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: "Your video has been uploaded successfully!", presenter: self)
            }
            else {
                self.showAlertWith(strMessage: MSG_ERROR_OCCURRED)
            }
        })
    }
    /*___________________________________________________ */
    
    //MARK: Alert View Delegate Implementation
    private func showAlertWith(strMessage: String) {
        let alert = TMAlert()
        alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: strMessage, presenter: self)
    }
    
    func alertOkBtnDidResponded(){}
    func alertCancelBtnDidResponded(){}
    
    func alertSingleOkBtnDidResponded(){
        
        if !(self.isFinalVideoPreview) {
            self.dict_PreviousVideoChunk.removeObject(forKey: "videoData")
            self.delegate?.beatBoxVideoPreviewControllerDidRespondedWith(musicDict: self.dict_PreviousVideoChunk, withIndex: self.musicIndex)
        }
        
        for controller in (self.navigationController?.viewControllers)! {
            if (controller is SoundBankViewController) {
                let soundBankController = controller as! SoundBankViewController
                self.navigationController?.popToViewController(soundBankController, animated: true)
                break
            }
        }
//        if (shouldPostNewVideo) {}
//        else {}
    }
    /*___________________________________________________ */
    
    //MARK: btn Action Create Video
    @IBAction func btnActionCreateVideo(_ sender: Any) {
        
        self.addLoader(withTransition: true)
        self.perform(#selector(self.synthesizeFinalVideo), with: nil, afterDelay: 0.3)
    }
    
    @objc private func synthesizeFinalVideo() {
        
        var strVideoName = "Video 2"
        if (UserDefaults.standard.value(forKey: "videoName") != nil){
            strVideoName = String(format: "%@", UserDefaults.standard.value(forKey: "videoName") as! CVarArg)
        }

        var strVideoId = "2"
        if (UserDefaults.standard.value(forKey: "videoId") != nil){
            strVideoId = String(format: "%@", UserDefaults.standard.value(forKey: "videoId") as! CVarArg)
        }

        let params = NSMutableDictionary()
        params.setValue(kAPI_KEY, forKey: "apiKey")
        params.setValue(kAPI_SESSION_TOKEN, forKey: "token")
        params.setValue(strVideoId, forKey: "videoId")
        params.setValue(strVideoName, forKey: "videoName")
        params.setValue("1", forKey: "status")

        var strMediaURL = String(format: "%@", self.strSavedVideoURL)
        strMediaURL = strMediaURL.replacingOccurrences(of: "file://", with: "")
        let videoURL = URL(fileURLWithPath: strMediaURL)

        let genreVideoData = try! Data(contentsOf: videoURL)
        let strRequest = String(format: "%@/video/edit/%@", kROOT_API_URL, strVideoId)
        ServerTalker.sharedInstance.postFinalVidoeFile(strRequest: strRequest, videoData: genreVideoData, params: params, completion: { (dataDict, error) in

            if (error == nil) {
                self.perform(#selector(self.showSuccessAlert), on: .main, with: nil, waitUntilDone: true)
            }
            else {
                self.removeLoader()
                self.showAlertWith(strMessage: MSG_ERROR_OCCURRED)
            }
        })
    }
    
    @objc private func showSuccessAlert() {
        self.removeLoader()
        let alert = TMAlert()
        alert.delegate = self
        alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: "Your video has been uploaded successfully!", presenter: self)
        
       
    }
    
    //MARK: btnAction Record/Edit Video
    @IBAction func btnActionRecord(_ sender: Any) {

        var isFound = false
        for controller in (self.navigationController?.viewControllers)! {
            if (controller is BeatBoxCameraViewController) {

                isFound = true
                let soundBankController = controller as! BeatBoxCameraViewController
                self.navigationController?.popToViewController(soundBankController, animated: true)
                break
            }
        }

        if !(isFound) {
            let beatBoxBoard = UIStoryboard(name: "BeatBoxCameraBoard", bundle: nil)
            let cameraBeatBox = beatBoxBoard.instantiateViewController(withIdentifier: "BeatBoxCameraViewController") as! BeatBoxCameraViewController
            cameraBeatBox.delegate = self
            cameraBeatBox.soundBank = soundModel
            cameraBeatBox.shouldPop = true
            cameraBeatBox.strGenreTitle = self.strGenreTitle
            cameraBeatBox.strSavedVideoURL = self.strSavedVideoURL
            cameraBeatBox.dict_PreviousVideoChunk = dict_PreviousVideoChunk
            cameraBeatBox.musicIndex = musicIndex
            self.navigationController?.pushViewController(cameraBeatBox, animated: true)
        }
    }
    
    func beatBoxCameraViewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int) {}

    
    @IBAction func showLogs(_ sender: Any) {

        if self.isFinalVideoPreview {

            var strMediaURL = String(format: "%@", self.strSavedVideoURL)
            strMediaURL = strMediaURL.replacingOccurrences(of: "file://", with: "")
            let videoURL = URL(fileURLWithPath: strMediaURL)
            let asset = AVURLAsset(url: videoURL, options: [:])
            let  audioDurationSeconds = CMTimeGetSeconds(asset.duration);
            let logsVC : BeatBoxLogsViewControllers = UIStoryboard.init(name: "BeatBoxBoard", bundle: nil).instantiateViewController(withIdentifier: "BeatBoxLogsViewControllers") as! BeatBoxLogsViewControllers
            logsVC.textToShow = "View URL : \(asset.url.absoluteString) \n\n\nand Duration of the video is : \(String(format: "%.2f", audioDurationSeconds))s \n\n\n\nand total of seqeunce that merge video is : \(totalTimeOfSeq as String)"
            self.navigationController?.pushViewController(logsVC, animated: true)
        } else {
            let toast =   Toast(text:"Show logs only active For final video", duration: 3)
            toast.show()
        }

    }
    //MARK: btnAction Back Navigation
    @IBAction func btnActionBack(_ sender: Any) {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BeatBoxHeroViewController: TrimmerViewDelegate {
    
  func positionBarStoppedMoving(_ playerTime: CMTime) {
    //print("play")
    player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    player?.play()
    startPlaybackTimeChecker()
    let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
    print("duration \(duration)")
  }
  
  func didChangePositionBar(_ playerTime: CMTime) {
    stopPlaybackTimeChecker()
    player?.pause()
    player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
    print(duration)
  }
}
extension AVPlayer {
  
  var isPlaying: Bool {
    return self.rate != 0 && self.error == nil
  }
}
class VideoPlayerView: UIView {
var playerLayer: CALayer?

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}
