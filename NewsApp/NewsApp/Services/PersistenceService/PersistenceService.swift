//
//  PersistenceService.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import CoreData

class PersistenceService {
    enum ContainerName: String {
        case standard = "CoreDataModel"
    }
    
    typealias PersistenceErrorClosure = GenericClosure<PersistenceServiceError?>
    typealias PersistenceResultClosure<Success> = ResultClosure<Success, PersistenceServiceError>
    
    static let shared: PersistenceServiceContext = PersistenceService(name: .standard)
    let mainContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    let persistentContainer: NSPersistentContainer
    
    private init(name: ContainerName) {
        let container = NSPersistentContainer(name: name.rawValue)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer = container
        mainContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
        mainContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    func getObjectID(from url: URL) -> NSManagedObjectID? {
        persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }
}

// MARK: - Fetch Method(s)
extension PersistenceService {
    func fetch<Entity>(on context: NSManagedObjectContext, predicate: NSPredicate? = nil) async throws -> [Entity] where Entity: NSManagedObject {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            
            return try context.fetch(request) as? [Entity] ?? []
        }
    }
    
    func fetch<Entity>(url: URL, on context: NSManagedObjectContext) async throws -> Entity? where Entity: NSManagedObject {
        guard let objectID = getObjectID(from: url) else { throw PersistenceServiceError.general("Not found id from URL: \(url.absoluteString) in context \(context.self)") }
        
        return try await context.perform {
            return try context.existingObject(with: objectID) as? Entity
        }
    }
}

// MARK: Delete Method(s)
extension PersistenceService {
    func delete(url: URL, on context: NSManagedObjectContext) async throws {
        guard let objectID = getObjectID(from: url) else { throw PersistenceServiceError.general("Not found id from URL: \(url.absoluteString) in context \(context.self)") }
        
        try await context.perform {
            let entity = try context.existingObject(with: objectID)
            context.delete(entity)
        }
    }
    
    func deleteAndMergeChanges(on context: NSManagedObjectContext, using batchDeleteRequest: NSBatchDeleteRequest) async throws {
        try await context.perform {
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]

            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
    }
}

// MARK: Save Method(s)
extension PersistenceService {
    func saveContextIfNeeded(_ context: NSManagedObjectContext) async throws {
        try await context.perform {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}
