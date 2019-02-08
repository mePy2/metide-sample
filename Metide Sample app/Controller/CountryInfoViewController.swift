//
//  CountryInfoViewController.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 07/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CountryInfoViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var officialNameLabel: UILabel!
    @IBOutlet weak var countryMapView: MKMapView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var noteTitleLabel: UILabel!
    
    weak var paragraphStyle: NSMutableParagraphStyle? {
        let p = NSMutableParagraphStyle()
        p.firstLineHeadIndent = 5.0
        p.lineHeightMultiple = 1.5
        return p
    }
    
    var dataProvider: DataProvider?
    var country: Country?
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        retriveNoteFromCountryID(id: country?.id) { (note) in
            self.note = note
        }
        
        setupOfficialNameLabel()
        setupMapView()
        setupNoteTextView()
    }
    
    func setupOfficialNameLabel() {
        officialNameLabel.text = "Name: \(country?.name ?? "Country name")\nOfficial name: \(country?.officialName ?? "Country official name")"
    }
    
    func setupNoteTextView() {
        noteTitleLabel.text = "Note:"
        noteTitleLabel.textColor = .white
        noteTitleLabel.font = UIFont(name: "JosefinSans-Regular", size: 17.0)
        noteTitleLabel.attributedText = NSAttributedString(string: "Note:", attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle!])
        noteTitleLabel.clipsToBounds = true
        noteTitleLabel.layer.cornerRadius = 3.0
        noteTitleLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        noteTextView.isEditable = true
        noteTextView.delegate = self
        noteTextView.text = note?.content
        noteTextView.clipsToBounds = true
        noteTextView.layer.cornerRadius = 3.0
        noteTextView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func setupMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = ((country?.location.coordinate)!)
        annotation.title = country?.name
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(country?.zoom ?? "0")!) * Double(self.countryMapView.frame.size.width) / 256)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        self.countryMapView.setRegion(region, animated: true)
    }

    func retriveNoteFromCountryID(id: String?, completion: @escaping(_ note: Note?) -> Void) {
        guard let id = id else { self.noteTextView.isHidden = true; return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "countryId == %@", id)
        do {
            let result = try dataProvider?.viewContext.fetch(fetchRequest)
            if result?.count == 1 {
                let note = result?[0] as? Note
                completion(note)
            } else {
                completion(nil)
            }
        } catch {
            print("Error while fetching the note content...")
            completion(nil)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let newContent = self.noteTextView.text
        if let note = note {
            note.content = newContent
        } else {
            guard let context = dataProvider?.viewContext else { return }
            let note = Note(context: context)
            note.content = newContent
            note.countryId = country?.id
        }
        do { try dataProvider?.viewContext.save() } catch { return }
    }
}
