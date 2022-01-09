//
//  BeatBoxCameraViewController.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 09/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

protocol BeatBoxCameraViewControllerDelegate: class {
    func beatBoxCameraViewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int)
}

class BeatBoxCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BeatBoxHeroViewControllerDelegate  {

    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblGenreTitle: UILabel!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var viewAnimation: UIView!
    @IBOutlet weak var imgAnimation: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet var galleryButton: UIButton!
    
    var delegate: BeatBoxCameraViewControllerDelegate? = nil
    var strGenreTitle = String()
    var soundBank: SoundBankModel!
    private var picker = UIImagePickerController()
    private var counter = 3
    private var videoTimer = 0
    var strSavedVideoURL = String()
    var shouldPop = Bool()
    var recoding = false
    
    var dict_PreviousVideoChunk = NSMutableDictionary()
    var musicIndex = Int()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (soundBank != nil) {
            debugPrint("soudn genrer name \(soundBank.strMusicGenreSoundName)")
        }else {
            debugPrint("no sound name")
        }
        
        self.lblGenreTitle.text =  String(format: "Record a %@", soundBank.strMusicGenreSoundName)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
            self.checkCameraAccess()
        })
    }
    
    @IBAction func openPhotoGalleryAction(_ sender: Any) {
        
        self.perform(#selector(self.openPhotoLibraryBrowser), with: nil, afterDelay: 0.1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Present Photo Library to Edit Current Video Selection
    @objc private func openPhotoLibraryBrowser() {


        if Platform.isSimulator {

            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.mediaTypes = [kUTTypeMovie as String] // kUTTypeImage
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)

        }else{

            picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.mediaTypes = ["public.movie"]
            picker.sourceType = .camera
            picker.cameraCaptureMode = .video
            // picker.videoMaximumDuration = 2
            picker.showsCameraControls = false
            picker.cameraFlashMode = .off
            picker.videoQuality = .typeLow

            picker.view.frame = CGRect(x: 0, y: 0, width: viewCamera.frame.size.width, height: viewCamera.frame.size.height)
            viewCamera.addSubview(picker.view)

        }
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if !recoding{
                   self.videoTimer = 0
                    self.lblTimer.text = "00:00:00"
                    self.viewTimer.isHidden = true
                    self.dict_PreviousVideoChunk.setValue("1", forKey: "videoEditedLocally")
                    var mediaURL : URL!
                    var asset: AVAsset!
                    mediaURL    = (info[UIImagePickerControllerMediaURL] as? URL)!
                    asset   = AVURLAsset.init(url: mediaURL! as URL)
                    if Platform.isSimulator {
                        //mediaURL    = (Bundle.main.url(forResource: "movie3", withExtension: "mp4") ?? nil)!
                        dismiss(animated: true) {
                            self.changeUserInteractionState(state: true)
                            if (self.shouldPop) {
            //                    self.perform(#selector(self.popBeatBoxHeroViewController(mediaURL:asset:)), with: mediaURL,  afterDelay: 0.05)
            //                    self.perform(#selector(self.popBeatBoxHeroViewController(mediaURL:asset:)), with: (mediaURL, asset), afterDelay: 0.05)
                                self.popBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                                
                            }
                            else {
            //                    self.perform(#selector(self.pushBeatBoxHeroViewController(mediaURL:asset:)), with: mediaURL, afterDelay: 0.05)
            //                    self.perform(#selector(self.pushBeatBoxHeroViewController(mediaURL:asset:)), with: (mediaURL, asset), afterDelay: 0.05)
                                self.pushBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                            }
                        }
                    }else{
                        //mediaURL    = (info[UIImagePickerControllerMediaURL] as? URL)!
                        changeUserInteractionState(state: true)
                        if (self.shouldPop) {
            //                self.perform(#selector(self.popBeatBoxHeroViewController(mediaURL:asset:)), with: mediaURL, afterDelay: 0.05)
            //                self.perform(#selector(self.popBeatBoxHeroViewController(mediaURL:asset:)), with: (mediaURL, asset), afterDelay: 0.05)
                            self.popBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                        }
                        else {
            //                self.perform(#selector(self.pushBeatBoxHeroViewController(mediaURL:asset:)), with: mediaURL, afterDelay: 0.05)
            //                self.perform(#selector(self.pushBeatBoxHeroViewController(mediaURL:asset:)), with: (mediaURL, asset), afterDelay: 0.05)
                            self.pushBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: soundBank)
                        }
                    }
        }
        else {
            dismiss(animated: true, completion: nil)
            
//            guard
//              let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
//              mediaType == (kUTTypeMovie as String),
//              // 1
//              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
//              // 2
//              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
//              else { return }
            var mediaURL : URL!
            var asset: AVAsset!
            mediaURL    = (info[UIImagePickerControllerMediaURL] as? URL)!
            asset   = AVURLAsset.init(url: mediaURL! as URL)
            
//              let videourl = NSURL(fileURLWithPath: mediaURL)
//              let asset   = AVURLAsset.init(url: videourl as URL)
              
              if Platform.isSimulator {
                        
                    dismiss(animated: true) {
                        self.changeUserInteractionState(state: true)
                    if (self.shouldPop) {
                        self.popBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                        }
                    else {
                        self.pushBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                        }
                    }
             }else{
                        //mediaURL    = (info[UIImagePickerControllerMediaURL] as? URL)!
                        changeUserInteractionState(state: true)
                        if (self.shouldPop) {
                            self.popBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                        }
                        else {
                            self.pushBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: soundBank)
                        }
            }
        }
 

    }
    
    @objc private func pushBeatBoxHeroViewController(mediaURL: URL, asset: AVAsset, soundModel: SoundBankModel) {
        let beatBoxHeroBoard = UIStoryboard(name: "BeatBoxBoard", bundle: nil)
        let beatBoxHeroViewController = beatBoxHeroBoard.instantiateViewController(withIdentifier: "BeatBoxHeroViewController") as! BeatBoxHeroViewController
        beatBoxHeroViewController.delegate = self
        beatBoxHeroViewController.shouldPostNewVideo = true
        beatBoxHeroViewController.strGenreTitle = self.strGenreTitle
        beatBoxHeroViewController.strSavedVideoURL = self.strSavedVideoURL
        beatBoxHeroViewController.mediaURL = mediaURL
        beatBoxHeroViewController.asset = asset
        beatBoxHeroViewController.soundModel = soundModel
        beatBoxHeroViewController.dict_PreviousVideoChunk = self.dict_PreviousVideoChunk
        self.navigationController?.pushViewController(beatBoxHeroViewController, animated: true)
    }
    
    @objc private func popBeatBoxHeroViewController(mediaURL: URL, asset: AVAsset, soundModel: SoundBankModel) {
        
        for beatController in (self.navigationController?.viewControllers)! {
            if (beatController is BeatBoxHeroViewController) {
                let beatBoxHeroViewController = beatController as! BeatBoxHeroViewController
                beatBoxHeroViewController.mediaURL = mediaURL
                beatBoxHeroViewController.asset = asset
                beatBoxHeroViewController.shouldPop = true
                beatBoxHeroViewController.dict_PreviousVideoChunk = dict_PreviousVideoChunk
                self.navigationController?.popToViewController(beatBoxHeroViewController, animated: true)
                break
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Record Action
    @IBAction func btnActionRecord(_ sender: Any) {

//        if (self.counter != 3){
//            self.counter = 3
//            let strImage = String(format: "Play-%d", self.counter)
//            self.imgAnimation.image = UIImage(named: strImage)
//            UIView.animate(withDuration: 0.4, animations: {
//                self.imgAnimation.alpha = 1
//            },completion: { _ in})
//        }
        changeUserInteractionState(state: false)
        DispatchQueue.main.async {
            self.playAnimation()
        }
    }
    
    //MARK: Play Animation with Transition
    @objc private func playAnimation() {
        self.viewAnimation.isHidden = true
        self.startCapturingSessionAndShowTimer()
        
//        if (self.counter == 1) {
//            DispatchQueue.main.async {
//                self.viewAnimation.isHidden = true
//                if !Platform.isSimulator {
//                    self.picker.startVideoCapture()
//                }
//                self.startCapturingSessionAndShowTimer()
//            }
//        } else {
//            UIView.animate(withDuration: 0.7, animations: {
//                self.imgAnimation.alpha = 0
//            },
//            completion: { _ in
//                self.counter -= 1
//                let strImage = String(format: "Play-%d", self.counter)
//                self.imgAnimation.image = UIImage(named: strImage)
//                UIView.animate(withDuration: 0.4, animations: {
//                    self.imgAnimation.alpha = 1
//                },
//                completion: { _ in
//                    self.playAnimation()
//                })
//            })
//        }
    }

    private func changeUserInteractionState(state: Bool) {
        self.view.isUserInteractionEnabled = state
        self.viewAnimation.isHidden = state
    }
    
    //MARK: BeatBox Hero ViewController Delegate
    func beatBoxVideoPreviewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int) {
        self.delegate?.beatBoxCameraViewControllerDidRespondedWith(musicDict: musicDict, withIndex: musicIndex)
    }
    
    //MARK: Show Timer and Record Video
    private func startCapturingSessionAndShowTimer() {

        self.viewTimer.isHidden = false;
        //self.perform(#selector(self.showTimer), with: nil, afterDelay: 1);
        //self.perform(#selector(self.printDate), with: nil, afterDelay: 1)
        //Start recoding
        recoding = true
        BeatBoxCameraViewController.startMediaBrowser(delegate: self, sourceType: .camera)
    
    }
    @objc private func printDate() {
        debugPrint(Date());
    }
    
    @objc private func showTimer() {

        if (self.videoTimer == 2) {
            if !Platform.isSimulator {
                self.perform(#selector(self.stopVideoCaptureAndPushBeatBoxHeroController), on: .main, with: nil, waitUntilDone: true)
            }else {
                self.videoTimer = 0
                self.lblTimer.text = "00:00:00"
                self.viewTimer.isHidden = true
                self.changeUserInteractionState(state: true);
            }
           // self.printDate();
        } else {
            self.videoTimer += 1
            self.lblTimer.text = String(format: "00:00:0%d", self.videoTimer)
            self.perform(#selector(self.showTimer), with: nil, afterDelay: 1)
        }

    }
    
    @objc private func stopVideoCaptureAndPushBeatBoxHeroController() {
        self.picker.stopVideoCapture()
    }
    
    //MARK:- for camera permission
    private func checkCameraAccess() {
        
        CameraPermissions.permissionInstance.checkForCameraPermissions(completion: {(status) in
            self.stopTimer()
            if (status == "0") {
                self.pushDeniedPermissionsSettingsController()
            }
        })
    }
    
    private func stopTimer() {
        if (self.timer != nil) {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    private func pushDeniedPermissionsSettingsController() {
        
        let CameraAccessStatusBoard = UIStoryboard(name: "CameraAccessStatusBoard", bundle: nil)
        let cameraAccessStatusViewController = CameraAccessStatusBoard.instantiateViewController(withIdentifier: "CameraAccessStatusViewController") as! CameraAccessStatusViewController
        self.navigationController?.pushViewController(cameraAccessStatusViewController, animated: true)
    }
    
    
    //TODO: Recod code
    static func startMediaBrowser(
      delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
      sourceType: UIImagePickerController.SourceType
    ) {
      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }

      let mediaUI = UIImagePickerController()
      mediaUI.sourceType = sourceType
      mediaUI.mediaTypes = [kUTTypeMovie as String]
      mediaUI.allowsEditing = true
      mediaUI.delegate = delegate
      delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    
}


