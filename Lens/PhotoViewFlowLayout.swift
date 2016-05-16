
import UIKit

class PhotoViewFlowLayout: UICollectionViewFlowLayout {

    override var itemSize: CGSize {
        set {
            
        }
        get {
            var numberOfColumns: CGFloat = UIDevice.currentDevice().orientation == .Portrait ? 3 : 5
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
                numberOfColumns += 1
            }
            let itemWidth = (self.collectionView!.frame.width - 5) / numberOfColumns

            return CGSizeMake(itemWidth, itemWidth)
        }
    }
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .Vertical
    }
    
}
