//
//  CoreDataStack.swift
//  Everpobre
//
//  Created by German Hernandez on 14/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private let modelName: String
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.storeContainer.newBackgroundContext()
    }()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    /*private*/ lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved  error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
