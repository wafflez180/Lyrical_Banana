//
//  AppleMusicSongResult.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppleMusicSongResult: SearchSongResult {
    init(json: JSON) {
        super.init()
        self.name = json["trackName"].stringValue
        self.songId = json["trackId"].stringValue
        self.durationMilliSec = json["trackTimeMillis"].intValue
        self.albumImageLink = json["artworkUrl100"].stringValue
        self.artists = [json["artistName"].stringValue]
    }
}
