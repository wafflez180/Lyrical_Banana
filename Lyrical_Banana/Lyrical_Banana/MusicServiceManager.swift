//
//  MusicServiceManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class MusicServiceManager: NSObject {
    @objc func checkCurrentSong() {}
    
    func restartSong() {
        self.pauseSong() // TODO: Add option to not pause aka repeatedly replay the song
        self.currentSongTimeSec = 0
        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
    }
}
