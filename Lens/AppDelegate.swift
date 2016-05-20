
import UIKit
import CoreData
import FBSDKCoreKit
import Fabric
import TwitterKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Twitter.self])
        Dropbox.setupWithAppKey(Constants.TWITTER_KEY)
        Dropbox.unlinkClient()
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.saveContext()
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        onDropboxLoginComplete(url)
        return false
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        onDropboxLoginComplete(url)
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func onDropboxLoginComplete(url: NSURL) {
        if let authResult = Dropbox.handleRedirectURL(url) {
            var isDropboxLinked: Bool
            switch authResult {
            case .Success(let token):
                isDropboxLinked = true
                print("Success! User is logged into Dropbox with token: \(token)")
            case .Error(let error, let description):
                isDropboxLinked = false
                print("Error \(error): \(description)")
            }
            NSNotificationCenter.defaultCenter().postNotificationName("isDropboxLinked", object: NSNumber(bool: isDropboxLinked))
        }
    }
    
}

