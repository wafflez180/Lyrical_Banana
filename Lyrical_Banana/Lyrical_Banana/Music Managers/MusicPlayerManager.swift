//
//  MusicPlayerManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/23/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation

protocol SongPlayerViewControlDelegate {
    func didPauseSong()
    func didPlayOrResumeSong()
}

protocol MusicServiceManager {
    func checkCurrentSong()
    func restartSong(success: ((Bool) -> ())?)
    
    func playSong(success: ((Bool) -> ())?)
    func pauseSong(success: ((Bool) -> ())?)
    func resumeSong(success: ((Bool) -> ())?)
    func seekTo(newSongTime: Int, success: ((Bool) -> ())?)
}

enum MusicService {
    case appleMusic
    case spotify
}

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    
    let appleMusicManager: AppleMusicManager = AppleMusicManager()
    let spotifyManager: SpotifyManager = SpotifyManager()
    
    var selectedMusicService: MusicService?
    var musicService: MusicServiceManager? {
        get {
            if let musicService = selectedMusicService {
                if musicService == .appleMusic {
                    return appleMusicManager
                } else if musicService == .spotify {
                    return spotifyManager
                }
            }
            return nil
        }
    }
        
    var currentSong: SearchSongResult?
    var isPlaying: Bool = false
    var currentSongTimeSec = 0
    let seekForwardBackwardSecAmount = 10

    var restartingSong: Bool = false
    var isRequestingToPlay: Bool = false
    var isSeeking: Bool = false
    var isPausing: Bool = false
    var isResuming: Bool = false
    
    var checkSongTimer: Timer? = nil
    
    var didChangeSongTimeWhileDisconnected = false

    var songPlayerViewControlDelegate: SongPlayerViewControlDelegate?
    
    // MARK: - Music Player Manager
        
    func restartSong() {
        // Restart song and pause at 0:00
        // TODO: Add option to not pause aka repeatedly replay the song
        
        musicService!.restartSong { success in
            if success {
                MusicPlayerManager.shared.pauseSong()
                MusicPlayerManager.shared.currentSongTimeSec = 0
                NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
            }
        }
    }
        
    func startCheckSongTimer() {
        checkSongTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkCurrentSong), userInfo: nil, repeats: true)
    }

    // Checks that the selected song is still playing (could be changed from other device)
    // and syncs the current song time and other data
    @objc func checkCurrentSong() {
        musicService!.checkCurrentSong()
    }
    
    func playSong(success: ((Bool) -> ())? = nil) {
        if checkSongTimer == nil {
            startCheckSongTimer()
        }
        
        // TODO: For some reason, not playing for Apple Music?
        // Check prev commit implementation of Apple Music, might help
        musicService!.playSong { success in
            if success {
                MusicPlayerManager.shared.isPlaying = true
                MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPlayOrResumeSong()
            }
        }
    }
        
    // MARK: - User Controls
    
    func pauseSong(){
        if isPausing || !isPlaying || isResuming || isSeeking { return }

        musicService!.pauseSong { success in
            if success {
                self.isPlaying = false
                self.songPlayerViewControlDelegate?.didPauseSong()
            }
        }
    }
    
    func resumeSong(){
        if isPausing || isPlaying || isResuming || isSeeking { return }

        musicService!.resumeSong { success in
            if success {
                self.isPlaying = true
                self.songPlayerViewControlDelegate?.didPlayOrResumeSong()
            }
        }
    }
    
    func seekBackwards10Seconds() {
        var newSongTime = self.currentSongTimeSec - self.seekForwardBackwardSecAmount
        if newSongTime < 0 {
            newSongTime = 0
        }
        
        seekTo(newSongTime: newSongTime)
    }

    func seekForwards10Seconds() {
        let newSongTime = self.currentSongTimeSec + self.seekForwardBackwardSecAmount
        if newSongTime > self.currentSong!.durationSec {
            self.currentSongTimeSec = self.currentSong!.durationSec
            NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
            restartSong()
        } else {
            seekTo(newSongTime: newSongTime)
        }
    }
    
    func seekTo(newSongTime: Int, success: ((Bool) -> ())? = nil) {
        if (isSeeking) { return }
        
        musicService!.seekTo(newSongTime: newSongTime) { successful in
            if successful {
                self.currentSongTimeSec = newSongTime
                NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
            }
            success?(successful)
        }
    }
                        
    // MARK: - Error Handling
    
    func presentErrorAlert(title: String, error: Error){
        presentErrorAlert(title: title, errorDescription: error.localizedDescription)
    }
    
    func presentErrorAlert(title: String, errorDescription: String){
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller

            let alert = UIAlertController(title: title, message: errorDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
