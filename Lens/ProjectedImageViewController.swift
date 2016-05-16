
import UIKit

class ProjectedImageViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var toSaveImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let b = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(ProjectedImageViewController.btnSave))
        self.navigationItem.setRightBarButtonItems([b], animated: true)
        
        imageView.image = toSaveImage!
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func btnSave() {
        if (!GalleryManager.addImage(imageView.image!)) {
            Utils.showAlert(self, title: "An error occured", message: "Cannot save image. Please try again", btnText: "OK")
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}
