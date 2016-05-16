import UIKit

class CropperViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: JBCroppableImageView!
    var toCropImage: UIImage!
    var finalImage: UIImage?
    var pointsOnImage:[CGPoint] = []
    
    @IBAction func scaleImage(sender: UIPinchGestureRecognizer) {
        self.imageView.transform = CGAffineTransformScale(self.imageView.transform, sender.scale, sender.scale)
        sender.scale = 1
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        dispatch_async(dispatch_get_main_queue(), {
            var points: [CGPoint]
            if (self.pointsOnImage.count == 4) {
                points = self.calculatePoints()
            } else {
                points = self.getDefaultPoints()
            }
            self.imageView.setPointsCoordinates(UnsafeMutablePointer(points))
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let b = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: #selector(CropperViewController.projectImage))
        self.navigationItem.setRightBarButtonItems([b], animated: true)
        
        imageView.removePointsView()
        
        displayImage()
    }
    
    func displayImage() {
        navigationItem.rightBarButtonItem?.enabled = false
        let indicator = startIndicator()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.toCropImage = Utils.fixOrientation(self.toCropImage)
            dispatch_async(dispatch_get_main_queue(), {
                indicator.stopAnimating()
                self.imageView.image = self.toCropImage
                self.detectBorders()
            })
        })
    }
    
    func detectBorders() {
        let indicator = startIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let imageSize = self.toCropImage.size
            var points: [CGPoint] = []
            
            let detected = CVWrapper().detectEdges(self.toCropImage, size: imageSize)
            if (detected.count == 4) {
                for point in detected as! [NSValue] {
                    self.pointsOnImage.append(point.CGPointValue())
                }
                points = self.calculatePoints()
            } else {
                points = self.getDefaultPoints()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                indicator.stopAnimating()
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.imageView.setPointsCoordinates(UnsafeMutablePointer(points))
            })
            
        })

    }
    
    func startIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        
        return indicator
    }
    
    func projectImage() {
        let indicator = startIndicator()
        navigationItem.rightBarButtonItem?.enabled = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let points = self.getCropperPoints()
            
            self.finalImage = CVWrapper().processImageWithOpenCV(self.toCropImage, points: UnsafeMutablePointer(points)) as UIImage
            
            dispatch_async(dispatch_get_main_queue(), {
                indicator.stopAnimating()
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.performSegueWithIdentifier("projected", sender: self)
            })
        })
    }
    
    func getDefaultPoints() -> [CGPoint] {
        let imageViewSize = self.imageView.frame.size
        let width = imageViewSize.width
        let height = imageViewSize.height
        let points: [CGPoint] = [
            CGPoint(x: width * 0.2, y: height * 0.8),
            CGPoint(x: width * 0.8, y: height * 0.8),
            CGPoint(x: width * 0.8, y: height * 0.2),
            CGPoint(x: width * 0.2, y: height * 0.2)]
        
        return points
    }
    
    func calculatePoints() -> [CGPoint] {
        var points: [CGPoint] = []
        
        let imageSize = self.toCropImage.size
        
        let rect = self.calculateRectOfImageInImageView(self.imageView)
        let xRatio = imageSize.width / rect.width
        let yRatio = imageSize.height / rect.height
        
        let margins = self.getImageMarginsInImageView()
        
        for i in (0...3).reverse() {
            points.append(CGPointMake(self.pointsOnImage[i].x / xRatio + margins.left, self.pointsOnImage[i].y / yRatio + margins.top))
        }
        
        return points
    }
    
    func getCropperPoints() -> [CGPoint] {
        let cropPoints = self.imageView.getPoints()
        var points: [CGPoint] = []
        
        let rect = self.calculateRectOfImageInImageView(self.imageView)
        let imageSize = self.toCropImage.size
        let xRatio = imageSize.width / rect.width
        let yRatio = imageSize.height / rect.height
        
        let margins = getImageMarginsInImageView()
        
        if let downcastNSValueArray = cropPoints as? [NSValue] {
            for i in 0 ..< downcastNSValueArray.count {
                let p = downcastNSValueArray[i]
                points.append(CGPointMake((p.CGPointValue().x - margins.left) * xRatio, (p.CGPointValue().y - margins.top) * yRatio))
            }
        }
        
        return points
    }
    
    func getImageMarginsInImageView() -> (top: CGFloat, left: CGFloat) {
        let rect = self.calculateRectOfImageInImageView(self.imageView)
        let imageViewSize = self.imageView.bounds.size
        let margins = (top: (imageViewSize.height - rect.height) / 2, left: (imageViewSize.width - rect.width) / 2)
        return margins
    }
    
    func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size
        
        guard let imageSize = imgSize where imgSize != nil else {
            return CGRectZero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y
        
        return imageRect
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "projected") {
            let pvc = segue.destinationViewController as! ProjectedImageViewController
            pvc.toSaveImage = finalImage
        }
    }
    
}
