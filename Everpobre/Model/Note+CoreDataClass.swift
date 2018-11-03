//
//  Note+CoreDataClass.swift
//  Everpobre
//
//  Created by German Hernandez on 3/11/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {

}

extension Note {
    func csv() -> String {
        let exportedTitle = title ?? "Sin Titulo"
        let exportedText = text ?? ""
        let exportedCreationDate = (creationDate as Date?)?.customStringLabel() ?? "ND"
        let exportedTags = tags ?? "ND"
        let exportedCoords = "(\(latitude),\(longitude))"
        return "\(exportedCreationDate),\(exportedTitle),\(exportedText),\(exportedTags),\(exportedCoords)"
    }
}
