//
//  Notebook+CoreDataClass.swift
//  Everpobre
//
//  Created by German Hernandez on 24/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Notebook)
public class Notebook: NSManagedObject {

}
extension Notebook {
    func csv() -> String {
        let exportedName = name ?? "Sin Titulo"
        let exportedNotesCount = notes?.count ?? 0
        let exportedCreationDate = (creationDate as Date?)?.customStringLabel() ?? "ND"
        
        return "Notebook Name:\"\(exportedName)\",NumOfNotes:\(exportedNotesCount),\"\(exportedCreationDate)\""
    }
}
