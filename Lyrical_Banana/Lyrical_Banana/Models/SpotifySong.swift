//
//  SpotifySong.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation
import SwiftyJSON

class SpotifySong: NSObject {
    
    var name: String = ""
    var artists: [String] = []
    var spotifyURI: String = ""
    var albumImageLink: String = ""
    var durationMilliSec: Int = -1


    init(json: JSON) {
        name = json["name"].stringValue
        spotifyURI = json["uri"].stringValue
        durationMilliSec = json["duration_ms"].intValue
        albumImageLink = json["album"]["images"].array![2]["url"].stringValue
        
        for artistJSON in json["artists"].array! {
            artists.append(artistJSON["name"].stringValue)
        }
    }
}
