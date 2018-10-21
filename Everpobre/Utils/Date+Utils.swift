//
//  Date+Utils.swift
//  Everpobre
//
//  Created by German Hernandez on 14/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import Foundation

extension Date{
    func customStringLabel() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return "Creado: \(dateFormatter.string(from: self))"
    }
}
