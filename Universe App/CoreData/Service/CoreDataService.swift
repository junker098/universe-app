//
//  CoreDataService.swift
//  Universe App
//
//  Created by Yuriy on 21.03.2024.
//

import CoreData

protocol CoreDataServiceProtocol {
    func fetchPhotoModels(completion: @escaping ([PhotoModelData]?) -> Void )
    func saveNewModels(_ newModels: [PhotoModel])
}

class CoreDataService: CoreDataServiceProtocol {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Universe App")
        container.loadPersistentStores { _ , error in
            if let error = error {
                DebugLogger.shared.logEvent(type: .error, object: error)
            }
            
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            DebugLogger.shared.logEvent(type: .error, object: error)
        }
    }
    
    func fetchPhotoModels(completion: @escaping ([PhotoModelData]?) -> Void ) {
        let fetchRequest: NSFetchRequest<PhotoModelData> = PhotoModelData.fetchRequest()
        do {
            let fetchObject = try context.fetch(fetchRequest)
            return completion(fetchObject)
        } catch {
            DebugLogger.shared.logEvent(type: .error, object: error)
            return completion(nil)
        }
    }
    
    func saveNewModels(_ newModels: [PhotoModel]) {
        deleteAllPhotoModels()
        newModels.forEach { model in
            let newPhoto = PhotoModelData(context: context)
            newPhoto.localIdentifiers = model.localIdentifiers
            newPhoto.isDeleting = model.isDeleting
        }
        saveContext()
    }
    
    private func deleteAllPhotoModels() {
        let fetchRequest: NSFetchRequest<PhotoModelData> = PhotoModelData.fetchRequest()
        do {
            let photos = try context.fetch(fetchRequest)
            photos.forEach { context.delete($0) }
        } catch {
            DebugLogger.shared.logEvent(type: .error, object: error)
        }
    }
}
