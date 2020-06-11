//
//  ImageSearchViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkeletonView

class ImageSearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var clearTextButton: UIButton!
    @IBOutlet var imageResultsCollectionView: UICollectionView!
    
    var imageSearchResults: [GoogleImageSearchResult] = []
    
    var selectedCell: ImageSearchResultCollectionViewCell?
    var nextSearchIndex = 10
    var nextSearchPageResultCount = 10
    var isSearchingImages = false
    let searchLimit = 100

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageResultsCollectionView.delegate = self
        imageResultsCollectionView.dataSource = self

        searchTextField.delegate = self
        
        clearTextButton.isHidden = true
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: searchTextField.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        if let flowLayout = imageResultsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.itemSize = CGSize(width: 120, height: 120)
//        }
    }
    
    // MARK: - ImageSearchViewController
        
    // MARK: - Actions
    
    @IBAction func pressedClearTextButton(_ sender: Any) {
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
        clearTextButton.isHidden = true
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = selectedCell {
            cell.removeHighlightBorder()
        }
        
        selectedCell = collectionView.cellForItem(at: indexPath) as? ImageSearchResultCollectionViewCell
        selectedCell?.addHighlightBorder()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numOfCellsToPassToLoadMoreImages = numOfCells() - nextSearchPageResultCount - 6
        if imageSearchResults.count > 0 && indexPath.row > numOfCellsToPassToLoadMoreImages && !isSearchingImages {
            loadImages(withStartIndex: nextSearchIndex)
        }
    }

    // MARK: - SkeletonCollectionViewDataSource / UICollectionViewDataSource
    
    func numOfCells() -> Int {
        if imageSearchResults.count > 0 {
            if nextSearchIndex > searchLimit {
                return imageSearchResults.count
            } else {
                return imageSearchResults.count + nextSearchPageResultCount
            }
        } else {
            return 0
        }
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfCells()
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfCells()
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ImageSearchResult"
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSearchResult", for: indexPath) as! ImageSearchResultCollectionViewCell
        
        // If user has scrolled past the loaded results, show skeletionview
        if indexPath.row >= imageSearchResults.endIndex {
            cell.showLoadingAnimation()
        } else {
            cell.configureCell(withSearchResult: imageSearchResults[indexPath.row])
        }
        
        return cell
    }
        
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let idealCellWidth = 175
        let cellPerRow = Int(ceil(collectionView.frame.size.width / CGFloat(idealCellWidth)))
        let contentWidthWithoutSpacing = collectionView.contentSize.width - flowLayout.minimumInteritemSpacing
        let cellWidth = CGFloat(contentWidthWithoutSpacing / CGFloat(cellPerRow))
        
        return CGSize(width: cellWidth, height: cellWidth)
    }

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            let wasHidden = clearTextButton.isHidden
            clearTextButton.isHidden = updatedText.count == 0
            
            if updatedText.count != 0 && wasHidden {
                clearTextButton.alpha = 0.0
                UIView.animate(withDuration: 0.4) {
                    self.clearTextButton.alpha = 1.0
                }
            }
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // TODO: perform google search request
        
        if let searchText = textField.text {
            if searchText.count > 0 {
                imageSearchResults = []
                loadImages(withStartIndex: 0)
            }
        }
        
        searchTextField.endEditing(true)
        
        return true
    }
    
    // MARK: Google API
    
    func loadImages(withStartIndex startIndex: Int) {
        if isSearchingImages || startIndex > searchLimit { return }
        
        // Other Google custom search parameter options: (like imgSize: large)
        // https://developers.google.com/custom-search/v1/reference/rest/v1/cse/list
        let googleApiKey = "AIzaSyDTUH29lE_1oOPlF3_nEmlddk2sA6UXNG0"//"AIzaSyABmRCsK1sBT7cGBW2hgY6Lovjl-RmNDsw"
        let customSearchEngineId = "003510071416855038274:pfhissroehu"
        let params = ["q": searchTextField.text!, "start": String(startIndex), "searchType": "image", "key": googleApiKey, "cx": customSearchEngineId]
                
        // TODO: When user has bad connection and the request doesn't go through, pop up an alert
        isSearchingImages = true
        AF.request("https://www.googleapis.com/customsearch/v1", method: .get, parameters: params, encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil).response { response in
            self.isSearchingImages = false
            let jsonResponse = JSON.init(response.value!)
            
            //print(jsonResponse)
            //print(startIndex)
            let prevSearchItemCount = self.imageSearchResults.count
            
            //let searchItemsCount = jsonResponse["queries"]["request"][0]["count"].intValue
                //let searchItemsStartIndex = queriesDictionary["request"]!["startIndex"].intValue
            let nextPageCount = jsonResponse["queries"]["nextPage"][0].dictionary!["count"]!.intValue
            let nextPageStartIndex = jsonResponse["queries"]["nextPage"][0].dictionary!["startIndex"]!.intValue
            self.nextSearchIndex = nextPageStartIndex
            self.nextSearchPageResultCount = nextPageCount

            if let searchItemsJSONArray = jsonResponse["items"].array {
                for searchItemJSON in searchItemsJSONArray {
                    self.imageSearchResults.append(GoogleImageSearchResult.init(json: searchItemJSON))
                }
            }
            
            if startIndex == 0 {
                self.imageResultsCollectionView.reloadData()
            } else {
                var reloadIndexPathList: [IndexPath] = []
                let newSearchItemCount = self.imageSearchResults.count - prevSearchItemCount
                
                for i in stride(from: 1, through: newSearchItemCount, by: 1) {
                    reloadIndexPathList.append(IndexPath.init(row: self.imageSearchResults.count - i, section: 0))
                }
                self.imageResultsCollectionView.reloadItems(at: reloadIndexPathList)
            }
        }
    }
}
