
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
            pointsView.activePoint!.backgroundColor = pointsView.pointColor
            pointsView.activePoint = nil
        }
        pointsView.moveActivePointToLocation(posInStretch)
    }
    
    func doublePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self)
        let newCenter = CGPointMake(self.center.x+translation.x, self.center.y+translation.y)
        
        center = newCenter
        
        gesture.setTranslation(CGPointZero, inView: self)
    }
    
    func removePointsView() {
        pointsView.removeFromSuperview()
    }
    
    func setPointsCoordinates(coords: [CGPoint]) {
        pointsView.removeFromSuperview()
        pointsView = CroppableLayer(imageView: self)
        pointsView.addPointsAt(coords)
        
        addSubview(pointsView)
    }

}
