
import UIKit

class ProjectedImageViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var galleryManager: GalleryManager!
    
    var toSaveImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let b = UIBarButtonItem(title: "Save".localized, style: .Plain, target: self, action: #selector(ProjectedImageViewController.btnSave))
        navigationItem.setRightBarButtonItems([b], animated: true)
        
        imageView.image = toSaveImage!
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.enabled = false;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func btnSave() {
        if (galleryManager.addImage(imageView.image!)) {
            navigationController?.popToRootViewControllerAnimated(true)
        } else {
            Utils.showAlert(self, title: "An error occured".localized, message: "Cannot save image".localized, btnText: "OK")
        }
    }
    
}
