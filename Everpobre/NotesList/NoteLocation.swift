//
//  NoteLocation.swift
//  Everpobre
//
//  Created by German Hernandez on 4/11/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import UIKit
import MapKit

class NoteLocation: NSObject {
    
    let name: String
    let info: String
    let location: CLLocationCoordinate2D
    
    init(note: Note) {
        self.name = note.title ?? "ND"
        self.info = note.text ?? "ND"
        self.location = CLLocationCoordinate2D(latitude: note.latitude,longitude: note.longitude)
    }
}

extension NoteLocation: MKAnnotation {
    var coordinate: CLLocationCoordinate2D{
        get {
            return location
        }
    }
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return info
    }
}
