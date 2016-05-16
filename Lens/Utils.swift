
import Foundation

class Utils {
    
    static func generateImageFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return "\(paths[0])/\(Utils.randomString(Constants.IMAGE_FILE_PATH_LENGTH))\(Constants.IMAGE_FILE_SUFFIX)"
    }
    
    static func showAlert(controller: UIViewController, title: String, message: String, btnText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: btnText, style:.Default, handler: nil)
        alert.addAction(ok)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func currentTimeMillis() -> Int64 {
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    static func randomString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    static func fixOrientation(image: UIImage) -> UIImage {
        if image.imageOrientation == .Up {
            return image
        }
        var transform = CGAffineTransformIdentity
        
        switch image.imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch (image.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1);
        default:
            break;
        }
        
        let ctx = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage).rawValue)
        
        CGContextConcatCTM(ctx, transform)
        
        switch (image.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
        }
        
        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg!)
        
        return img
    }
        
}