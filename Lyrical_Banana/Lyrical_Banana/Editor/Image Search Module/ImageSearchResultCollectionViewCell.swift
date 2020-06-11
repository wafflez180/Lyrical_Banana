//
//  ImageSearchResultCollectionViewCell.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/10/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class ImageSearchResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewBotConstraint: NSLayoutConstraint!
    
    func showLoadingAnimation() {
        if !isSkeletonActive {
            imageViewTopConstraint.isActive = true
            imageViewBotConstraint.isActive = true
            imageViewLeftConstraint.isActive = true
            imageViewRightConstraint.isActive = true

            let animation = GradientDirection.topLeftBottomRight.slidingAnimation()
            self.showAnimatedGradientSkeleton(usingGradient: SkeletonAppearance.default.gradient, animation: animation, transition: .none)
        }
    }
    
    func configureCell(withSearchResult searchResult: GoogleImageSearchResult) {
        if isSkeletonActive {
            hideSkeleton(transition: .crossDissolve(0.25))
        }
        
        imageView.kf.setImage(with: searchResult.thumbnailLink)
        
        /* TODO: When user has poor connection, show the skeleton view
        imageView.kf.setImage(with: <#T##Source?#>, placeholder: nil, options: nil, progressBlock: nil) { result, error in
            <#code#>
        }*/
        
        imageView.borderWidth = 0
        
        if searchResult.thumbnailHeight > searchResult.thumbnailWidth {
            imageViewTopConstraint.isActive = true
            imageViewBotConstraint.isActive = true
            imageViewLeftConstraint.isActive = false
            imageViewRightConstraint.isActive = false
        } else {
            imageViewTopConstraint.isActive = false
            imageViewBotConstraint.isActive = false
            imageViewLeftConstraint.isActive = true
            imageViewRightConstraint.isActive = true
        }
    }
    
    func addHighlightBorder() {
        imageView.borderWidth = 4
    }
    
    func removeHighlightBorder() {
        imageView.borderWidth = 0
    }
}
