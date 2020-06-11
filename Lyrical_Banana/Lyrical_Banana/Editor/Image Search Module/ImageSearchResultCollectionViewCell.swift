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

class ImageSearchResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var photoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var photoImageViewHeightConstraint: NSLayoutConstraint!
    
    func configureCell(withPhotoAsset photoAsset: PHAsset) {
        let skeletonAnimation = GradientDirection.topLeftBottomRight.slidingAnimation()
        self.showAnimatedGradientSkeleton(usingGradient: SkeletonAppearance.default.gradient, animation: skeletonAnimation, transition: .none)
                
        let imageRequestOptions = PHImageRequestOptions.init()
        imageRequestOptions.isNetworkAccessAllowed = true // if image stored in iCloud
        imageRequestOptions.deliveryMode = .highQualityFormat
        imageRequestOptions.resizeMode = .none
        imageRequestOptions.isSynchronous = false
        PHImageManager.default().requestImage(for: photoAsset, targetSize: self.frame.size, contentMode: .aspectFit, options: imageRequestOptions) { image, imageInfoDict in
            if let image = image {
                self.hideSkeleton()
                self.photoImageView.image = image
                
                // Set constraints such that when borderWidth is set, it surrounds the image (instead of a square imageView)
                if image.size.width > image.size.height {
                    self.photoImageViewWidthConstraint.constant = self.frame.size.width
                    self.photoImageViewHeightConstraint.constant = self.frame.size.height * (image.size.height / image.size.width)
                } else {
                    self.photoImageViewWidthConstraint.constant = self.frame.size.width * (image.size.width / image.size.height)
                    self.photoImageViewHeightConstraint.constant = self.frame.size.height
                }
                self.layoutIfNeeded()
            }
            if let errorDesc = imageInfoDict?[PHImageErrorKey] as? String {
                ErrorManager.shared.presentErrorAlert(title: "Photo Retreival Error", errorDescription: errorDesc)
            }
        }
        
        photoImageView.borderWidth = 0
    }
    
    func addHighlightBorder() {
        photoImageView.borderWidth = 4
    }
    
    func removeHighlightBorder() {
        photoImageView.borderWidth = 0
    }
}
