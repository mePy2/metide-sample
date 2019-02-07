//
//  APIManager.swift
//  Metide Sample app
//
//  Created by Umberto Cerrato on 04/02/2019.
//  Copyright © 2019 Umberto Cerrato. All rights reserved.
//

import Foundation
import CoreData

class APIManager {
    
    private init() {}
    static let shared = APIManager()
    
    private let urlSession = URLSession.shared
    private var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "us-central1-job-interview-cfe5a.cloudfunctions.net"
        components.path = "/countries"
        let url = components.url
        return url
    }
    
    /// Calls the API and download the data from it. The raw data is then serialized in a JSON object as array of dictionaries.
    ///
    /// - Parameter completion: escape the downloaded JSON as an array of dictionaries.
    func getCountries(completion: @escaping(_ countriesDict: [[String: Any]]?, _ error: Error?) -> ()) {
        guard let url = url else { return }
        
        let loginString = String(format: "%@:%@", "developer", "metide")
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField:"Authorization")
        urlSession.dataTask(with: request)  { (data, response, error) in
            if let error = error {
                print("error")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("no data")
                completion(nil, error)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? [[String: Any]] else {
                    throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                }
                completion(jsonDictionary, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
}
