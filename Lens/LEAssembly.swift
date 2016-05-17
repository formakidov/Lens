
import Foundation
import Typhoon

class LEAssembly : TyphoonAssembly {
    
    internal dynamic func shareManager() -> AnyObject {
        return TyphoonDefinition.withClass(ShareManager.self) {
            (definition) in
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    internal dynamic func galleryManager() -> AnyObject {
        return TyphoonDefinition.withClass(GalleryManager.self) {
            (definition) in
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    internal dynamic func viewController() -> AnyObject {
        return TyphoonDefinition.withClass(ViewController.self) {
            (definition) in
            definition.injectProperty(#selector(LEAssembly.galleryManager), with:self.galleryManager())
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    internal dynamic func fullPhotoViewController() -> AnyObject {
        return TyphoonDefinition.withClass(FullPhotoViewController.self) {
            (definition) in
            definition.injectProperty(#selector(LEAssembly.shareManager), with:self.shareManager())
            definition.injectProperty(#selector(LEAssembly.galleryManager), with:self.galleryManager())
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    internal dynamic func projectedImageViewController() -> AnyObject {
        return TyphoonDefinition.withClass(ProjectedImageViewController.self) {
            (definition) in
            definition.injectProperty(#selector(LEAssembly.galleryManager), with:self.galleryManager())
            definition.scope = TyphoonScope.Singleton
        }
    }
}