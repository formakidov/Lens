
import UIKit

class CroppableImageView: UIImageView, UIGestureRecognizerDelegate {

    var pointsView: CroppableLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        pointsView = CroppableLayer(imageView: self)
        
        addSubview(pointsView)
        
        let singlePan = UIPanGestureRecognizer(target: self, action: #selector(CroppableImageView.singlePan(_:)))
        singlePan.delegate = self
        singlePan.maximumNumberOfTouches = 1
        addGestureRecognizer(singlePan)
        
        let doublePan = UIPanGestureRecognizer(target: self, action: #selector(CroppableImageView.doublePan(_:)))
        doublePan.maximumNumberOfTouches = 2
        addGestureRecognizer(singlePan)
    }
    
    func singlePan(gesture: UIPanGestureRecognizer) {
        let posInStretch = gesture.locationInView(pointsView)
        if (gesture.state == UIGestureRecognizerState.Began) {
            pointsView.findPointAtLocation(posInStretch)
        }
        if (gesture.state == UIGestureRecognizerState.Ended) {
            pointsView.activePoint?.backgroundColor = pointsView.pointColor
            pointsView.activePoint = nil
        }
        pointsView.moveActivePointToLocation(posInStretch)
    }
    
    func doublePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self)
        let newCenter = CGPointMake(center.x+translation.x, center.y+translation.y)
        
        center = newCenter
        
        gesture.setTranslation(CGPointZero, inView: self)
    }
    
    func removePointsView() {
        pointsView.removeFromSuperview()
    }
    
    func resetPointsView() {
        pointsView.removeFromSuperview()
        pointsView = CroppableLayer(imageView: self)
        pointsView.resetPoints()
        
        addSubview(pointsView)
    }
    
    func setPointsCoordinates(coords: [CGPoint]) {
        guard coords.count == 4 else {
            return
        }
        
        pointsView.removeFromSuperview()
        pointsView = CroppableLayer(imageView: self)
        pointsView.addPointsAt(coords)
        
        addSubview(pointsView)
    }
    
    func getImageMargins() -> (top: CGFloat, left: CGFloat) {
        let rect = calculateRectOfImageInImageView()
        let imageViewSize = bounds.size
        let margins = (top: (imageViewSize.height - rect.height) / 2, left: (imageViewSize.width - rect.width) / 2)
        return margins
    }
    
    func calculateRectOfImageInImageView() -> CGRect {
        let imageViewSize = frame.size
        let imgSize = image?.size
        
        guard let imageSize = imgSize where imgSize != nil else {
            return CGRectZero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        imageRect.origin.x += frame.origin.x
        imageRect.origin.y += frame.origin.y
        
        return imageRect
    }

}
