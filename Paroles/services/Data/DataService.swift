//
//  DataService.swift
//  scout-ios
//
//  Created by Benjamin DENEUX on 13/04/2017.
//  Copyright © 2017 UBLEAM. All rights reserved.
//

import Foundation
import CoreData

public protocol DataService {
    
    func getPrivateContext() -> NSManagedObjectContext
    
    func create<T : NSManagedObject>(type: T.Type, entityName: String) -> T?
    
    func create<T : NSManagedObject>(type: T.Type, entityName: String, in context: NSManagedObjectContext) -> T?
    
    func save(_ object: NSManagedObject)
    
    func save(_ context: NSManagedObjectContext)
    
    func fetchObjects<T>(request: NSFetchRequest<T>) -> [T]?
    
    func fetchObjects<T>(request: NSFetchRequest<T>, on context: NSManagedObjectContext) -> [T]?
    
    func delete(_ object: NSManagedObject)
    
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>)
}
