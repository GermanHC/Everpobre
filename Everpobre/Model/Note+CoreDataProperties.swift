//
//  Note+CoreDataProperties.swift
//  Everpobre
//
//  Created by German Hernandez on 15/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var lastSeenDate: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var notebook: Notebook?

}
