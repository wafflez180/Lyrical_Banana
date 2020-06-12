//
//  SelectedImageCollectionViewCell.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/12/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import SkeletonView
import Photos

class SelectedImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var selectedImageWidthConstraint: NSLayoutConstraint!
    
    func configureCell(withPhotoAsset photoAsset: PHAsset) {
        if selectedImageView.image == nil {
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
                self.selectedImageView.image = image
                
                // Adjust width to match image so the border can wrap around image instead of imageView
                let widthToHeightRatio = image.size.width / image.size.height
                self.selectedImageWidthConstraint.constant = self.frame.size.height * widthToHeightRatio
                self.layoutIfNeeded()
            }
            if let errorDesc = imageInfoDict?[PHImageErrorKey] as? String {
                ErrorManager.shared.presentErrorAlert(title: "Photo Retreival Error", errorDescription: errorDesc)
            }
        }
    }
}
