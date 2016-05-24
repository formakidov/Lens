import UIKit
import MBProgressHUD

class CropperViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: CroppableImageView!
    
    var toCropImage: UIImage!
    var finalImage: UIImage?
    
    var pointsOnImage:[CGPoint] = []
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        dispatch_async(dispatch_get_main_queue(), {
            var points: [CGPoint]
            if (self.pointsOnImage.count == 4) {
                points = self.calculatePoints()
                self.imageView.setPointsCoordinates(points)
            } else {
                self.imageView.resetPointsView()
                points = self.imageView.pointsView.getPointsCoords()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let save = UIBarButtonItem(title: "Done".localized, style: .Plain, target: self, action: #selector(CropperViewController.projectImage))
        let back = UIBarButtonItem(title: "Documents".localized, style: .Plain, target: nil, action: nil)
        
        navigationItem.setRightBarButtonItem(save, animated: true)
        if let nav = navigationController {
            nav.interactivePopGestureRecognizer?.enabled = false;
            nav.navigationBar.topItem?.backBarButtonItem = back
        }
        
        displayImage()
    }
    
    func displayImage() {
        navigationItem.rightBarButtonItem?.enabled = false
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Loading image..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.toCropImage = Utils.fixOrientation(self.toCropImage)
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.imageView.image = self.toCropImage
                self.detectBorders()
            })
        })
    }
    
    func detectBorders() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Detecting bounds..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let imageSize = self.toCropImage.size
            var points: [CGPoint] = []
            
            let detected = CVWrapper().detectEdges(self.toCropImage, size: imageSize)
            if (detected.count == 4) {
                for point in detected {
                    self.pointsOnImage.append(point.CGPointValue())
                }
                points = self.calculatePoints()
            } else {
                self.imageView.resetPointsView()
                points = self.imageView.pointsView.getPointsCoords()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.imageView.setPointsCoordinates(points)
            })
            
        })

    }
    
    func projectImage() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Processing..."
        
        navigationItem.rightBarButtonItem?.enabled = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let points = self.getSelectedCoordsInPixels()
            
            self.finalImage = CVWrapper().processImageWithOpenCV(self.toCropImage, points: UnsafeMutablePointer(points)) as UIImage
            
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.performSegueWithIdentifier("projected", sender: self)
            })
        })
    }
    
    func calculatePoints() -> [CGPoint] {
        var points: [CGPoint] = []
        
        let imageSize = toCropImage.size
        
        let rect = imageView.calculateRectOfImageInImageView()
        let xRatio = imageSize.width / rect.width
        let yRatio = imageSize.height / rect.height
        
        let margins = imageView.getImageMargins()
        
        for p in pointsOnImage {
            points.append(CGPointMake(p.x / xRatio + margins.left, p.y / yRatio + margins.top))
        }
        
        return points
    }
    
    func getSelectedCoordsInPixels() -> [CGPoint] {
        let cropPoints = imageView.pointsView.getPointsCoords()
        var points: [CGPoint] = []
        
        let rect = imageView.calculateRectOfImageInImageView()
        let imageSize = toCropImage.size
        let xRatio = imageSize.width / rect.width
        let yRatio = imageSize.height / rect.height
        
        let margins = imageView.getImageMargins()
        
        for p in cropPoints {
            points.append(CGPointMake((p.x - margins.left) * xRatio, (p.y - margins.top) * yRatio))
        }
        
        return points
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "projected") {
            let pvc = segue.destinationViewController as! ProjectedImageViewController
            pvc.toSaveImage = finalImage
        }
    }
    
}
