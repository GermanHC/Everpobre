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
    @IBOutlet weak var imageView: UIImageView!
    
    var item: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: Note) {
        backgroundColor = .white
        titleLabel.text = item.title
        
        creationDateLabel.text = (item.creationDate as Date?)?.customStringLabel()
        
        guard let data = item.image as Data? else {
            imageView.image = #imageLiteral(resourceName: "120x180")
            return
        }
        
        imageView.image = UIImage(data: data)    }
}
