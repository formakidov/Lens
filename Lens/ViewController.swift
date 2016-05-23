
import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var picker:UIImagePickerController? = UIImagePickerController()
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var images :[NSManagedObject] = []
    var toCropImage: UIImage?
    var selectedImagePath: String?
    
    var galleryManager: GalleryManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate=self
        photosCollectionView.collectionViewLayout = PhotoViewFlowLayout()
        
        let openGallery = UIBarButtonItem(image: UIImage(named: "Gallery"), style: .Plain, target: self, action: #selector(ViewController.openGallery))
        let takePhoto = UIBarButtonItem(image: UIImage(named: "Camera"), style: .Plain, target: self, action: #selector(ViewController.takePhotoBtn))
        
        navigationItem.setRightBarButtonItems([takePhoto, openGallery], animated: true)
        
        self.title = "Documents".localized
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let result = galleryManager.getAll() {
            images = result
            infoLabel.hidden = result.count > 0
            photosCollectionView.reloadData()
        } else {
            Utils.showAlert(self, title: "An Error occured".localized, message: "Cannot load images".localized, btnText: "WTF???")
        }
    }
    
    func takePhotoBtn() {
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
    
    func openGallery() {
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
        cell.img.image = UIImage(named: imagePath)
        
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

