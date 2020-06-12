//
//  ImageSearchViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import SkeletonView
import Photos

class ImageSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var imageSelectionHeaderLabel: UILabel!
    @IBOutlet var imageIconImageView: UIImageView!
    
    @IBOutlet var collectionViewBotConstraint: NSLayoutConstraint!
    @IBOutlet var photosCollectionView: UICollectionView!
    @IBOutlet var tapToReselectLabel: UILabel!
    
    let collectionViewLeftRightSectionInset: CGFloat = 10
    var photoAssetList = [PHAsset]()
    
    var selectedPhotoAsset: PHAsset?

    var isTopModule = false

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        imageSelectionHeaderLabel.isHighlighted = true
        imageIconImageView.isHighlighted = true
        tapToReselectLabel.alpha = 0.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPhotoAssets), name: Notification.Name("willHideSelectSongView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willSwapEditingModules), name: Notification.Name("swapEditingModules"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPhotoAssets()
    }
    
    // MARK: - ImageSearchViewController
    
    @objc func getPhotoAssets() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
           // self.cameraAssets.add(object)
            self.photoAssetList.append(object)
        })

        // Reverse to get latest images first
        self.photoAssetList.reverse()

        self.photosCollectionView.reloadData()
    }
        
    @objc func willSwapEditingModules() {
        isTopModule = !isTopModule
        imageSelectionHeaderLabel.isHighlighted = !isTopModule
        imageIconImageView.isHighlighted = !isTopModule
        photosCollectionView.isUserInteractionEnabled = !isTopModule
        photosCollectionView.showsVerticalScrollIndicator = !isTopModule
        
        if isTopModule {
            photosCollectionView.isHidden = true
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.tapToReselectLabel.alpha = 1.0
            }) { completed in
                self.photosCollectionView.isHidden = false
                self.photosCollectionView.reloadData()
                self.photosCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0) , at: .top, animated: false)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.tapToReselectLabel.alpha = 0.0
            }
            photosCollectionView.reloadData()
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            if isTopModule {
                NotificationCenter.default.post(name: Notification.Name("swapEditingModules"), object: nil, userInfo: nil)
            }
        }
    }
        
    // MARK: - UICollectionViewDelegate
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhotoAsset = photoAssetList[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name("swapEditingModules"), object: nil, userInfo: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isTopModule && section == 1 {
            return UIEdgeInsets.init(top: 10, left: collectionViewLeftRightSectionInset, bottom: 0, right: collectionViewLeftRightSectionInset)
        } else {
            return UIEdgeInsets.init(top: 0, left: collectionViewLeftRightSectionInset, bottom: 0, right: collectionViewLeftRightSectionInset)
        }
    }
    
    // MARK: - UICollectionViewDataSource
            
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isTopModule {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isTopModule && section == 0 {
            return 1
        } else {
            return photoAssetList.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isTopModule && indexPath.section == 0 {
            let selectedImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedImage", for: indexPath) as! SelectedImageCollectionViewCell
            selectedImageCell.configureCell(withPhotoAsset: selectedPhotoAsset!)
            
            return selectedImageCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSearchResult", for: indexPath) as! ImageCollectionViewCell
            cell.configureCell(withPhotoAsset: photoAssetList[indexPath.row])
            
            return cell
        }
    }
        
    // MARK: - UICollectionViewDelegateFlowLayout
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Fit as many cells with width of 175 within the collectionView's width
        // After you get # of cells that fit, place them into the collectionView and expand the widths to fill the gaps
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let idealCellWidth = 175
        let sectionLeftRightInset = collectionViewLeftRightSectionInset * 2
        let cellPerRow = Int(ceil((collectionView.frame.size.width) / CGFloat(idealCellWidth)))
        let contentWidthWithoutSpacing = collectionView.contentSize.width - flowLayout.minimumInteritemSpacing - sectionLeftRightInset
        let cellWidth = CGFloat(contentWidthWithoutSpacing / CGFloat(cellPerRow))
        
        if isTopModule && indexPath.section == 0 {
            let newCollectionViewHeight = EditorViewController.topModuleHeight - collectionView.frame.origin.y - collectionViewBotConstraint.constant
            return CGSize(width: contentWidthWithoutSpacing, height: newCollectionViewHeight)
        } else {
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
}
