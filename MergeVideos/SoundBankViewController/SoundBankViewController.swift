//
//  SelectSequenceViewController.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 01/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//



import UIKit
import Photos
import SDWebImage
import Toaster
import AVKit
import AVFoundation
import Toaster
import PryntTrimmerView
import MobileCoreServices

class SoundBankViewController: UIViewController, BeatBoxHeroViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TMAlertDelegate, BeatBoxCameraViewControllerDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var genreModel: GenreModel!
    
    @IBOutlet weak var btnBackNavigation: UIButton!
    @IBOutlet weak var btnPreviewVideo: UIButton!
    @IBOutlet weak var soundCollection: UICollectionView!

    private var strGenreTrimmedTitle = String()
    var arr_DownloadRequests = NSMutableArray()
    
    @IBOutlet weak var btnBack: UIButton!
    var dict_PreviousVideo = NSMutableDictionary()
    var arr_ProvidedSequence = NSMutableArray()
    
    @IBOutlet weak var viewParent: UIView!
    @IBOutlet weak var viewToastMsg: UIView!
    @IBOutlet weak var lblToast: UILabel!
    
    let repo = VideoDataRepository()
    
    var recursiveCount = -1
    var selectedIndex = -1
    var totalTimeOfVideoSholdBe = 0.0
    let chunkedAForMergingBy = 4
    private var width = CGFloat()
    private var height = CGFloat()
    var trimVideoArray = [URL]()


    var arr_JoiningSequenceA  = NSMutableArray()
    var arr_joiningVideoChunks  = NSMutableArray()
    var arrayOfTotalVideo = [AVAsset]()
    var arrayOfTotalVideoURLs = [Any]()
    
    private var picker = UIImagePickerController()
    var shouldPop = Bool()
    var soundBank: SoundBankModel!
    var strGenreTitle = String()
    var strSavedVideoURL = String()
    var dict_PreviousVideoChunk = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getall = repo.getAll()
        print("total record \(getall?.count)")
        if let records = getall {
            for record in records {
                print("name: \(String(describing: record.name)), genre : \(String(describing: record.genre)), id: \(String(describing: record.musicGenreId)), soundid: \(String(describing: record.musicGenreSoundId))")
            }
        }
        
        showToastMessage()
        addVideoEditedFlagInFinalVideoDict()
        createDirectoryIfMandatory()
        self.perform(#selector(self.roundOffPreview), with: nil, afterDelay: 0.3)
        if (UserDefaults.standard.value(forKey: "videoCreated") as! String == "0") {
            createVideoAPIHit()
        }
        else {
            self.soundCollection.delegate = self
            self.soundCollection.dataSource = self
        }
//        for  i in 0 ..< genreModel.arr_SoundBank.count {
//            let soundBank = genreModel.arr_SoundBank[i] as! SoundBankModel
//            debugPrint("array count \(soundBank.strMusicGenreSoundName)")
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.soundCollection.reloadData()
    }

    //MARK: Create Folder In Documents_Directory
    private func createDirectoryIfMandatory() {
        
        strGenreTrimmedTitle = genreModel.strMusicGenreName.replacingOccurrences(of: " ", with: "")
        ServerTalker.sharedInstance.createGenreDirectory(strFolderName: strGenreTrimmedTitle, completion: {(dict_response, error) in
            
            if (dict_response != nil) {
                debugPrint("directory created")
            }
        })
    }
    
    //MARK: Create Video API_Hit
    private func createVideoAPIHit() {
        
        self.addLoader(withTransition: true)
        let strRequest = String(format: "%@/video", kROOT_API_URL)
        let params = NSMutableDictionary()
        params.setValue(kAPI_KEY, forKey: "apiKey")
        params.setValue(kAPI_SESSION_TOKEN, forKey: "token")
        params.setValue("1", forKey: "status")
        params.setValue(strGenreTrimmedTitle, forKey: "videoName")
        
        ServerTalker.sharedInstance.createGenreFinalVideo(strRequest: strRequest, params: params, completion: {(dict_Response, error) in
            
            self.removeLoader()
            if (dict_Response != nil) {
                let strVideoId = String(format: "%@", dict_Response!.value(forKey: "videoId") as! CVarArg)
                let strVideoName = String(format: "%@", dict_Response!.value(forKey: "videoName") as! CVarArg)
                let defaults = UserDefaults.standard
                defaults.setValue(strVideoId, forKey: "videoId")
                defaults.setValue(strVideoName, forKey: "videoName")
                defaults.setValue("1", forKey: "videoCreated")
                defaults.synchronize()
                
                self.soundCollection.delegate = self
                self.soundCollection.dataSource = self
            }
            else {
                let alert = TMAlert()
                alert.delegate = self
                alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: MSG_ERROR_OCCURRED, presenter: self)
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Round Off Layer Preview
    @objc private func roundOffPreview() {
        btnPreviewVideo.layer.cornerRadius = 10
        btnPreviewVideo.layer.masksToBounds = true
    }
    
    //MARK: Show Toast Message
    private func showToastMessage() {
        if (genreModel.arr_SoundBank.count == 0) {
            viewParent.isHidden = true
            viewToastMsg.isHidden = false
            self.btnBack.layer.cornerRadius = 10
            self.btnBack.layer.masksToBounds = true
            let strToastMessage = String(format: "There is no sound bank in %@", genreModel.strMusicGenreName)
            self.lblToast.text = strToastMessage
        }
    }
    
    //MARK: Pop Navigation
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Add Video Edited Flag in Source Dict
    private func addVideoEditedFlagInFinalVideoDict() {
        if (dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") != nil) {
            let arr_MusicGenreSoundRecA = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSArray
            let arr_MusicGenreSoundRecA_MutableCopy = arr_MusicGenreSoundRecA.mutableCopy() as! NSMutableArray
            
            for index in 0..<arr_MusicGenreSoundRecA_MutableCopy.count {
                let dict = arr_MusicGenreSoundRecA[index] as! NSDictionary
                let mutable_Copy = dict.mutableCopy() as! NSMutableDictionary
                mutable_Copy.setValue("0", forKey: "videoEditedLocally")
                arr_MusicGenreSoundRecA_MutableCopy.replaceObject(at: index, with: mutable_Copy)
            }
            
            self.dict_PreviousVideo.setValue(arr_MusicGenreSoundRecA_MutableCopy, forKey: "musicGenreSoundRecA")
        }
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genreModel.arr_SoundBank.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoundCell", for: indexPath) as! GenreCollectionCell
        
        if (genreModel.arr_SoundBank.count % 2 != 0 && indexPath.row == genreModel.arr_SoundBank.count-1)  {
           cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoundLandscapeCell", for: indexPath) as! GenreCollectionCell
        }
        
        let soundBank = genreModel.arr_SoundBank[indexPath.row] as! SoundBankModel
        
        let checkCurrent = repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
        
        let strImageURL = String(format: "%@/%@/%@-a.png", URL_GENRE_SOUND_BANK_IMAGE_ROOT, soundBank.strMusicGenreId, soundBank.strMusicGenreSoundId)
        let img_URL = URL(string: strImageURL)
        //UIImage(named: "PlaceHolder")
        cell.btnGenre.sd_setImage(with: img_URL, for: .normal, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
             cell.myIndicator.stopAnimating();
            if (error != nil) {
                let imgPlaceHolder = UIImage(named: "PlaceHolder")
                cell.btnGenre.setImage(imgPlaceHolder, for: .normal)
                
            }
            else {
                cell.btnGenre.setImage(image, for: .normal)
                if let soundId = checkCurrent?.musicGenreSoundId {
                    if (Int(soundId) == Int(soundBank.strMusicGenreSoundId)) {
                            print("name used: \(soundId)" )
                            cell.btnGenre.layer.borderWidth = 1.0
                            cell.btnGenre.layer.borderColor = UIColor.green.cgColor
                            cell.btnGenre.layer.cornerRadius = 13
                    }
                }else {
                    cell.btnGenre.layer.borderWidth = 0.0
                }
            }
        })
        
        
        cell.btnGenre.tag = indexPath.row
        cell.btnGenre.addTarget(self, action: #selector(self.btnActionGenre(btnGenre:)), for: .touchUpInside)
        
        if (genreModel.arr_SoundBank.count % 2 != 0 && indexPath.row == genreModel.arr_SoundBank.count-1) {
            
            let xAxis = (UIScreen.main.bounds.width/2) - (width/2) - 15
            let yAxis = (cell.bounds.height/2) - (height/2)
            cell.btnGenre.frame = CGRect(x: xAxis, y: yAxis, width: width, height: height)
            
        }
        else {
            let firstTrait = (UIScreen.main.bounds.size.width/2) - 45
            width = firstTrait
            height = firstTrait
        }
        
//        //TODO: check gener uploaded and add border
//        let checkCurrent = repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
//        if let soundId = checkCurrent?.musicGenreSoundId {
//            if (Int(soundId) == Int(soundBank.strMusicGenreSoundId)) {
//                print("name used: \(soundId)" )
//                cell.btnGenre.layer.borderWidth = 1.0
//                cell.btnGenre.layer.borderColor = UIColor.green.cgColor
//                cell.btnGenre.layer.cornerRadius = 13
//            }else {
//                print("no border")
//            }
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:  IndexPath) -> CGSize {
        
        let firstTrait = (UIScreen.main.bounds.size.width/2) - 15
        var returnSize = CGSize(width: firstTrait, height: firstTrait)
        if (genreModel.arr_SoundBank.count % 2 != 0 && indexPath.row == genreModel.arr_SoundBank.count-1) {
            returnSize = CGSize(width: UIScreen.main.bounds.size.width-30, height: firstTrait)
        }
        
        return returnSize
    }
    @objc private func btnActionGenre(btnGenre: UIButton) {
        
        selectedIndex = btnGenre.tag
        self.soundBank = genreModel.arr_SoundBank[btnGenre.tag] as? SoundBankModel
        //print("sound bank value \(soundBank.strMusicGenreSoundName)")
        checkIfGenreDownloaded(soundBank: soundBank)
    }
    
    //MARK: Check If Genre is Downloaded
    @objc private func checkIfGenreDownloaded(soundBank: SoundBankModel) {
        
//        let strTrimmedFileName = soundBank.strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
//        let strFilePath = String(format: "%@/%@.mov", self.strGenreTrimmedTitle,strTrimmedFileName)
//        let filePath = ServerTalker.sharedInstance.checkIfFileExistsAtPath(strFileName: strFilePath)
//        if (filePath.count == 0) {
//            self.checkIfSoundBankAlreadyExists(soundBank: soundBank, filePath: "")
//        } else {
//            self.checkIfSoundBankAlreadyExists(soundBank: soundBank, filePath: filePath)
//        }
        //MARK: delete all video
       //let repo = VideoDataRepository()
//        let result = repo.deleteRecord()
//        print("result \(result)")
//        let getall = repo.getAll()
//        print("all record detailas \(getall?.count)")
        //MARK: fetch all data from code data and check video available show message
        //let cdRepository = VideoDataRepository()
        let checkCurrent = repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
        debugPrint("selected sound \(String(describing: checkCurrent?.musicGenreSoundId))")
        if (checkCurrent != nil) {
            print("alrady data \((checkCurrent?.name)!)")
            self.checkIfSoundBankAlreadyExists(soundBank: soundBank, name: (checkCurrent?.name)!)
        }else {
            self.checkIfSoundBankAlreadyExists(soundBank: soundBank, name: "")
        }
        
//        do {
//            guard let result = try PersistentStorage.shared.context.fetch(Video.fetchRequest()) as? [Video] else {return}
//            result.forEach({debugPrint($0.name)})
//
//        } catch let error {
//            debugPrint(error)
//        }
        
        
    }

    //MARK: Check if Sound Bank Already Exists
    private func checkIfSoundBankAlreadyExists(soundBank: SoundBankModel, name: String) {
        
        if (name.isEmpty) {
            self.confirmMediaSelection(soundBank: soundBank)
            //self.pushEmptyHeroViewObject(soundBank: soundBank)
        }else {
            print("name of gener \(name)")
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
              let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("output") {
            let filePath = pathComponent.path + "/" + name + "1.mp4"
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    //debugPrint("FILE AVAILABLE")
                    //self.showAlertWith(strMessage: "Video already uploaded for this gener")
                    
                    let alertController = UIAlertController(title: nil, message: "Video already uploaded for this gener \nDo you want to upload new video?", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
                        let checkCurrent = self.repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
                        if let videoData = checkCurrent {
                           let result = self.repo.delete(record: videoData)
                            if result {
                                self.confirmMediaSelection(soundBank: soundBank)
                                //self.pushEmptyHeroViewObject(soundBank: soundBank)
                            }
                        }
                        
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(defaultAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    //print("FILE NOT AVAILABLE")
                    self.confirmMediaSelection(soundBank: soundBank)
                    //self.pushEmptyHeroViewObject(soundBank: soundBank)
                }
            }
        }
        
//        if (self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") != nil) {
//            let arr_MusicGenreSoundRecA = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
//            var dict_Genre = NSMutableDictionary()
//            var isFound = false
//            for index in 0..<arr_MusicGenreSoundRecA.count {
//                let dict = arr_MusicGenreSoundRecA[index] as! NSMutableDictionary
//                let strMusicGenreSoundId = dict.value(forKey: "musicGenreSoundId") as! String
//                if (strMusicGenreSoundId == soundBank.strMusicGenreSoundId) {
//
//                    isFound = true
//                    dict_Genre = dict
//                    break
//                }
//            }
//
//            if (isFound) {
//                self.downloadSoundBankChunk(dict_Genre: dict_Genre, filePath: filePath)
//            }
//            else {
//                //This means directory is there and file is not downloaded
//                //No Video Found At Database, Post A new Video
//                pushEmptyHeroViewObject(soundBank: soundBank)
//            }
//        }
//        else {
//            //No Video Found At Database, Post A new Video
//            pushEmptyHeroViewObject(soundBank: soundBank)
//        }
    }
    func confirmMediaSelection(soundBank: SoundBankModel) {
        let alertController = UIAlertController(title: nil, message: "Select option?", preferredStyle: .actionSheet)
        let recordAction = UIAlertAction(title: "Record Video", style: .default) { (action: UIAlertAction) in
            self.pushEmptyHeroViewObject(soundBank: soundBank)
        }
        
        let selectVideo = UIAlertAction(title: "Select Video", style: .default) { (action: UIAlertAction) in
            self.openPhotoGalleryAction()
        }
        
        
        alertController.addAction(recordAction)
        alertController.addAction(selectVideo)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func openPhotoGalleryAction() {
        
        self.perform(#selector(self.openPhotoLibraryBrowser), with: nil, afterDelay: 0.1)
        
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

//            picker.view.frame = CGRect(x: 0, y: 0, width: viewCamera.frame.size.width, height: viewCamera.frame.size.height)
//            viewCamera.addSubview(picker.view)

        }



    }
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
                 dismiss(animated: true, completion: nil)
               
                var mediaURL : URL!
                var asset: AVAsset!
                mediaURL    = (info[UIImagePickerControllerMediaURL] as? URL)!
                asset   = AVURLAsset.init(url: mediaURL! as URL)
                            
                              
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
                    
                        changeUserInteractionState(state: true)
                        if (self.shouldPop) {
                            self.popBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: self.soundBank)
                        }
                        else {
                            self.pushBeatBoxHeroViewController(mediaURL: mediaURL, asset: asset, soundModel: soundBank)
                        }
                }
    }
    
    private func changeUserInteractionState(state: Bool) {
           self.view.isUserInteractionEnabled = state
          // self.viewAnimation.isHidden = state
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
    
    
    private func downloadSoundBankChunk(dict_Genre: NSMutableDictionary, filePath: String) {
        
        if (filePath.count > 0) {
            self.beatBoxHeroController(dict_PreviousVideoChunk: dict_Genre, strMediaURL: filePath)
        }
        else {
            
            self.addLoader(withTransition: true)
            let childURL =  dict_Genre.value(forKey: "url") as! String
            let strRequestURL = String(format: "%@/%@", url_BaseUrlVideos, childURL)
            let strMusicGenreSoundId = dict_Genre.value(forKey: "musicGenreSoundId") as! String
            let strMusicGenreSoundRecId = dict_Genre.value(forKey: "musicGenreSoundRecId") as! String
            var strMusicGenreSoundName = ""
            for index in 0..<genreModel.arr_SoundBank.count {
                
                let soundBank = genreModel.arr_SoundBank[index] as! SoundBankModel
                if (strMusicGenreSoundId == soundBank.strMusicGenreSoundId) {
                    
                    strMusicGenreSoundName = String(format: "%@", soundBank.strMusicGenreSoundName)
                    strMusicGenreSoundName = strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
                    break
                }
            }
            
            let strDestination = String(format: "%@/%@.mov", self.strGenreTrimmedTitle, strMusicGenreSoundName)
            let strOrigin = String(format: "%@.mov", strMusicGenreSoundRecId)
            
            ServerTalker.sharedInstance.downloadVideoWithProgress(strVideoUrl: strRequestURL, strDestinationPath: strDestination, strOriginUrl: strOrigin, completion: {(dict_Response, error) in
                
                if (dict_Response != nil) {
                    
                    let strMediaUrl = dict_Response!.value(forKey: "mediaUrl") as! String
                    self.beatBoxHeroController(dict_PreviousVideoChunk: dict_Genre, strMediaURL: strMediaUrl)
                }
                else {
                    self.showAlertWith(strMessage: "Error occured. Please try again!")
                }
            })
        }
    }
    
    func beatBoxHeroController(dict_PreviousVideoChunk: NSMutableDictionary, strMediaURL: String) {
        
        self.removeLoader()
        let beatBoxBoard = UIStoryboard(name: "BeatBoxBoard", bundle: nil)
        let controllerBeatBox = beatBoxBoard.instantiateViewController(withIdentifier: "BeatBoxHeroViewController") as! BeatBoxHeroViewController
        controllerBeatBox.dict_PreviousVideoChunk = dict_PreviousVideoChunk
        controllerBeatBox.musicIndex = selectedIndex
        controllerBeatBox.strGenreTitle = genreModel.strMusicGenreName
        controllerBeatBox.strSavedVideoURL = strMediaURL
        
        let mediaURL = URL(fileURLWithPath: strMediaURL)
        controllerBeatBox.mediaURL = mediaURL
        
        let soundBank = genreModel.arr_SoundBank[selectedIndex] as! SoundBankModel
        controllerBeatBox.soundModel = soundBank
        controllerBeatBox.delegate = self
        self.navigationController?.pushViewController(controllerBeatBox, animated: true)
    }
    
    func pushEmptyHeroViewObject(soundBank: SoundBankModel) {
        
        let dict_Genre = NSMutableDictionary()
        dict_Genre.setValue(soundBank.strMusicGenreSoundId, forKey: "musicGenreSoundId")
        dict_Genre.setValue("0", forKey: "videoEditedLocally")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let strTrimmedFileName = soundBank.strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
        let strPath = String(format: "%@/%@/%@.mov", path as CVarArg,self.strGenreTrimmedTitle,strTrimmedFileName)
        
        let beatBoxBoard = UIStoryboard(name: "BeatBoxCameraBoard", bundle: nil)
        let cameraBeatBox = beatBoxBoard.instantiateViewController(withIdentifier: "BeatBoxCameraViewController") as! BeatBoxCameraViewController
        cameraBeatBox.delegate = self
        cameraBeatBox.soundBank = soundBank
        cameraBeatBox.strGenreTitle = genreModel.strMusicGenreName
        cameraBeatBox.strSavedVideoURL = strPath
        cameraBeatBox.soundBank = soundBank
        cameraBeatBox.dict_PreviousVideoChunk = dict_Genre
        cameraBeatBox.musicIndex = selectedIndex
        self.navigationController?.pushViewController(cameraBeatBox, animated: true)
    }
    
    //MARK: BeatBox Camera ViewController Delegate
    func beatBoxCameraViewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int) {
        
        mutuallyRespondedDelegateProcessing(musicDict: musicDict, withIndex: musicIndex)
    }

    //MARK: BeatBox Hero ViewController Delegate
    func beatBoxVideoPreviewControllerDidRespondedWith(musicDict: NSMutableDictionary, withIndex musicIndex: Int) {
        
        mutuallyRespondedDelegateProcessing(musicDict: musicDict, withIndex: musicIndex)
    }
    
    private func mutuallyRespondedDelegateProcessing(musicDict: NSMutableDictionary, withIndex musicIndex: Int) {
        
        let path =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let strVideoPath = String(format: "%@/%@.mov", path as CVarArg, strGenreTrimmedTitle)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: strVideoPath)){
            try? fileManager.removeItem(atPath: strVideoPath)
        }
        
        if (self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") != nil) {
            let arr_MusicGenreSoundRecA = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
            
            var isFound = false
            let strMusicGenreSoundId_Edited = musicDict.value(forKey: "musicGenreSoundId") as! String
            for index in 0..<arr_MusicGenreSoundRecA.count {
                let dict = arr_MusicGenreSoundRecA[index] as! NSMutableDictionary
                let strMusicGenreSoundId_Existing = dict.value(forKey: "musicGenreSoundId") as! String
                if (strMusicGenreSoundId_Edited == strMusicGenreSoundId_Existing) {
                    
                    isFound = true
                    arr_MusicGenreSoundRecA.replaceObject(at: musicIndex, with: musicDict)
                    self.dict_PreviousVideo.setValue(arr_MusicGenreSoundRecA, forKey: "musicGenreSoundRecA")
                    break
                }
            }
            
            if !(isFound) {
                arr_MusicGenreSoundRecA.add(musicDict)
                self.dict_PreviousVideo.setValue(arr_MusicGenreSoundRecA, forKey: "musicGenreSoundRecA")
            }
        }
        else {
            let arr_MusicGenreSoundRecA = NSMutableArray()
            arr_MusicGenreSoundRecA.add(musicDict)
            self.dict_PreviousVideo.setValue(arr_MusicGenreSoundRecA, forKey: "musicGenreSoundRecA")
        }
    }
    
    //MARK: Btn Action Preview All Video
    @IBAction func btnActionPreviewVideo(_ sender: UIButton) {
        
        print("click create video")
        
//        if (self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") == nil) {
//
//            self.showAlertWith(strMessage: MSG_UPLOAD_VIDEO)
//            return
//        }
//        if arr_JoiningSequenceA.count == 0 {
//            self.showAlertWith(strMessage: MSG_NOTSEQUENCEGENRE)
//            return
//        }
//        var isVideoModified = false
//        let arr_VideoGenres = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
//        if (arr_VideoGenres.count < 5) {
//            self.showAlertWith(strMessage: MSG_NOT_ENOUGH_GENRE)
//            return
//        }
//
//        for index in 0..<arr_VideoGenres.count {
//            let dict = arr_VideoGenres[index] as! NSMutableDictionary
//            let videoEditedLocally = dict.value(forKey: "videoEditedLocally") as! String
//            if (videoEditedLocally == "1") {
//
//                isVideoModified = true
//                break
//            }
//        }
//
//        if (isVideoModified) {
//            self.removeLocallySavedMergedVideo()
//        }
//        else {
//            self.perform(#selector(startLoader), on: .main, with: nil, waitUntilDone: true)
//        }
        
        
        //let videoRepo = VideoDataRepository()
        //check all gener video available
        trimVideoArray.removeAll();
        var video_array = [Video]()
        for index in 0 ..< genreModel.arr_SoundBank.count {
            let soundBank = genreModel.arr_SoundBank[index] as! SoundBankModel
            let videoData = repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
            if let data = videoData {
                video_array.append(data)
            }
            
        }
        //print("video file array \(video_array.count)")
        if(video_array.count == genreModel.arr_SoundBank.count) {
            self.trimAndUpdateVideo(video_array: video_array)
        }else {
            self.showAlertWith(strMessage: MSG_UPLOAD_VIDEO)
        }
        
    }
    
    private func trimAndUpdateVideo(video_array: [Video]) {
//        var filePath_array = [URL]()
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        if let pathComponent = url.appendingPathComponent("output") {
//            for index in 0 ..< video_array.count {
//                let filePathURL = pathComponent.appendingPathComponent("/\(video_array[index].name!)")
//                let filePath = filePathURL.path
//                let fileManager = FileManager.default
//                if fileManager.fileExists(atPath: filePath) {
//                    let url = NSURL(fileURLWithPath: filePath)
//                    filePath_array.append(url as URL)
//                }
//            }
//        }else {
//            self.showAlertWith(strMessage: MSG_UPLOAD_VIDEO)
//        }
        
        self.addLoader(withTransition: true)
        // MARK:- Brack video according to JSON Frame
        //DispatchQueue.main.async {
            self.splitVideoAccordingToJson(video_array: video_array, completion: {(sucess) -> Void in
                if (sucess) {
                    
//                    let timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { (timer) in
//                                    print("delayed message")
//                                }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        // your code here
                        self.mergeVideo(trimVideos: self.trimVideoArray, video_array: video_array);
                    }
                    
                }
            })
        //}
//        DispatchQueue.main.async{/
//
//            print("inside closer")
//            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer) in
//                print("delayed message")
//            }
//            self.mergeVideo(video_array: video_array)
//        }
        
    }
    //MARK:- split video defination
    func splitVideoAccordingToJson(video_array:[Video] , completion: (_ success: Bool) -> Void) {
          let collectionService = GenreCollectionService()
          let playList = collectionService.getPlayList()
          //print("play List ", playList)
          for item in playList {
              var selectedVideo = Video()
              let startTime: Float = 0
              let endtime: Float = ((item.time) as NSString).floatValue
              let genreSoundId = item.strMusicGenreSoundId
              
              for video in video_array {
                  if(video.musicGenreSoundId == genreSoundId) {
                      selectedVideo = video
                      break;
                  }
              }
              //print("video selected \(selectedVideo)  start time \(startTime), end time \(endtime) ")
              let url = NSURL(fileURLWithPath: selectedVideo.videoData!)
              //print("saved video url : \(url)" )
              //DispatchQueue.main.async {
              self.cropVideo(sourceURL1: url, startTime: startTime, endTime: endtime, soundModel: selectedVideo)
                print("video trimmed ");
             // }
              
          }
        
        completion(true)
          
      }
    
    
    //MARK:- merge video
    private func mergeVideo(trimVideos:[URL], video_array:[Video]) {
       
//        print("count \(video_array.count)")
//        print("genre aray count \(self.genreModel.arr_SoundBank.count)")
//        var trimVideoArray = [URL]()
//        for index in 0 ..< self.genreModel.arr_SoundBank.count {
//            let soundBank = self.genreModel.arr_SoundBank[index] as! SoundBankModel
//            let videourl = repo.getVideoBySubGener(musicGenreSoundId: soundBank.strMusicGenreSoundId)
//            print("video video url : \(videourl!.videoData!)")
//            if let data = videourl {
//                let url = URL(fileURLWithPath: data.videoData!)
//                trimVideoArray.append(url)
//            }
//        }
        print("trimming video data \(trimVideoArray)")
        DPVideoMerger().mergeVideos(withFileURLs: trimVideos) { (_ mergedVideoFile: URL?,  _ error: Error?) in

            if error != nil {
                self.removeLoader()
                let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (a) in
                }))
                self.present(alert, animated: true) {() -> Void in }
                return
            }
            self.removeLoader()
            print("mergerd file url \(String(describing: mergedVideoFile))")
            //MARK: Navigate to another screen
            var asset: AVAsset!
            asset   = AVURLAsset.init(url: mergedVideoFile! as URL)
            self.pushBeatBoxHeroViewController(mediaURL: mergedVideoFile!, asset: asset, video_array: video_array)

        }
        
    }
    
    //MARK:- crop video
    //Trim Video Function
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float, soundModel : Video)
    {
        let manager = FileManager.default
        var asset: AVAsset!
        
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
           let url = NSURL(fileURLWithPath: path)
           if let pathComponent = url.appendingPathComponent("output") {
            let filePathURL = pathComponent.appendingPathComponent("/\(sourceURL1.lastPathComponent!)")
               let filePath = filePathURL.path
               let fileManager = FileManager.default
                //print("FILE AVAILABLE \(filePath)")
               if fileManager.fileExists(atPath: filePath) {
                   //print("FILE AVAILABLE \(filePath)")
                let url = NSURL(fileURLWithPath: filePath)
                //print("file path \(url)")
                asset = AVURLAsset.init(url: url as URL)
               } else {
                   print("FILE NOT AVAILABLE")
               }
           } else {
               print("FILE PATH NOT AVAILABLE")
           }
        
        
        
        //print("asset value \(asset.duration.value)")
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            //print("trim video  length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            //print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("update")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                let soundGenerName = soundModel.name!
                //debugPrint("sound name \(soundGenerName)")
                outputURL = outputURL.appendingPathComponent("\(soundGenerName)Update1.mp4")
                //print("output video name : \(outputURL)")
            }catch let error {
                print("this is error: \(error)")
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
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    //DispatchQueue.main.async {
                        print("exported at \(outputURL)")
                    self.trimVideoArray.append(outputURL)
                       // _ = self.saveToCameraRoll(URL: outputURL as NSURL?, soundModel: soundModel)
                    //}
                    
                    //self.saveVideoToDocumentedDirectory(outputURL: outputURL)
                case .failed:
                    print("failed:: \(exportSession.error)")

                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")

                default: break
                }
                
            }
            
        }
        
    }
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!,soundModel: Video)-> Bool {
            
        soundModel.videoData = "\(String(describing: URL!))"
        //let repository = VideoDataRepository()
        let result = repo.update(data: soundModel)
                print("update Result \(result)")
        return result
        }
    
    //MARK: send to preview Merge screen
    @objc private func pushBeatBoxHeroViewController(mediaURL: URL, asset: AVAsset, video_array: [Video]) {
           let beatBoxHeroBoard = UIStoryboard(name: "BeatBoxBoard", bundle: nil)
           let beatBoxHeroViewController = beatBoxHeroBoard.instantiateViewController(withIdentifier: "BeatBoxHeroViewController") as! BeatBoxHeroViewController
           beatBoxHeroViewController.delegate = self
           beatBoxHeroViewController.shouldPostNewVideo = true
           beatBoxHeroViewController.mediaURL = mediaURL
           beatBoxHeroViewController.asset = asset
           beatBoxHeroViewController.mergerVideo = true
        beatBoxHeroViewController.video_array = video_array
           self.navigationController?.pushViewController(beatBoxHeroViewController, animated: true)
       }
    
    @objc private func startLoader() {
        self.addLoader(withTransition: true)
        self.perform(#selector(self.getAllVideoGenresFromDocumentDirectory), with: nil, afterDelay: 0.3)
    }
    
    @objc private func getAllVideoGenresFromDocumentDirectory() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            
            let strGenreFile = String(format: "%@%@", documentsURL as CVarArg, self.strGenreTrimmedTitle)
            let genreURL = URL(string: strGenreFile)!
            let fileURLs = try fileManager.contentsOfDirectory(at: genreURL, includingPropertiesForKeys: nil)
            
            let arr_URLS = fileURLs as NSArray
            let arr_MutableFileURLs = arr_URLS.mutableCopy() as! NSMutableArray
            if (arr_MutableFileURLs.count>0) {
                
                for url_index in stride(from: arr_MutableFileURLs.count-1, to: -1, by: -1) {
                    let url_video = arr_MutableFileURLs[url_index] as! URL
                    let strAbsoluteURL = url_video.absoluteString
                    if (strAbsoluteURL.contains(".DS_Store")) {
                        arr_MutableFileURLs.removeObject(at: url_index)
                    }
                }
            }
            
            let arr_VideoGenres = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
            //===
            var dataNeedTodownload = false
            for index in 0..<arr_VideoGenres.count {
                let data : NSDictionary = arr_VideoGenres[index] as! NSDictionary
                if data.value(forKey: "mediaUrl") == nil {
                    dataNeedTodownload = true;
                    break;
                }
            }
            //===
            if ((arr_MutableFileURLs.count == genreModel.arr_SoundBank.count || arr_MutableFileURLs.count == arr_VideoGenres.count) && !dataNeedTodownload){
                
                var arrClips: [AVAsset] = []
                for index in 0..<arr_MutableFileURLs.count {
                    let MediaURL = arr_MutableFileURLs[index] as! URL
                    let videoAsset = AVAsset(url: MediaURL)
                    arrClips.append(videoAsset)
                }
                self.mergeVideosUsingDPVideoMerger(arr_FileURLs: arr_MutableFileURLs)
            }
            else {
                seperateOutRequestedVideos(fileURLs: arr_MutableFileURLs)
            }
        }
        catch {
            debugPrint("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            self.removeLoader()
            self.showAlertWith(strMessage: "Error Occurred. Please try again!!!")
        }
    }
    
    @objc private func seperateOutRequestedVideos(fileURLs: NSMutableArray) {
        
        if (fileURLs.count == 0) {
            let arr_MusicGenreSoundRecA = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
            for index in 0..<arr_MusicGenreSoundRecA.count {
                let dict = arr_MusicGenreSoundRecA[index] as! NSDictionary
                let checkIfVideoIsModified = dict.value(forKey: "videoEditedLocally") as! String
                if (checkIfVideoIsModified == "0") {
                    self.arr_DownloadRequests.add(dict)
                }
            }
            self.recursiveCount = 0
            self.downloadVideoChunksToBeMerged()
        }
        else {
            //FIXME:: //check which videos need downloading
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let finalPath = String(format: "%@/%@/", path,strGenreTrimmedTitle)
            
            for index in 0..<fileURLs.count {
                let url_VideoDownloadedFile = fileURLs[index] as! URL
                var absoluteString = url_VideoDownloadedFile.absoluteString
                absoluteString = absoluteString.replacingOccurrences(of: finalPath, with: "")
                absoluteString = absoluteString.replacingOccurrences(of: "file://", with: "")
                absoluteString = absoluteString.replacingOccurrences(of: ".mov", with: "")
                for betaIndex in 0..<genreModel.arr_SoundBank.count {
                    let soundBank = genreModel.arr_SoundBank[betaIndex] as! SoundBankModel
                    
                    let strTrimmedFileName = soundBank.strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
                    if (strTrimmedFileName == absoluteString) {
                        soundBank.alreadyDownloaded = true
                        genreModel.arr_SoundBank[betaIndex] = soundBank
                        break
                    }
                }
            }
            
            let arr_MusicGenreSoundRecA = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
            for betaIndex in 0..<genreModel.arr_SoundBank.count {
                let soundBank = genreModel.arr_SoundBank[betaIndex] as! SoundBankModel
                if (!soundBank.alreadyDownloaded) {
                    for omegaIndex in 0..<arr_MusicGenreSoundRecA.count {
                        let dict = arr_MusicGenreSoundRecA[omegaIndex] as! NSDictionary
                        let musicGenreSoundId = dict.value(forKey: "musicGenreSoundId") as! String
                        if (musicGenreSoundId == soundBank.strMusicGenreSoundId) {
                            self.arr_DownloadRequests.add(dict)
                        }
                    }
                }
            }
            
            self.recursiveCount = 0
            self.downloadVideoChunksToBeMerged()
        }
    }
    
    @objc private func downloadVideoChunksToBeMerged() {
        
        if (self.recursiveCount == arr_DownloadRequests.count) {
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                
                let strGenreFile = String(format: "%@%@", documentsURL as CVarArg, self.strGenreTrimmedTitle)
                let genreURL = URL(string: strGenreFile)!
                let fileURLs = try fileManager.contentsOfDirectory(at: genreURL, includingPropertiesForKeys: nil)
                
                let arr_URLS = fileURLs as NSArray
                let arr_MutableFileURLs = arr_URLS.mutableCopy() as! NSMutableArray
                if (arr_MutableFileURLs.count>0) {
                    
                    for url_index in stride(from: arr_MutableFileURLs.count-1, to: -1, by: -1) {
                        let url_video = arr_MutableFileURLs[url_index] as! URL
                        let strAbsoluteURL = url_video.absoluteString
                        if (strAbsoluteURL.contains(".DS_Store")) {
                            arr_MutableFileURLs.removeObject(at: url_index)
                        }
                    }
                }
                
                var arrClips: [AVAsset] = []
                for gama_Index in 0..<arr_MutableFileURLs.count {
                    let MediaURL = arr_MutableFileURLs[gama_Index] as! URL
                    let videoAsset = AVAsset(url: MediaURL)
                    arrClips.append(videoAsset)
                }
                
                self.mergeVideosUsingDPVideoMerger(arr_FileURLs: arr_MutableFileURLs)
            }
            catch {
                debugPrint("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
                self.removeLoader()
                self.showAlertWith(strMessage: "Error Occurred. Please try again!!!")
            }
        }
        else {
            
            let dict_Genre = arr_DownloadRequests[self.recursiveCount] as! NSDictionary
            let childURL =  dict_Genre.value(forKey: "url") as! String
            let strRequestURL = String(format: "%@/%@", url_BaseUrlVideos, childURL)
            let strMusicGenreSoundId = dict_Genre.value(forKey: "musicGenreSoundId") as! String
            let strMusicGenreSoundRecId = dict_Genre.value(forKey: "musicGenreSoundRecId") as! String
            var strMusicGenreSoundName = ""
            for index in 0..<genreModel.arr_SoundBank.count {
                
                let soundBank = genreModel.arr_SoundBank[index] as! SoundBankModel
                if (strMusicGenreSoundId == soundBank.strMusicGenreSoundId) {
                    strMusicGenreSoundName = String(format: "%@", soundBank.strMusicGenreSoundName)
                    strMusicGenreSoundName = strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
                    break
                }
            }

            let strDestination = String(format: "%@/%@.mov", strGenreTrimmedTitle,strMusicGenreSoundName)
            
            let strOrigin = String(format: "%@.mov", strMusicGenreSoundRecId)
            
            ServerTalker.sharedInstance.downloadVideoWithProgress(strVideoUrl: strRequestURL, strDestinationPath: strDestination, strOriginUrl: strOrigin, completion: {(dict_Response, error) in
                
                self.recursiveCount += 1
                debugPrint(self.recursiveCount)
                self.downloadVideoChunksToBeMerged()
            })
        }
    }
    
    private func mergeDownloadedChunks(arrClips: [AVAsset]) {
        KVVideoManager.shared.mergeWithAnimation(arrayVideos: arrClips) { [weak self] (outputURL, error) in
            guard let aSelf = self else {
                return
            }
            
            if let error = error {
                aSelf.removeLoader()
                aSelf.showAlertWith(strMessage: "Error Occured. Please try again!")
                debugPrint("Error:\(error.localizedDescription)")
            }
            else {
                if let url = outputURL {
                    aSelf.getVideoURL(url)
                }
            }
        }
    }
    
    private func mergeVideosUsingDPVideoMerger(arr_FileURLs: NSMutableArray) {
        
        let path =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let strVideoPath = String(format: "%@/%@.mov", path as CVarArg, strGenreTrimmedTitle)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: strVideoPath)){
            
            let mergedVideoFile = URL(fileURLWithPath: strVideoPath)
            self.getVideoURL(mergedVideoFile)
        }
        else {
            UserDefaults.standard.setValue(strVideoPath, forKey: "strVideoPath")
            UserDefaults.standard.synchronize()

            DispatchQueue.main.async {
                let toast =   Toast(text: "Approx 1-2 min required to check video", duration: 180)
                toast.show()
            }
            debugPrint("Start Time : \( Date())");

            self.getFinalArrayAfterCropToMerge(storedVideoURLs: arr_FileURLs);
            NotificationCenter.default.addObserver(self, selector: #selector (SoundBankViewController.finalMergingVideo) , name: Notification.Name("completertask"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector (SoundBankViewController.failedMergingVideo) , name: Notification.Name("Failedtask"), object: nil)

/*
            let arr_SortedGenres = reArrangeVideosOrder(arr_FileURLs: arr_FileURLs)
            DPVideoMerger().mergeVideos(withFileURLs: arr_SortedGenres as! [URL], completion: {(_ mergedVideoFile: URL?, _ error: Error?) -> Void in
                
                if error != nil {
                    let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    self.present(alert, animated: true) {() -> Void in }
                    return
                }
                
                self.getVideoURL(mergedVideoFile!)
            })
*/
        }
    }
    
    private func reArrangeVideosOrder(arr_FileURLs: NSArray) -> NSMutableArray {
        
        let arr_SortedURLs = NSMutableArray()
        if (genreModel.arr_JoiningSequence.count > 0) {
            //Sequence Given
            
            for rawIndex in 0..<genreModel.arr_JoiningSequence.count {
                let strProvidedIndex = String(format: "%@", genreModel.arr_JoiningSequence[rawIndex] as! CVarArg)
                
                for betaIndex in 0..<genreModel.arr_SoundBank.count {
                    let soundBank = genreModel.arr_SoundBank[betaIndex] as! SoundBankModel
                    if (soundBank.strMusicGenreSoundId == strProvidedIndex) {
                        
                        for index in 0..<arr_FileURLs.count {
                            let MediaURL = arr_FileURLs[index] as! URL
                            let strMediaURL = MediaURL.absoluteString
                            
                            let strTrimmedGenreSoundName = soundBank.strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
                            if (strMediaURL.contains(strTrimmedGenreSoundName)) {
                                arr_SortedURLs.add(MediaURL)
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
        else {
            
            //Sequence Not Given Arrange Alphabattically
            for betaIndex in 0..<genreModel.arr_SoundBank.count {
                let soundBank = genreModel.arr_SoundBank[betaIndex] as! SoundBankModel
                for index in 0..<arr_FileURLs.count {
                    let MediaURL = arr_FileURLs[index] as! URL
                    let strMediaURL = MediaURL.absoluteString
                    
                    let strTrimmedGenreSoundName = soundBank.strMusicGenreSoundName.replacingOccurrences(of: " ", with: "")
                    if (strMediaURL.contains(strTrimmedGenreSoundName)) {
                        arr_SortedURLs.add(MediaURL)
                    }
                }
            }
        }
        
        return arr_SortedURLs
    }

    private func getVideoURL(_ videoURL:URL) {
        
        UserDefaults.standard.removeObject(forKey: "strVideoPath")
        UserDefaults.standard.synchronize()
        self.removeLoader()
        sendMergedVideoURLToHeroController(strFinalVideoURL: videoURL.absoluteString)
    }
    
    func sendMergedVideoURLToHeroController(strFinalVideoURL: String) {
        let beatBoxBoard = UIStoryboard(name: "BeatBoxBoard", bundle: nil)
        let controllerBeatBox = beatBoxBoard.instantiateViewController(withIdentifier: "BeatBoxHeroViewController") as! BeatBoxHeroViewController
        controllerBeatBox.strSavedVideoURL = strFinalVideoURL
        controllerBeatBox.strGenreTitle = genreModel.strMusicGenreName
        controllerBeatBox.isFinalVideoPreview = true
        controllerBeatBox.delegate = self
        controllerBeatBox.totalTimeOfSeq =  String(format: "%.2f", totalTimeOfVideoSholdBe)
        self.navigationController?.pushViewController(controllerBeatBox, animated: true)
    }
    
    private func removeLocallySavedMergedVideo() {
        let path =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let strVideoPath = String(format: "%@/%@.mov", path as CVarArg, strGenreTrimmedTitle)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: strVideoPath)){
            try? fileManager.removeItem(atPath: strVideoPath)
        }
        self.perform(#selector(startLoader), on: .main, with: nil, waitUntilDone: true)
    }
    
    //MARK: Show Alert With Delegate Methods Implementation
    private func showAlertWith(strMessage: String) {
        let alert = TMAlert()
        alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: strMessage, presenter: self)
    }
    
    func alertOkBtnDidResponded(){
        self.navigationController?.popViewController(animated: true)
    }
    func alertCancelBtnDidResponded(){}
    func alertSingleOkBtnDidResponded(){}

    // MARK:- CHANGES BY ABUBAKER

    @objc private func failedMergingVideo () -> Void {

        let errorMessage = "\(MSG_Mergingfailed)"
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        self.present(alert, animated: true) {() -> Void in }
        self.removeCreatedVideoChunks(finalAToRemove: arrayOfTotalVideo);
        ToastCenter.default.cancelAll()
        debugPrint("End Time : \( Date()) Failed Merging")
        return

    }
    @objc private func finalMergingVideo () -> Void {
        // debugPrint("Final array for merging : \(arrayOfTotalVideo)")
        let divdedAOfTotalVideos = arrayOfTotalVideo.chunked(by: chunkedAForMergingBy)
        self.chunksMerging(dividedTotalA: divdedAOfTotalVideos, currentIndex: 0)



    }
    private func chunksMerging (dividedTotalA : [[AVAsset]] , currentIndex : Int) -> Void {

        if (currentIndex == dividedTotalA.count){
            let chunkedVideoA  = self.arr_joiningVideoChunks as Array
            let divdedAOfTotalVideos = chunkedVideoA.chunked(by: chunkedAForMergingBy)
            self.arr_joiningVideoChunks.removeAllObjects()
            self.chunksMerging(dividedTotalA: divdedAOfTotalVideos as! [[AVAsset]], currentIndex: 0)
           // debugPrint("================== getting new array ");
        }else{
            let finalA = dividedTotalA[currentIndex];
           // debugPrint("================== calling merging ");
            KVVideoManager.shared.mergeCustom(arrayVideos: finalA, isFinalVideo: dividedTotalA.count == 1) { (
                _ mergedVideoFile: URL?, _ error: Error?) -> Void in

                //  debugPrint("new url from tmp\(String(describing: mergedVideoFile))")
                if error != nil {
                    let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    self.present(alert, animated: true) {() -> Void in }
                    return
                }
                if (dividedTotalA.count == 1){
                    debugPrint("End Time : \( Date())")
                    ToastCenter.default.cancelAll()
                    DispatchQueue.main.async {
                        self.removeCreatedVideoChunks(finalAToRemove: self.arrayOfTotalVideoURLs);
                    }
                    self.getVideoURL(mergedVideoFile!)
                } else {
                    self.arrayOfTotalVideo.append(AVAsset.init(url: mergedVideoFile ?? NSURL.init() as URL))
                    self.arr_joiningVideoChunks.add( AVAsset.init(url: mergedVideoFile ?? NSURL.init() as URL));
                    self.chunksMerging(dividedTotalA: dividedTotalA , currentIndex: currentIndex + 1)
                }
            }

        }
    }
    private func removeCreatedVideoChunks ( finalAToRemove : [Any]) {
        let fileManager = FileManager.default
        for  data in arrayOfTotalVideoURLs {
            let assetURL = data as! NSURL
            var urlPath : String = assetURL.absoluteString ?? ""
            urlPath = urlPath.replacingOccurrences(of: "file://", with: "")
            if (fileManager.fileExists(atPath: urlPath)){
                try? fileManager.removeItem(atPath: urlPath)
            }
        }
        clearTmpDirectory(stringNotToDeleted: "mergedVideo.mp4");
    }
    func clearTmpDirectory(stringNotToDeleted : String) {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                if file != stringNotToDeleted {
                    let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                    try FileManager.default.removeItem(atPath: path)
                }

            }
        } catch {
            debugPrint(error)
        }
    }
    func getFinalArrayAfterCropToMerge(storedVideoURLs : NSMutableArray){

        arrayOfTotalVideo = [AVAsset]()
        arrayOfTotalVideoURLs = [Any]()
        totalTimeOfVideoSholdBe = 0;
        let arr_VideoGenres = self.dict_PreviousVideo.value(forKey: "musicGenreSoundRecA") as! NSMutableArray
        self.setLocalDataInPreVideoDict(arr_VideoGenres: arr_VideoGenres, storedVideoURLs: storedVideoURLs)
        self.recursiveCalling(currentIndex: 0 , totalCount: arr_JoiningSequenceA.count, arr_VideoGenres: arr_VideoGenres, arr_storedVideo: storedVideoURLs)
    }
    func setLocalDataInPreVideoDict (arr_VideoGenres : NSMutableArray , storedVideoURLs : NSMutableArray)  {

        //now we will check local data available here
        for index in 0..<genreModel.arr_SoundBank.count {
            let soundObject : SoundBankModel  = genreModel.arr_SoundBank[index] as! SoundBankModel
            let musicGenreSoundIdPredicate = NSPredicate(format: "musicGenreSoundId = %@",soundObject.strMusicGenreSoundId);
            let filteredArray = arr_VideoGenres.filter { musicGenreSoundIdPredicate.evaluate(with: $0) };
            if filteredArray.count > 0 {
                // we have object avialble with same sound id
                let dictToEmbedMediaURL : NSMutableDictionary = filteredArray[0] as! NSMutableDictionary
                let indexToAdd  =  arr_VideoGenres.index(of: dictToEmbedMediaURL)
                if dictToEmbedMediaURL.value(forKey: "mediaUrl") != nil {
                    continue;
                }else{

                    var stringToFind : String = soundObject.strMusicGenreSoundName
                    stringToFind  = stringToFind.replacingOccurrences(of: " ", with: "");
                    let searchLocalURLPridicate = NSPredicate(format: "absoluteString Contains[cd] %@",stringToFind)
                    let filteredURLArray = storedVideoURLs.filter { searchLocalURLPridicate.evaluate(with: $0) };
                    if filteredURLArray.count > 0 {
                        let mediaURlLocal : NSURL = filteredURLArray[0] as! NSURL;
                        let finalStrToaddInDict  = mediaURlLocal.absoluteString?.replacingOccurrences(of: "file://", with: "") ?? mediaURlLocal.absoluteString
                        dictToEmbedMediaURL.setValue(finalStrToaddInDict, forKey: "mediaUrl")
                    }
                    arr_VideoGenres.replaceObject(at: indexToAdd, with: dictToEmbedMediaURL)
                }
            }
        }
        // now assign back new array to dict _ previous video with media local url
        self.dict_PreviousVideo.setValue(arr_VideoGenres, forKey: "musicGenreSoundRecA")


    }
    func recursiveCalling(currentIndex : Int , totalCount : Int  ,  arr_VideoGenres : NSMutableArray , arr_storedVideo : NSMutableArray) -> Void {

        if currentIndex == totalCount {
            NotificationCenter.default.post(name: Notification.Name("completertask"), object: nil)
            NotificationCenter.default.removeObserver(self)
            return;
        }else{

            let sequenceObj : JoiningSequenceModel = arr_JoiningSequenceA[currentIndex] as! JoiningSequenceModel
            let musicGenreSoundIdPredicate = NSPredicate(format: "musicGenreSoundId = %@",sequenceObj.musicGenreSoundId);
            let filteredArray = arr_VideoGenres.filter { musicGenreSoundIdPredicate.evaluate(with: $0) };
            if filteredArray.count > 0 {
                let dataDict  = filteredArray[0] as! NSDictionary
                if dataDict.value(forKey: "mediaUrl") == nil {
//                    debugPrint("====================local URL not found logic to set local url to merge failed===============")
                    NotificationCenter.default.post(name: Notification.Name("Failedtask"), object: nil)
                    NotificationCenter.default.removeObserver(self)
                }else{
                    let mediaURLStr : String = "file://"  + (dataDict.value(forKey: "mediaUrl") as! String)
                    let MediaURL : URL = URL.init(string: mediaURLStr)!
                    totalTimeOfVideoSholdBe = totalTimeOfVideoSholdBe + sequenceObj.time
                    KVVideoManager.shared.cropVideo(sourceURL: MediaURL , startTime: 0, endTime: sequenceObj.time) { (finalCropURL) in
                        // check url length for its validity
                        if finalCropURL.absoluteString.count > 10 {
                            let videoAsset = AVAsset(url: finalCropURL)
                            self.arrayOfTotalVideo.append(videoAsset)
                            self.arrayOfTotalVideoURLs.append(finalCropURL)
                        }
                        self.recursiveCalling(currentIndex: currentIndex + 1 , totalCount: totalCount, arr_VideoGenres: arr_VideoGenres, arr_storedVideo: arr_storedVideo)
                    }
                }
            }else{
                recursiveCalling(currentIndex: currentIndex + 1 , totalCount: totalCount, arr_VideoGenres: arr_VideoGenres, arr_storedVideo: arr_storedVideo)
            }
        }

    }

}
