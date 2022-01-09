//
//  PersistentStorage.swift
//  BeatBox
//
//  Created by Shailendra Barewar on 02/12/20.
//  Copyright © 2020 Khoa Vo. All rights reserved.
//

import Foundation
import CoreData

final class PersistentStorage {
    
    private init(){}
    static let shared = PersistentStorage()
     // MARK: - Core Data stack

       lazy var persistentContainer: NSPersistentContainer = {
           
           let container = NSPersistentContainer(name: "BeatBoxData")
           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                  
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           })
           return container
       }()

       // MARK: - Core Data Saving support
        lazy var context = persistentContainer.viewContext
       func saveContext () {
       
           if context.hasChanges {
               do {
                   try context.save()
               } catch {
                   
                
                   let nserror = error as NSError
                   fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
               }
           }
       }
}
