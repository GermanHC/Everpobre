//
//  NotesListCollectionViewCell.swift
//  Everpobre
//
//  Created by German Hernandez on 22/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import UIKit

class NotesListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    var item: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: Note) {
        backgroundColor = .red
        titleLabel.text = item.title
        creationDateLabel.text = (item.creationDate as Date?)?.customStringLabel()
    }
}
