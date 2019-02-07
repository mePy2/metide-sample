//
//  CustomHeaderTableViewCell.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 05/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import UIKit

class CustomHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    
    func setupHeaderCell() {
        self.backgroundColor = UIColor(red: 248/255, green: 133/255, blue: 5/255, alpha: 1)
        self.headerLabel.textColor = .white
        self.headerLabel.text = "This is a list of countries, sorted from the closest to to farthest by Metide Srl location (45.554550, 12.303390)"
        self.headerLabel.lineBreakMode = .byWordWrapping
    }
}
