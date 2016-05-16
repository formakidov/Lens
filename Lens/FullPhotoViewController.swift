
import UIKit

class FullPhotoViewController: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var imagePath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: imagePath)
        imageView.contentMode = .ScaleAspectFit
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        
        let del = UIBarButtonItem(title: "Delete", style: .Plain, target: self, action: #selector(FullPhotoViewController.btnDeleteImage))
        let share = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(FullPhotoViewController.btnShareImage))
        
        self.navigationItem.setRightBarButtonItems([share, del], animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func btnDeleteImage() {
        if (!GalleryManager.deleteImage(imagePath)) {
            Utils.showAlert(self, title: "An error occured", message: "Cannot delete image. Please try again", btnText: "WTF???")
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func btnShareImage() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
        let path = self.imagePath
        
        let fbAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            ShareManager.shareFacebook(self, path: path)
        })
        let dropAction = UIAlertAction(title: "Dropbox", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FullPhotoViewController.shareDropbox), name: "isDropboxLinked", object: nil)
            self.shareDropbox()
        })
        let twiAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            ShareManager.shareTwitter(self, path: path)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(fbAction)
        alertController.addAction(dropAction)
        alertController.addAction(twiAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func shareDropbox() {
        ShareManager.shareDropbox(self, path: self.imagePath)
    }

}