
import Foundation
import FBSDKCoreKit
import FBSDKShareKit
import TwitterKit
import SwiftyDropbox

class ShareManager : NSObject {
    
    func shareFacebook(controller: UIViewController, path: String) {
        let photo = FBSDKSharePhoto()
        photo.image = UIImage(named: path)
        photo.userGenerated = true
        
        let content = FBSDKSharePhotoContent()
        content.photos = [photo]
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = controller
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.ShareSheet
        dialog.show()
    }
    
    func shareTwitter(controller: UIViewController, path: String) {
        let composer = TWTRComposer()
        composer.setImage(UIImage(named: path))
        composer.showFromViewController(controller) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            } else {
                print("Sending tweet!")
            }
        }
    }
    
    func shareDropbox(controller: UIViewController, path: String) {
        if let client = Dropbox.authorizedClient {
            print("Uploading")
            
            let fromIndex = path.endIndex.advancedBy(-15)
            let imageName = path.substringFromIndex(fromIndex) // path contains slash, ten symbols and ".png"
            let url : NSURL = NSURL(string: path)!
            
            client.files.upload(path: imageName, body: url).response{response, error in
                if let metadata = response {
                    print("Uploaded file name: \(metadata.name)")
                } else {
                    print(error!)
                }
            }
        } else {
            print("Authorization")
            Dropbox.authorizeFromController(controller)
        }
    }
}