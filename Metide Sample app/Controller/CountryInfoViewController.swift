//
//  CountryInfoViewController.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 07/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import UIKit
import MapKit

class CountryInfoViewController: UIViewController {

    @IBOutlet weak var officialNameLabel: UILabel!
    @IBOutlet weak var countryMapView: MKMapView!
    @IBOutlet weak var noteTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        view.backgroundColor = .white
        noteTextView.layer.cornerRadius = 3
        // Do any additional setup after loading the view.
    }
    
    init(name: String, officialName: String, location: CLLocation, noteContent: String?) {
        super.init(nibName: nil, bundle: nil)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = name
        
        self.title = name
        self.officialNameLabel.text = officialName
        self.countryMapView.addAnnotation(annotation)
        self.noteTextView.text = noteContent
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
