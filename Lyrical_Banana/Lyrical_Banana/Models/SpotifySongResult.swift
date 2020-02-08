//
//  SpotifySong.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation
import SwiftyJSON

class SpotifySongResult: SearchSongResult {
    init(json: JSON) {
        super.init()
        self.name = json["name"].stringValue
        self.songId = json["uri"].stringValue
        self.durationMilliSec = json["duration_ms"].intValue
        self.albumImageLink = json["album"]["images"].array![2]["url"].stringValue
        
        for artistJSON in json["artists"].array! {
            self.artists.append(artistJSON["name"].stringValue)
        }
    }
}
