//
//  GenreCollectionModel.swift
//  BeatBox
//
//  Created by Shailendra Barewar on 23/02/21.
//  Copyright © 2021 Khoa Vo. All rights reserved.
//

import Foundation


class GenreCollectionModel : NSObject {
    
    var strMusicGenreSoundId = String()
    var strMusicGenreId = String()
    var strMusicGenreSoundName = String()
    var frame = String()
    var time = String()
    var count = String()
    
    init(strMusicGenreSoundId:String, strMusicGenreId: String, strMusicGenreSoundName:String, frame:String, time:String, count:String ) {
        self.strMusicGenreSoundId = strMusicGenreSoundId
        self.strMusicGenreId = strMusicGenreId
        self.strMusicGenreSoundName = strMusicGenreSoundName
        self.frame = frame
        self.time = time
        self.count = count
    }

}

class GenreCollectionService {
    
    func getPlayList() -> [GenreCollectionModel]{
       let playList = [
        GenreCollectionModel(strMusicGenreSoundId: "1", strMusicGenreId: "3", strMusicGenreSoundName: "Kick", frame: "4", time: "2", count: "1"),
        GenreCollectionModel(strMusicGenreSoundId: "2", strMusicGenreId: "3", strMusicGenreSoundName: "Snare", frame: "4", time: "2", count: "1"),
        GenreCollectionModel(strMusicGenreSoundId: "3", strMusicGenreId: "3", strMusicGenreSoundName: "Shoosh", frame: "4", time: "3", count: "1"),
        GenreCollectionModel(strMusicGenreSoundId: "4", strMusicGenreId: "3", strMusicGenreSoundName: "Dubstep", frame: "4", time: "4", count: "1"),
        GenreCollectionModel(strMusicGenreSoundId: "5", strMusicGenreId: "3", strMusicGenreSoundName: "Pop", frame: "4", time: "3", count: "1")
        ]
        return playList
    }
}
