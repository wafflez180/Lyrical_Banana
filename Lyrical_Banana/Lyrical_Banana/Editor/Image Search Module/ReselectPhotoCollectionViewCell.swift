//
//  ReselectPhotoCollectionViewCell.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/11/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class ReselectPhotoCollectionViewCell: UICollectionViewCell {
    @IBAction func didPressReselect(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("didPressReselectPhoto"), object: nil, userInfo: nil)
    }
}
