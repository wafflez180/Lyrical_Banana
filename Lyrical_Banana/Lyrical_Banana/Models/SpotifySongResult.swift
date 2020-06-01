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
        self.durationSec = json["duration_ms"].intValue / 1000
        self.durationStr = stringFromMilliSec(ms: json["duration_ms"].intValue)
        self.albumImageLink = json["album"]["images"].array![2]["url"].stringValue
        
        for artistJSON in json["artists"].array! {
            let artistName = artistJSON["name"].stringValue
            self.artists.append(artistJSON["name"].stringValue)
            
            artistLabelText += artistName
            if (json["artists"].array!.last?["name"].stringValue)! != artistName {
                artistLabelText += ", "
            }
        }
    }
    
    func stringFromMilliSec(ms: Int) -> String {
        let time = NSInteger(ms / 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60

        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}
