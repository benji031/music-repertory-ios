//
//  CoreDataService.swift
//  scout-ios
//
//  Created by Benjamin DENEUX on 13/04/2017.
//  Copyright © 2017 UBLEAM. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataService: DataService {
    
    private let modelName: String = "Model"
    
    public init() {
        
    }
    
    // MARK: - Core Data Stack
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            Log("Unable to Load Persistent Store", level: .error)
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: - Notification Handling
    @objc func saveChanges(_ notification: NSNotification) {
        managedObjectContext.perform {
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                Log("Unable to Save Changes of Managed Object Context", level: .error)
                Log("\(saveError), \(saveError.localizedDescription)", level: .error)
            }
            
            self.privateManagedObjectContext.perform {
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    Log("Unable to Save Changes of Private Managed Object Context", level: .error)
                    Log("\(saveError), \(saveError.localizedDescription)", level: .error)
                }
            }
            
        }
    }
    
    public func getPrivateContext() -> NSManagedObjectContext {
        return self.privateManagedObjectContext
    }
    
    public func create<T : NSManagedObject>(type: T.Type, entityName: String) -> T? {
        let context = self.privateManagedObjectContext
        return create(type: type, entityName: entityName, in: context)
    }
    
    public func create<T>(type: T.Type, entityName: String, in context: NSManagedObjectContext) -> T? where T : NSManagedObject {
        let description = NSEntityDescription.entity(forEntityName: entityName, in: context)
        return T(entity: description!, insertInto: context)
    }
    
    public func save(_ object: NSManagedObject) {
        guard let context = object.managedObjectContext else {
            Log("No context found for object \(object)!", level: .warning)
            return
        }
        
        save(context)
    }
    
    public func save(_ context: NSManagedObjectContext) {
        context.performAndWait {
            if context.hasChanges == true {
                do {
                    try context.save()
                } catch let error {
                    Log("Error saving context : \(error)", level: .error)
                }
            }
        }
        
        self.managedObjectContext.performAndWait { [unowned self] in
            if self.managedObjectContext.hasChanges == true {
                do {
                    try self.managedObjectContext.save()
                } catch let error {
                    Log("Error saving main context : \(error)", level: .error)
                }
            }
        }
    }
    
    public func fetchObjects<T>(request: NSFetchRequest<T>) -> [T]? {
        let context = self.privateManagedObjectContext
        return fetchObjects(request: request, on: context)
    }
    
    public func fetchObjects<T>(request: NSFetchRequest<T>, on context: NSManagedObjectContext) -> [T]? {
        var elements: [T]?
        context.performAndWait {
            elements = try! context.fetch(request)
        }
        return elements
    }
    
    public func delete(_ object: NSManagedObject) {
        guard let context = object.managedObjectContext else {
            Log("No context found for object \(object)!", level: .warning)
            return
        }
        context.performAndWait {
            context.delete(object)
        }
        save(context)
    }
    
    public func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) {
        let objects = fetchObjects(request: request)
        if let objects = objects, objects.count > 0 {
            Log("Remove \(objects.count) object in persistent store.", level: .info)
            let context = objects.first!.managedObjectContext
            for object in objects {
                context?.delete(object)
            }
            save(context!)
        }
    }
}
