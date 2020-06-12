//
//  ImageSearchResultCollectionViewCell.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/10/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Photos
import SkeletonView

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
            
    func configureCell(withPhotoAsset photoAsset: PHAsset) {
        if photoImageView.image == nil {
            let skeletonAnimation = GradientDirection.topLeftBottomRight.slidingAnimation()
            self.showAnimatedGradientSkeleton(usingGradient: SkeletonAppearance.default.gradient, animation: skeletonAnimation, transition: .none)
        }
        
        let imageRequestOptions = PHImageRequestOptions.init()
        imageRequestOptions.isNetworkAccessAllowed = true // if image stored in iCloud
        imageRequestOptions.deliveryMode = .highQualityFormat
        imageRequestOptions.resizeMode = .none
        imageRequestOptions.isSynchronous = false
        
        PHImageManager.default().requestImage(for: photoAsset, targetSize: self.frame.size, contentMode: .aspectFit, options: imageRequestOptions) { image, imageInfoDict in
            if let image = image {
                self.hideSkeleton()
                self.photoImageView.image = image
            }
            if let errorDesc = imageInfoDict?[PHImageErrorKey] as? String {
                ErrorManager.shared.presentErrorAlert(title: "Photo Retreival Error", errorDescription: errorDesc)
            }
        }
    }
}
