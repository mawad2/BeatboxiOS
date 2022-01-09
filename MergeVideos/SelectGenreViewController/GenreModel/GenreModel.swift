//
//  GenreModel.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 04/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class GenreModel: NSObject {
    
    var strMusicGenreId = String()
    var strNormalGenreImage = String()
    var strSelectedGenreImage = String()
    var arr_SoundBank = NSMutableArray()
    var arr_JoiningSequence = NSMutableArray()//OLDER ONE WILL NEED TO REMOVE
    var joiningSequenceA  = NSMutableArray()
    var strMusicGenreName = String()

    init(info: NSDictionary) {
        self.strMusicGenreId = info.value(forKey: "musicGenreId") as! String
        self.strNormalGenreImage = String(format: "%@ (N)", info.value(forKey: "musicGenreName") as! CVarArg)
        self.strSelectedGenreImage = String(format: "%@ (P)", info.value(forKey: "musicGenreName") as! CVarArg)
        self.strMusicGenreName = info.value(forKey: "musicGenreName") as! String
        
        if (info.value(forKey: "musicGenreSoundA") != nil) {
            let arr_SBPacket = info.value(forKey: "musicGenreSoundA") as! NSArray
            for index in 0..<arr_SBPacket.count {
                let dict_SBPacket = arr_SBPacket[index] as! NSDictionary
                let soundBank = SoundBankModel(infoDict: dict_SBPacket)
                self.arr_SoundBank.add(soundBank)
            }
        }

        if (info.value(forKey: "joiningSequenceA") != nil) {
            let arr_JoingSeq = info.value(forKey: "joiningSequenceA") as! NSArray
            for index in 0..<arr_JoingSeq.count {
                let dict_JoinSeq = arr_JoingSeq[index] as! NSDictionary
                let JoinObj = JoiningSequenceModel.init(info: dict_JoinSeq)
                self.joiningSequenceA.add(JoinObj)
            }
        }
        if (info.value(forKey: "joiningSequenceA") != nil) {
            let joiningSequenceArray = info.value(forKey: "joiningSequenceA") as! NSArray
            self.arr_JoiningSequence = joiningSequenceArray.mutableCopy() as! NSMutableArray
        }
    
    }
}
