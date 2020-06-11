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

class ImageSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var photosCollectionView: UICollectionView!
    
    var photoAssetList = [PHAsset]()
    var selectedCell: ImageSearchResultCollectionViewCell?

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPhotoAssets), name: Notification.Name("willHideSelectSongView"), object: nil)
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
        
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = selectedCell {
            cell.removeHighlightBorder()
        }
        
        selectedCell = collectionView.cellForItem(at: indexPath) as? ImageSearchResultCollectionViewCell
        selectedCell?.addHighlightBorder()
    }

    // MARK: - UICollectionViewDataSource
        
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssetList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSearchResult", for: indexPath) as! ImageSearchResultCollectionViewCell
        
        cell.configureCell(withPhotoAsset: photoAssetList[indexPath.row])
        
        return cell
    }
        
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Fit as many cells with width of 175 within the collectionView's width
        // After you get # of cells that fit, place them into the collectionView's width and fill the gaps between
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let idealCellWidth = 175
        let cellPerRow = Int(ceil(collectionView.frame.size.width / CGFloat(idealCellWidth)))
        let contentWidthWithoutSpacing = collectionView.contentSize.width - flowLayout.minimumInteritemSpacing
        let cellWidth = CGFloat(contentWidthWithoutSpacing / CGFloat(cellPerRow))
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
