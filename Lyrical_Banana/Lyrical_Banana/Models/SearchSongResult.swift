//
//  File.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation
import SwiftyJSON

class SearchSongResult: NSObject {
    var name: String = ""
    var artists: [String] = []
    var artistLabelText: String = ""
    var songId: String = ""
    var albumImageLink: String = ""
    var durationMilliSec: Int = -1
    var durationSec: Int = -1
    var durationStr: String = ""
    
    var isSpotifySong: Bool {
        return songId.contains("spotify")
    }
    
    var isAppleMusicSong: Bool {
        return !songId.contains("spotify")
    }
    
    // MARK: - Helper Funcs
    
    func stringFromMilliSec(ms: Int) -> String {
        let time = NSInteger(ms / 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60

        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}
