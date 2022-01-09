//
//  ViewController.swift
//  MergeVideos
//
//  Created by Khoa Vo on 12/20/17.
//  Copyright © 2017 Khoa Vo. All rights reserved.
//

import UIKit
import AVKit
//import DKImagePickerController
import Photos
import SDWebImage
import Alamofire
import Kingfisher

class SelectGenreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var labelProcessing: UILabel!
    @IBOutlet weak var buttonMergeVideosImages: UIButton!
    
    @IBOutlet weak var collectionGenre: UICollectionView!
    var arr_GenreTypes = NSMutableArray()
    var arr_Videos = NSMutableArray()
    var strSelectedType = ""
    var dict_PreviousVideo = NSMutableDictionary()
    var arr_ProvidedSequence = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.set("1", forKey: "videoCreated")
//        UserDefaults.standard.set("38", forKey: "videoId")
//        UserDefaults.standard.synchronize()
        
        self.checkIfVideoCreated()
        self.collectionGenre.delegate = self
        self.collectionGenre.dataSource = self
        self.addLoader(withTransition: true)
        self.initiateServerTalkerToGetGenre()
    }

    @objc private func checkIfVideoCreated() {
        
        let defaults = UserDefaults.standard
        defaults.synchronize()
        if(defaults.value(forKey: "videoCreated") == nil) {
            defaults.setValue("0", forKey: "videoCreated")
        }
        defaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initiateServerTalkerToGetGenre() {
        
        ServerTalker.sharedInstance.fetchAppConfigurations { (dataDict, error) in
            
            if (dataDict != nil) {
                
                URL_GENRE_IMAGE_ROOT = dataDict!.value(forKey: "baseUrlMusicGenreImages") as! String
                URL_GENRE_SOUND_BANK_IMAGE_ROOT = dataDict!.value(forKey: "baseUrlMusicGenreSoundImages") as! String
                url_BaseUrlVideos = dataDict!.value(forKey: "baseUrlVideos") as! String
                
                let arr_MusicGenre = dataDict!.value(forKey: "musicGenreA") as! NSArray
                for index in 0..<arr_MusicGenre.count {
                    let dict = arr_MusicGenre[index] as! NSDictionary
                    let genreModel = GenreModel(info: dict)
                    self.arr_GenreTypes.add(genreModel)
                }
                
                if (UserDefaults.standard.value(forKey: "videoCreated") as! String == "1") {
                    self.getPreviousUploadedVideo()
                }
                else {
                    self.removeLoader()
                    self.collectionGenre.reloadData()
                }
            }
            else {
                self.removeLoader()
                self.showAlertWith(strMessage: MSG_ERROR_OCCURRED)
            }
        }
    }
    
    private func showAlertWith(strMessage: String) {
        let alert = TMAlert()
        alert.showTMSingleOkAlertWith(Title: kAPP_NAME, message: strMessage, presenter: self)
    }
    
    //MARK: Get Previous Uploaded Video
    private func getPreviousUploadedVideo() {
        let videoId = String(format: "%@", UserDefaults.standard.value(forKey: "videoId") as! CVarArg)
        ServerTalker.sharedInstance.fetchPreviousVideo(strVideoId: videoId, completion: { (dataDict, error) in
            
            if (dataDict != nil) {
                self.dict_PreviousVideo = dataDict!.mutableCopy() as! NSMutableDictionary
                self.removeLoader()
            }
            else {
                self.removeLoader()
                self.showAlertWith(strMessage: MSG_ERROR_OCCURRED)
            }
            
            self.collectionGenre.reloadData()
        })
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.arr_GenreTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCollectionCell
        
        let genreModel = self.arr_GenreTypes[indexPath.row] as! GenreModel
        let imgNormal = UIImage(named: genreModel.strNormalGenreImage)
        cell.btnGenre.tag = indexPath.row
        cell.btnGenre.setImage(imgNormal, for: .normal)
        
        let strImageURL = String(format: "%@/%@-a.png", URL_GENRE_IMAGE_ROOT, genreModel.strMusicGenreId)
        let img_URL = URL(string: strImageURL)

        // UIImage(named: "PlaceHolder")
        cell.btnGenre.sd_setImage(with: img_URL, for: .normal, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: {image, error, cacheType, imageURL in
            cell.myIndicator.stopAnimating();
            cell.myIndicator.removeFromSuperview();
          
            if (error != nil) {
                let imgPlaceHolder = UIImage(named: "PlaceHolder")
                cell.btnGenre.setImage(imgPlaceHolder, for: .normal)
            }
            else {
                cell.btnGenre.setImage(image, for: .normal)
            }
        })
        
        cell.btnGenre.addTarget(self, action: #selector(self.btnActionGenre(btnGenre:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:  IndexPath) -> CGSize {
        
        let firstTrait = (UIScreen.main.bounds.size.width/2) - 15
        let returnSize = CGSize(width: firstTrait, height: firstTrait)
        
        return returnSize
    }
    
    @objc private func btnActionGenre(btnGenre: UIButton) {
        
        let genreModel = self.arr_GenreTypes[btnGenre.tag] as! GenreModel
        let storyBoard = UIStoryboard(name: "SoundBankBoard", bundle: nil)
        let sequenceViewController = storyBoard.instantiateViewController(withIdentifier: "SoundBankViewController") as! SoundBankViewController
        sequenceViewController.genreModel = genreModel
        sequenceViewController.dict_PreviousVideo = dict_PreviousVideo
        sequenceViewController.arr_JoiningSequenceA = genreModel.joiningSequenceA
        self.navigationController?.pushViewController(sequenceViewController, animated: true)
    }
    
    
    
}

