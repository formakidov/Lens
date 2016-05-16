
import CoreData

class GalleryManager {
    
    static func addImage(image: UIImage) -> Bool {
        let filePath = Utils.generateImageFilePath()
        
        let fileSavedSuccessfully = saveImageFile(image, path: filePath)
        
        if (fileSavedSuccessfully) {
            return ImageRepository.save(filePath, date: Utils.currentTimeMillis())
        } else {
            return false
        }
    }
    
    static func deleteImage(path: String) -> Bool {
        removeImageFile(path)
        return ImageRepository.deleteBy(path: path)
    }
    
    static func saveImageFile(image: UIImage, path: String) -> Bool {
        let pngImageData = UIImagePNGRepresentation(image)
        let result = pngImageData!.writeToFile(path, atomically: true)
        return result
    }
    
    static func removeImageFile(path: String) -> Bool {
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        let filePath = NSString(format:"%@", path) as String
        do {
            try fileManager.removeItemAtPath(filePath)
            return true
        } catch let error as NSError {
            print("Could not delete image file at \(filePath) error: \(error)")
            return false
        }

    }

}