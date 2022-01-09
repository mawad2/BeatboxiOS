//
//  JoiningSequenceModel.swift
//  MergeVideos
//
//  Created by M Abubaker Majeed on 10/10/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class JoiningSequenceModel: NSObject {


    var musicGenreId = String()
    var musicGenreSoundId = String()
    var time = Double()

    init(info: NSDictionary) {
        self.musicGenreId = info.value(forKey: "musicGenreId") as! String
        self.musicGenreSoundId = info.value(forKey: "musicGenreSoundId") as! String
        self.time =  Double(info.value(forKey: "time") as! String) ?? 0
    }
    
}
