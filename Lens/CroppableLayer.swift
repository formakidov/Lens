
import UIKit

class CroppableLayer: UIView {

    let k_POINT_WIDTH: CGFloat = 30
    
    var activePoint: UIView?
    
    var points = [UIView]()
    var isContainView = true
    let pointColor = UIColor.blueColor()
    let lineColor = UIColor.yellowColor()
    let lastBezierPath = UIBezierPath()
    //lastBezierPath = [UIBezierPath bezierPath];
    
    init(imageView: UIImageView) {
        super.init(frame: CGRectMake(0,0, imageView.frame.size.width, imageView.frame.size.height))
        
        userInteractionEnabled = true
        backgroundColor = UIColor.clearColor()
        clipsToBounds = true
        
        addPointsAt([CGPoint]()) // todo
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addPointsAt(coords: [CGPoint]) {
        var tmp = [UIView]()
        
        for i in 0..<coords.count {
            let pointToAdd = getPointView(i, at:coords[i])
            tmp.append(pointToAdd)
            addSubview(pointToAdd)
        }
        
        points = tmp
    }
    
    func getPointView(num: Int, at p: CGPoint) -> UIView {
        let point = UIView(frame: CGRectMake(p.x - k_POINT_WIDTH / 2, p.y - k_POINT_WIDTH / 2, k_POINT_WIDTH, k_POINT_WIDTH))
        point.alpha = 0.8
        point.backgroundColor = pointColor
        point.layer.borderColor = lineColor.CGColor
        point.layer.borderWidth = 4
        point.layer.cornerRadius = k_POINT_WIDTH / 2;
        
        let number = UILabel(frame: CGRectMake(0, 0, k_POINT_WIDTH, k_POINT_WIDTH))
        
        number.text = String(num)
        number.textColor = UIColor.whiteColor()
        number.backgroundColor = UIColor.clearColor()
        number.font = UIFont.systemFontOfSize(14)
        number.textAlignment = NSTextAlignment.Center;
        
        point.addSubview(number)
        
        return point
    }
    
    func getPointsCoords() -> [CGPoint] {
        var coords = [CGPoint]()
        
        for p in points {
            let coord = CGPointMake(p.frame.origin.x + k_POINT_WIDTH / 2, p.frame.origin.y + k_POINT_WIDTH / 2);
            coords.append(coord)
        }
        
        return coords
    }
    
    func resetPoints(num :Int) {
        let frameWidth = self.frame.size.width
        let frameHeight = self.frame.size.height
        
        points.removeAll()
        
        points.append(getPointView(0, at: CGPointMake(frameWidth * 0.2, frameHeight * 0.2)))
        points.append(getPointView(0, at: CGPointMake(frameWidth * 0.8, frameHeight * 0.2)))
        points.append(getPointView(0, at: CGPointMake(frameWidth * 0.8, frameHeight * 0.8)))
        points.append(getPointView(0, at: CGPointMake(frameWidth * 0.2, frameHeight * 0.8)))
        
        for p in points {
            addSubview(p)
        }
    }
    
    override func drawRect(rect: CGRect) {
        if (self.points.count == 0) {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, self.frame)
        let components = CGColorGetComponents(self.lineColor.CGColor);
        
        var red, green, blue, alpha: CGFloat
        
        if(CGColorGetNumberOfComponents(self.lineColor.CGColor) == 2) {
            red = 1
            green = 1
            blue = 1
            alpha = 1
        } else {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
            if (alpha <= 0) {
                alpha = 1
            }
        }
        
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        CGContextSetLineWidth(context, 2.0);
        
        let point1 = points[0]
        CGContextMoveToPoint(context, point1.frame.origin.x + k_POINT_WIDTH / 2, point1.frame.origin.y + k_POINT_WIDTH / 2);
        
        for p in points {
            CGContextAddLineToPoint(context, p.frame.origin.x + k_POINT_WIDTH/2, p.frame.origin.y + k_POINT_WIDTH/2);
        }
        
        CGContextAddLineToPoint(context, point1.frame.origin.x + k_POINT_WIDTH/2, point1.frame.origin.y + k_POINT_WIDTH/2);
        
        // tell the context to draw the stroked line
        CGContextStrokePath(context);
    }
    
    func distanceBetween(first: CGPoint, and last: CGPoint) -> CGFloat {
        var xDist = (last.x - first.x)
        if xDist < 0 {
            xDist *= -1
        }
        var yDist = (last.y - first.y)
        if yDist < 0 {
            yDist *= -1
        }
        return sqrt(xDist * xDist + yDist * yDist)
    }
    
    func findPointAtLocation(location: CGPoint) {
        activePoint!.backgroundColor = pointColor;
        activePoint = nil;
        var smallestDistance = CGFloat.infinity;
        
        for point in points {
            let extentedFrame = CGRectInset(point.frame, -20, -20);
            if (CGRectContainsPoint(extentedFrame, location))
            {
                let distanceToThis = distanceBetween(point.frame.origin, and:location)
                if distanceToThis < smallestDistance {
                    self.activePoint = point;
                    smallestDistance = distanceToThis;
                }
            }
        }
        if let active = activePoint {
            active.backgroundColor = UIColor.redColor()
        }
    }
    
    func moveActivePointToLocation(locationPoint: CGPoint) {
        var newX = locationPoint.x;
        var newY = locationPoint.y;
        //cap off possible values
        if newX < 0 {
            newX = 0
        } else if newX > self.frame.size.width {
            newX = self.frame.size.width;
        }
        if newY < 0 {
            newY = 0
        } else if newY > self.frame.size.height {
            newY = self.frame.size.height
        }
        
        let newLocPoint = CGPointMake(newX, newY);
        
        if let active = activePoint {
            active.frame = CGRectMake(newLocPoint.x - k_POINT_WIDTH/2, newLocPoint.y - k_POINT_WIDTH/2, k_POINT_WIDTH, k_POINT_WIDTH);
            setNeedsDisplay()
        }

    }
    
    func getPath() -> UIBezierPath? {
        if self.points.count == 0 {
            return nil
        }
        
        let points = getPointsCoords()
//        UIBezierPath *aPath = [UIBezierPath bezierPath];
        let aPath = UIBezierPath()
        // Set the starting point of the shape.
        let p1 = points[0]
        aPath.moveToPoint(CGPointMake(p1.x, p1.y))
        
        for point in points {
            aPath.addLineToPoint(CGPointMake(point.x, point.y));
        }
        
        aPath.closePath()
        
        return aPath
    }
    
    func maskImageView(image: UIImageView) {
        if let path = getPath() {
            var rect = CGRectZero;
            rect.size = image.image!.size;
            
            let shapeLayer = CAShapeLayer(layer: layer)
            
            shapeLayer.frame = CGRectMake(0, 0, image.frame.size.width, image.frame.size.height);
            shapeLayer.path = path.CGPath;
            shapeLayer.fillColor = UIColor.whiteColor().CGColor
            shapeLayer.backgroundColor = UIColor.clearColor().CGColor
            
            image.layer.mask = shapeLayer
        }
    }
    
}
