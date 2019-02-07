//
//  File.swift
//  iB-Draft
//
//  Created by Umberto Cerrato on 29/01/2019.
//  Copyright © 2019 Umberto. All rights reserved.
//

import CoreData

let dataErrorDomain = "dataErrorDomain"

enum DataErrorCode: NSInteger {
    case networkUnavailable = 101
    case wrongDataFormat = 102
}

class DataProvider {
    
    private let persistentContainer: NSPersistentContainer
    private let repository: APIManager
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer, repository: APIManager) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }
    
    /// - Parameter completion: escape the error if any from the getCountries func in the APIManager.
    func fetchCountries(completion: @escaping(Error?) -> Void) {
        repository.getCountries { (jsonDictionary, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let jsonDictionary = jsonDictionary else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            print("\n\nFETCHCOUNTRIES\n\n")
            
            /// A background context that will be merged with the main context at the end of the fetching process
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
            
            _ = self.syncCountries(jsonDictionary: jsonDictionary, taskContext: taskContext)
            
            completion(nil)
        }
    }
    
    /// Reads the data from the jsonDictionary and upload them into the Core Data context as _Country_ entity.
    ///
    /// - Parameters:
    ///   - jsonDictionary: the JSON object as array of dictionary _[[String: Any]]_.
    ///   - taskContext: the context where to save countries in.
    /// - Returns: true if successfull, false if not.
    private func syncCountries(jsonDictionary: [[String: Any]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            // Create new records.
            for countryDictionary in jsonDictionary {
                
                guard let country = NSEntityDescription.insertNewObject(forEntityName: "Country", into: taskContext) as? Country else {
                    print("Error: Failed to create a new Film object!")
                    return
                }
                
                do {
                    try country.update(with: countryDictionary)
                } catch {
                    print("Error: \(error)\nThe quake object will be deleted.")
                    taskContext.delete(country)
                }
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
}
