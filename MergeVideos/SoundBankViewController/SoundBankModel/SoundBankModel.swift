//
//  SoundBankModel.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 06/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class SoundBankModel: NSObject {
    
    var strMusicGenreSoundId = String()
    var strMusicGenreId = String()
    var strMusicGenreSoundName = String()
    var alreadyDownloaded = Bool()
    init(infoDict: NSDictionary) {
        
        alreadyDownloaded = false
        self.strMusicGenreSoundId = infoDict.value(forKey: "musicGenreSoundId") as! String
        self.strMusicGenreId = infoDict.value(forKey: "musicGenreId") as! String
        self.strMusicGenreSoundName = infoDict.value(forKey: "musicGenreSoundName") as! String
    }
    
}
