
import UIKit

class FullPhotoViewController: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var shareManager: ShareManager!
    var galleryManager: GalleryManager!
    var imagePath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: imagePath)
        imageView.contentMode = .ScaleAspectFit
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        
        let del = UIBarButtonItem(title: "Delete".localized, style: .Plain, target: self, action: #selector(FullPhotoViewController.btnDeleteImage))
        let share = UIBarButtonItem(title: "Share".localized, style: .Plain, target: self, action: #selector(FullPhotoViewController.btnShareImage))
        
        navigationItem.setRightBarButtonItems([share, del], animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func btnDeleteImage() {
        if (galleryManager.deleteImage(imagePath)) {
            navigationController?.popToRootViewControllerAnimated(true)
        } else {
            Utils.showAlert(self, title: "An error occured".localized, message: "Cannot delete image".localized, btnText: "WTF???")
        }
    }
    
    func btnShareImage() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        let path = imagePath
        
        let fbAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareManager.shareFacebook(self, path: path)
        })
        let dropAction = UIAlertAction(title: "Dropbox", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FullPhotoViewController.shareDropbox), name: "isDropboxLinked", object: nil)
            self.shareDropbox()
        })
        let twiAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareManager.shareTwitter(self, path: path)
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
        
        alertController.addAction(fbAction)
        alertController.addAction(dropAction)
        alertController.addAction(twiAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func shareDropbox() {
        shareManager.shareDropbox(self, path: imagePath)
    }

}
