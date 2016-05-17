
import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var picker:UIImagePickerController?=UIImagePickerController()
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var images :[NSManagedObject] = []
    var toCropImage: UIImage?
    var selectedImagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate=self
        photosCollectionView.collectionViewLayout = PhotoViewFlowLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let managedContext = CoreDataManager.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Image")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            images = results as! [NSManagedObject]
            
            photosCollectionView.reloadData()
        } catch let error as NSError {
            Utils.showAlert(self, title: "An Error occured".localized, message: "Cannot load images".localized, btnText: "WTF???")
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func takePictureBtn(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            picker!.cameraCaptureMode = .Photo
            presentViewController(picker!, animated: true, completion: nil)
        } else {
            photosCollectionView.reloadData()
            Utils.showAlert(self, title: "Cannot open camera".localized, message: "Device doesn't support camera".localized, btnText: "OK")
        }
    }
    
    @IBAction func openGallery(sender: UIButton) {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        toCropImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("cropper", sender: self)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoViewCell
        let imagePath = images[indexPath.row].valueForKey("path") as! String
        cell.img.image = UIImage(contentsOfFile: imagePath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedImagePath = images[indexPath.row].valueForKey("path") as? String
        performSegueWithIdentifier("fullScreen", sender: self)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        photosCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "cropper" {
            let cvc = segue.destinationViewController as! CropperViewController
            cvc.toCropImage = toCropImage
        } else if segue.identifier == "fullScreen" {
            let fpvc = segue.destinationViewController as! FullPhotoViewController
            fpvc.imagePath = selectedImagePath
        }
    }
    
}

