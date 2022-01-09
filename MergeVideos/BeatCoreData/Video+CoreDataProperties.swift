//
//  Video+CoreDataProperties.swift
//  BeatBox
//
//  Created by Shailendra Barewar on 23/12/20.
//  Copyright © 2020 Khoa Vo. All rights reserved.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var date: String?
    @NSManaged public var genre: String?
    @NSManaged public var name: String?
    @NSManaged public var videoData: String?
    @NSManaged public var musicGenreSoundId: String?
    @NSManaged public var musicGenreId: String?

}
