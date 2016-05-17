
import CoreData

class ImageRepository {
    
    static let IMAGE_DATA = "Image"
    
    static func queryAll() -> [NSManagedObject]? {
        let managedContext = CoreDataManager.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Image")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            return results as? [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    static func save(path: String, date: Int64) -> Bool {
        let managedContext = CoreDataManager.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName(IMAGE_DATA, inManagedObjectContext:managedContext)
        
        let imageData = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        imageData.setValue(path, forKey: "path")
        imageData.setValue(NSNumber(longLong: date), forKey: "date")
        
        do {
            try managedContext.save()
            return true
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }
    }
    
    static func deleteBy(path p: String) -> Bool {
        let managedContext = CoreDataManager.managedObjectContext
        
        let fetchPredicate = NSPredicate(format: "path = %@", p)
        
        let fetchImages = NSFetchRequest(entityName: IMAGE_DATA)
        fetchImages.predicate = fetchPredicate
        fetchImages.returnsObjectsAsFaults = false
        
        do {
            let fetchedImages = try managedContext.executeFetchRequest(fetchImages) as! [NSManagedObject]
            
            for fetchedImage in fetchedImages {
                managedContext.deleteObject(fetchedImage)
                try managedContext.save()
            }
            return true
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
    }
}
