//
//  CountryTableViewCell.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 04/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    
    
    /// Setup the cell with country name and flag.
    ///
    /// - Parameter country: the NSManagedObject where to take the country informations from.
    func setupCell(country: Country) {
        self.backgroundColor = .white
        self.countryName.text = country.name
        guard let link = country.flag else { return }
        self.flagImageView.loadImageUsingCacheWithURLString(link, placeHolder: UIImage(named: "missing-flag"))
    }
}
