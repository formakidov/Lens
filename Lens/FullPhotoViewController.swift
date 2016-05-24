
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
        
        let del = UIBarButtonItem(image: UIImage(named: "Delete"), style: .Plain, target: self, action: #selector(FullPhotoViewController.btnDeleteImage))
        let share = UIBarButtonItem(image: UIImage(named: "Share"), style: .Plain, target: self, action: #selector(FullPhotoViewController.btnShareImage))
        let back = UIBarButtonItem(title: "Documents".localized, style: .Plain, target: nil, action: nil)
        
        navigationItem.setRightBarButtonItems([del, share], animated: true)
        if let nav = navigationController {
            nav.interactivePopGestureRecognizer?.enabled = false;
            nav.navigationBar.topItem?.backBarButtonItem = back
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func btnDeleteImage() {
        let deleteAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let popoverController = deleteAlert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        let deleteAction = UIAlertAction(title: "Delete".localized, style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            if (self.galleryManager.deleteImage(self.imagePath)) {
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                Utils.showAlert(self, title: "An error occured".localized, message: "Cannot delete image".localized, btnText: "WTF???")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        presentViewController(deleteAlert, animated: true, completion: nil)
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
