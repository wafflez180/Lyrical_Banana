//
//  GoogleImageSearchResult.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/10/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoogleImageSearchResult: NSObject {
    var fullImageLink: URL!
    var displayLink: URL!
    var thumbnailLink: URL!
    var thumbnailHeight: Int!
    var thumbnailWidth: Int!

    init(json: JSON) {
        super.init()
        self.fullImageLink = URL.init(string: json["link"].stringValue)!
        self.displayLink = URL.init(string: json["displayLink"].stringValue)!

        let imageDictionary = json["image"].dictionary!
        self.thumbnailLink = URL.init(string: imageDictionary["thumbnailLink"]!.stringValue)
        self.thumbnailHeight = imageDictionary["thumbnailHeight"]!.intValue
        self.thumbnailWidth = imageDictionary["thumbnailWidth"]!.intValue
    }
}
