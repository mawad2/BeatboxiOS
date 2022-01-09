//
//  VideoRepository.swift
//  BeatBox
//
//  Created by Shailendra Barewar on 23/12/20.
//  Copyright © 2020 Khoa Vo. All rights reserved.
//

import Foundation
import CoreData

protocol VideoRepository {
    func createVideo(videoData: BeatBoxModel)
    func getAll() -> [Video]?
    func get(date: String) -> Video?
    func update(data: Video) -> Bool
    func delete(record: Video) -> Bool
    func getVideoBySubGener(musicGenreSoundId: String) -> Video?
}

struct VideoDataRepository : VideoRepository {
   
    func createVideo(videoData: BeatBoxModel) {
        let CDVideo = Video(context: PersistentStorage.shared.context)
        CDVideo.date = videoData.date
        CDVideo.genre = videoData.genre
        CDVideo.musicGenreId = videoData.musicGenreId
        CDVideo.musicGenreSoundId = videoData.musicGenreSoundId
        CDVideo.name = videoData.name
        CDVideo.videoData = videoData.videoData
        
        PersistentStorage.shared.saveContext()
    }
    
    func getAll() -> [Video]? {
            
        do {
            guard let result = try PersistentStorage.shared.context.fetch(Video.fetchRequest()) as? [Video] else {
                return nil
            }
             return result
        } catch let error{
            debugPrint(error)
        }
       return nil
    }
    
    func get(date: String) -> Video? {
        let fatchRequest = NSFetchRequest<Video>(entityName: "Video")
        let predicate = NSPredicate(format: "date==%@", date as CVarArg)
        fatchRequest.predicate = predicate
        do {
            let result = try PersistentStorage.shared.context.fetch(fatchRequest).first
            guard result != nil else {
                return nil
            }
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
//    func getGenerVideo(generId: String) -> Video? {
//        let fatchRequest = NSFetchRequest<Video>(entityName: "Video")
//        let predicate = NSPredicate(format: "musicGenreSoundId==%@", generId as CVarArg)
//        fatchRequest.predicate = predicate
//        do {
//                let result = try PersistentStorage.shared.context.fetch(fatchRequest).first
//                guard result != nil else {
//                    return nil
//                }
//            return result
//        } catch let error {
//                debugPrint(error)
//        }
//        return nil
//       }
//
    
    
    func update(data: Video) -> Bool {
        let result  = get(date: data.date ?? "")
        guard result != nil else {return false}
        
        result?.date = data.date
        result?.genre = data.genre
        result?.musicGenreId = data.musicGenreId
        result?.musicGenreSoundId = data.musicGenreSoundId
        result?.videoData = data.videoData
        result?.name = data.name
        
        PersistentStorage.shared.saveContext()
        return true
        
    }
    
    func delete(record: Video)-> Bool {
        let result  = get(date: record.date ?? "")
        guard result != nil else {return false}
        PersistentStorage.shared.context.delete(result!)
        return true
        
    }
    
    private func getCDVideo(date: String) -> Video? {
        
        let fatchRequest = NSFetchRequest<Video>(entityName: "Video")
        let predicate = NSPredicate(format: "date==%@", date as CVarArg)
        fatchRequest.predicate = predicate
        do {
            let result = try PersistentStorage.shared.context.fetch(fatchRequest).first
            guard result != nil else {
                return nil
            }
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    func getVideoBySubGener(musicGenreSoundId: String) -> Video? {
        let fatchRequest = NSFetchRequest<Video>(entityName: "Video")
        let predicate = NSPredicate(format: "musicGenreSoundId==%@", musicGenreSoundId as CVarArg)
        fatchRequest.predicate = predicate
        do {
            let result = try PersistentStorage.shared.context.fetch(fatchRequest).first
            guard result != nil else {
                return nil
            }
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    
    func deleteRecord() -> Bool {
        do {
            guard let records = try PersistentStorage.shared.context.fetch(Video.fetchRequest()) as? [Video] else {
                return true
            }
            debugPrint("total record\(records.count)")
            for record in records {
                PersistentStorage.shared.context.delete(record)
                debugPrint("delete all record")
            }
        } catch let error{
            debugPrint(error)
        }
        return true
    }
    
    private func convertIntoBeatBoxModel(videoData: Video) -> BeatBoxModel {
        
        let beatBox = BeatBoxModel()
        beatBox.name = videoData.name
        beatBox.genre = videoData.genre
        beatBox.date = videoData.date
        beatBox.musicGenreId = videoData.musicGenreId
        beatBox.musicGenreSoundId = videoData.musicGenreSoundId
        beatBox.videoData = videoData.videoData
        
        return beatBox
        
    }
    
}
