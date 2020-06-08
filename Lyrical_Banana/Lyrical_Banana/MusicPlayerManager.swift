//
//  MusicPlayerManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/23/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import Foundation
import MediaPlayer

protocol SongPlayerViewControlDelegate {
    func didPauseSong()
    func didPlayOrResumeSong()
}

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    
    let spotifyAppRemote = (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).appRemote
    var spotifyAccessToken = ""
    var recievedFirstSpotifyAuth = false
    
    let appleMusicPlayer: MPMusicPlayerApplicationController = MPMusicPlayerController.applicationQueuePlayer
    
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
    
    // MARK: - MusicPlayerManager
        
    func restartSong() {
        // Restart song and pause at 0:00
        if currentSong!.isSpotifySong {
            if !restartingSong {
                restartingSong = true
                self.playSong { success in
                    self.restartingSong = false
                    
                    if success {
                        self.pauseSong() // TODO: Add option to not pause aka repeatedly replay the song
                        self.currentSongTimeSec = 0
                        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
                    }
                }
            }
        } else if currentSong!.isAppleMusicSong {
            self.pauseSong()
            appleMusicPlayer.skipToBeginning()
            self.currentSongTimeSec = 0
            NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
        }
    }
        
    func startCheckSongTimer() {
        checkSongTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkCurrentSong), userInfo: nil, repeats: true)
    }

    // Checks that the selected song is still playing (could be changed from other device)
    // and syncs the current song time and other data
    @objc func checkCurrentSong() {
        if self.spotifyAppRemote.isConnected {
            self.spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
                if let playerState = result as? SPTAppRemotePlayerState {
                    // Needed when appWillResignActive and user comes back to the app
                    // and when user pauses/plays from other device
                    self.isPlaying = !playerState.isPaused

                    // Check the correct song is playing
                    // (could be changed on different device or spotify automatically switched to new song after song ended)
                    let songId:String = playerState.contextURI.absoluteString
                    if songId != self.currentSong!.songId {
                        self.restartSong()
                    }
                    
                    // Sync the song time
                    let playbackPositionSec = playerState.playbackPosition / 1000
                    if abs(self.currentSongTimeSec - playbackPositionSec) > 5 {
                        self.currentSongTimeSec = playbackPositionSec
                        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
                    } else {
                        self.currentSongTimeSec = playbackPositionSec
                    }
                } else if let error = error {
                    self.presentErrorAlert(title: "Spotify Song Check Error", error: error)
                }
            })
        } else if currentSong!.isAppleMusicSong {
            currentSongTimeSec = Int(appleMusicPlayer.currentPlaybackTime)
            NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": true])
        }
    }
    
    func playSong(success: ((Bool) -> ())? = nil) {
        if checkSongTimer == nil {
            startCheckSongTimer()
        }
        if currentSong!.isSpotifySong {
            reauthorizeSpotifyIfNeeded()
            
            if isRequestingToPlay { return }
            isRequestingToPlay = true
            spotifyAppRemote.playerAPI?.play(currentSong!.songId, asRadio: false, callback: { result, error in
                if let _ = result {
                    self.isRequestingToPlay = false
                    self.isPlaying = true
                    self.songPlayerViewControlDelegate?.didPlayOrResumeSong()

                    success?(true)
                }  else if let error = error {
                    self.presentErrorAlert(title: "Spotify Play Song Error", error: error)
                    success?(false)
                }
            })
        } else {
            // TODO: PLAY APPLE MUSIC
//            MPMusicPlayerController.applicationMusicPlayer.repeatMode = .
//            MPMusicPlayerController.applicationMusicPlayer.skipToBegginging
           // MPMusicPlayerController.applicationMusicPlayer.playbackState
//            appleMusicPlayer.setQueue(with: MPMusicPlayerStoreQueueDescriptor.init(storeIDs: [currentSong!.songId]))
//            appleMusicPlayer.prepareToPlay { error in
//                if let error = error { self.presentErrorAlert(title: "Apple Music Play Song Error", error: error) } else {
            
//            if
            // Warning, obserserver may be added twice if the user selects a new song again during editing
            MusicPlayerManager.shared.appleMusicPlayer.beginGeneratingPlaybackNotifications()
            NotificationCenter.default.addObserver(self, selector: #selector(appleMusicPlaybackStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)

            self.appleMusicPlayer.play()
//                }
//            }
        }
    }
    
    // MARK: - Apple Music
    
    @objc func appleMusicPlaybackStateDidChange(){
        /*
        MPMusicPlaybackStateStopped,
        MPMusicPlaybackStatePlaying,
        MPMusicPlaybackStatePaused,
        MPMusicPlaybackStateInterrupted,
        MPMusicPlaybackStateSeekingForward,
        MPMusicPlaybackStateSeekingBackward*/
        let playbackState = appleMusicPlayer.playbackState
        if playbackState == .playing {
            isPlaying = true
            songPlayerViewControlDelegate?.didPlayOrResumeSong()
        } else if playbackState == .paused || playbackState == .interrupted {
            isPlaying = false
            songPlayerViewControlDelegate?.didPauseSong()
        } else if playbackState == .stopped {
            restartSong()
        }
    }
    
    // MARK: - User Controls
    
    func pauseSong(){
        if currentSong!.isSpotifySong {
            reauthorizeSpotifyIfNeeded()
            if isPausing || !isPlaying || isResuming || isSeeking { return }

            isPausing = true
            spotifyAppRemote.playerAPI?.pause({ result, error in
                self.isPausing = false
                print("Paused Song")
                if let _ = result {
                    self.isPlaying = false
                    self.songPlayerViewControlDelegate?.didPauseSong()
                } else if let error = error { self.presentErrorAlert(title: "Spotify Pause Song Error", error: error) }
            })
        } else if currentSong!.isAppleMusicSong {
            appleMusicPlayer.pause()
            self.isPlaying = false
            self.songPlayerViewControlDelegate?.didPauseSong()
        }
    }
    
    func resumeSong(){
        if currentSong!.isSpotifySong {
            reauthorizeSpotifyIfNeeded()
            if isResuming || isPlaying || isPausing || isSeeking { return }

            isResuming = true
            spotifyAppRemote.playerAPI?.resume({ result, error in
                self.isResuming = false
                print("Resumed Song")
                if let _ = result {
                    self.isPlaying = true
                    self.songPlayerViewControlDelegate?.didPlayOrResumeSong()
                } else if let error = error { self.presentErrorAlert(title: "Spotify Resume Song Error", error: error) }
            })
        } else if currentSong!.isAppleMusicSong {
            appleMusicPlayer.play()
            self.isPlaying = true
            self.songPlayerViewControlDelegate?.didPlayOrResumeSong()
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
        let wasPaused = !self.isPlaying
        
        if currentSong!.isSpotifySong {
            isSeeking = true
            self.spotifyAppRemote.playerAPI?.seek(toPosition: newSongTime * 1000, callback: { result, error in
                self.isSeeking = false
                if let _ = result {
                    // If song is paused, then manually move the time indicator, else allow the checkCurrentSong to sync with the moving indicator
                    if wasPaused {
                        self.currentSongTimeSec = newSongTime
                        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
                    } else {
                        self.checkCurrentSong()
                    }
                    
                    success?(true)
                } else if let error = error {
                    self.presentErrorAlert(title: "Spotify Seek Error", error: error)
                    success?(false)
                }
            })
        } else if currentSong!.isAppleMusicSong {
            appleMusicPlayer.currentPlaybackTime = TimeInterval.init(newSongTime)
            self.currentSongTimeSec = newSongTime
            NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
            success?(true)
        }
    }
        
    // MARK: - Spotify Authorization
    
    func reauthorizeSpotifyIfNeeded() {
        if !self.spotifyAppRemote.isConnected {
            self.requestSpotifyAuthorization()
        }
    }

    func requestSpotifyAuthorization() {
        self.restartingSong = false
        self.spotifyAppRemote.authorizeAndPlayURI("")
    }
        
    func failedSpotifyAuthorization(error: String) {
        print(error)
    }
        
    // MARK: - App States

    func appWillResignActive(){
        if spotifyAppRemote.isConnected {
            self.songPlayerViewControlDelegate?.didPauseSong()
            pauseSong()
            spotifyAppRemote.disconnect()
        }
    }

    func appDidBecomeActive(){
        if let _ = spotifyAppRemote.connectionParameters.accessToken {
            spotifyAppRemote.connect()
        }
    }
    
    // MARK: - Error Handling
    
    func presentErrorAlert(title: String, error: Error){
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller

            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
