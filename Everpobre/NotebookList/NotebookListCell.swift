//
//  NotebookListCell.swift
//  Everpobre
//
//  Created by German Hernandez on 8/10/18.
//  Copyright © 2018 German Hernandez. All rights reserved.
//

import UIKit

class NotebookListCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var creationDateLabel: UILabel!
    
    override func prepareForReuse() {
        titleLabel.text = nil
        creationDateLabel.text = nil
        super.prepareForReuse()
    }
    
    func configure(with notebook: Notebook) {
        titleLabel.text = notebook.name
        creationDateLabel.text = "Creado: \((notebook.creationDate as Date?)?.customStringLabel() ?? "ND")"
    }
}
