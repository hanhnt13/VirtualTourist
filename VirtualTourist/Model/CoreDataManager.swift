//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit
import CoreData
import MapKit

class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    }
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completeion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.configureContexts()
            completeion?()
        }
    }
    
    func fetchCurrentPin() -> [TravelAnnotation] {
        let request:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "long", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        var annotations = [TravelAnnotation]()
        do {
            let results = try viewContext.fetch(request)
            for dictionary in results {
                let lat = CLLocationDegrees(dictionary.lat)
                let long = CLLocationDegrees(dictionary.long)
                
                let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = TravelAnnotation()
                annotation.coordinate = cordinate
                annotation.pin = dictionary
                
                annotations.append(annotation)
            }

        } catch {
            
        }
        return annotations
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
