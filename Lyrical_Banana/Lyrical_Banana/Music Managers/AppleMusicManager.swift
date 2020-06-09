//
//  AppleMusicManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import MediaPlayer

class AppleMusicManager: NSObject, MusicServiceManager {
    let appleMusicPlayer: MPMusicPlayerApplicationController = MPMusicPlayerController.applicationQueuePlayer
    var didAddPlaybackStateObserver = false
    var isFirstStop = true
    
    // MARK: - Apple Music Manager

    func prepareToPlay() {
        appleMusicPlayer.setQueue(with: MPMusicPlayerStoreQueueDescriptor.init(storeIDs: [MusicPlayerManager.shared.currentSong!.songId]))
        appleMusicPlayer.prepareToPlay()
    }
    
    // MARK: - Music Service Manager

    func restartSong(success: ((Bool) -> ())?) {
        appleMusicPlayer.skipToBeginning()
        success?(true)
    }
    
    func checkCurrentSong() {
        MusicPlayerManager.shared.currentSongTimeSec = Int(appleMusicPlayer.currentPlaybackTime)
        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": true])
    }
    
    func playSong(success: ((Bool) -> ())?) {
        if !didAddPlaybackStateObserver {
            appleMusicPlayer.beginGeneratingPlaybackNotifications()
            NotificationCenter.default.addObserver(self, selector: #selector(appleMusicPlaybackStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            didAddPlaybackStateObserver = true
        }

        appleMusicPlayer.play()
        success?(true)
    }

    func pauseSong(success: ((Bool) -> ())?) {
        appleMusicPlayer.pause()
        success?(true)
    }
    
    func resumeSong(success: ((Bool) -> ())?) {
        appleMusicPlayer.play()
        success?(true)
    }
        
    func seekTo(newSongTime: Int, success: ((Bool) -> ())?) {
        appleMusicPlayer.currentPlaybackTime = TimeInterval.init(newSongTime)
        success?(true)
    }
    
    // MARK: - Apple Music
    
    @objc func appleMusicPlaybackStateDidChange(){
        let playbackState = appleMusicPlayer.playbackState
        
        // When the song is first played after song selection,
        // it is stopped for some reason by Apple Music
        if playbackState == .stopped && isFirstStop { isFirstStop = false; return }
        
        if playbackState == .playing {
            MusicPlayerManager.shared.isPlaying = true
            MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPlayOrResumeSong()
        } else if playbackState == .paused || playbackState == .interrupted {
            MusicPlayerManager.shared.isPlaying = false
            MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPauseSong()
        } else if playbackState == .stopped {
            MusicPlayerManager.shared.restartSong()
        }
    }

}
