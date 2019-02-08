//
//  ViewController.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 04/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController {
    
    var dataProvider: DataProvider!
    var countries = [Country]()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.setupCountriesTableView),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        return refreshControl
    }()
    
    ///  TableView outlet from the storyboard
    @IBOutlet weak var countriesTableView: UITableView!

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        countriesTableView.sectionHeaderHeight = UITableView.automaticDimension
        countriesTableView.estimatedSectionHeaderHeight = 90;
        countriesTableView.refreshControl = refreshControl
        
        setupNavigationBar()
        setupCountriesTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.countriesTableView.indexPathForSelectedRow{
            self.countriesTableView.deselectRow(at: index, animated: true)
        }
    }
    
    /// Setup the TableView fetching the countries from the API url.
    @objc func setupCountriesTableView() {
        dataProvider.fetchCountries { (error) in
            self.fetchRecordsForEntity("Country", inManagedObjectContext: self.dataProvider.viewContext, completion: {
                DispatchQueue.main.async {
                    self.countriesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    // MARK: - Navigation bar setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.barTintColor = UIColor(red: 62/255, green: 74/255, blue: 74/255, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        
        let attributes = [NSAttributedString.Key.font: UIFont(name: "JosefinSans-Bold", size: 34)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CountryInfoViewController {
            guard let indexPath = countriesTableView.indexPathForSelectedRow else { return }
            destination.country = countries[indexPath.row]
            destination.dataProvider = dataProvider
        }
    }
    
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext, completion: @escaping() -> ()) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [Country] {
                let userLocation = CLLocation(latitude: 45.554550, longitude: 12.303390)
                
                // Here the countries are sorted based on their location, from the the closest to the farthest from the user location (Metide srl)
                countries = records.sorted { (l1, l2) -> Bool in return l1.distance(to: userLocation) < l2.distance(to: userLocation) }
                completion()
            }
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! CustomHeaderTableViewCell
        headerCell.setupHeaderCell()
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country") as! CountryTableViewCell
        let country = countries[indexPath.row]
        
        cell.setupCell(country: country)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.contentView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.contentView.backgroundColor = UIColor(red: 250/255, green: 173/255, blue: 40/255, alpha: 1)
        
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
}
