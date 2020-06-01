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
    func didPlaySong()
}

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()
    
    let spotifyAppRemote = (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).appRemote
    var spotifyAccessToken = ""
    
    var recievedFirstSpotifyAuth = false
    var needsSpotifyReauthorization = false
    
    var currentSong: SearchSongResult?
    var isPlaying:Bool = false
    var restartingSong:Bool = false
    var isSeeking:Bool = false
    var currentSongTimeSec = 0
    let seekForwardBackwardSecAmount = 10
    var checkCurrentSongTimer:Timer? = nil

    var songPlayerViewControlDelegate: SongPlayerViewControlDelegate?
    
    // MARK: - MusicPlayerManager
        
    func restartSong() {
        // Restart song and pause at 0:00
        if !restartingSong {
            restartingSong = true
            self.playSong {
                self.pauseSong() // TODO: Add option to not pause aka repeatedly replay the song
                self.currentSongTimeSec = 0
                NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: nil)
            }
        }
    }
        
    func startCurrentSongChecker() {
        checkCurrentSongTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkCurrentSong), userInfo: nil, repeats: true)
    }

    // Checks that the selected song is still playing (could be changed from other device)
    // and syncs the current song time
    @objc func checkCurrentSong()
    {
        if self.isPlaying {
            self.spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
                let playerState = (result as! SPTAppRemotePlayerState)
                let songId:String = playerState.contextURI.absoluteString
                
                if songId != self.currentSong!.songId {
                    self.restartSong()
                }
                
                // Sync the song time
                let playbackPositionSec = playerState.playbackPosition / 1000
                if abs(self.currentSongTimeSec - playbackPositionSec) > 5 {
                    self.currentSongTimeSec = playbackPositionSec
                    NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: nil)
                } else {
                    self.currentSongTimeSec = playbackPositionSec
                }
            })
        }
    }
    
    func playSong(completionBlock: (() -> ())? = nil) {
        if checkCurrentSongTimer == nil {
            startCurrentSongChecker()
        }
        if currentSong!.songId.contains("spotify") {
            reauthorizeSpotifyIfNeeded()
                        
            spotifyAppRemote.playerAPI?.play(currentSong!.songId, asRadio: false, callback: { result, error in
                self.isPlaying = true
                self.restartingSong = false
                
                completionBlock?()
            })
        } else {
            // TODO PLAY APPLE MUSIC
        }
        
        songPlayerViewControlDelegate?.didPlaySong()
    }
    
    // MARK: - User Controls
    
    func pauseSong(){
        isPlaying = false
        spotifyAppRemote.playerAPI?.pause({ result, error in
            print("Paused Song")
        })
        
        songPlayerViewControlDelegate?.didPauseSong()
    }
    
    func resumeSong(){
        reauthorizeSpotifyIfNeeded()
        isPlaying = true

        spotifyAppRemote.playerAPI?.resume({ result, error in
            print("Resumed Song")
        })
    }
    
    func seekBackwards10Seconds() {
        if (isSeeking) { return }
        reauthorizeSpotifyIfNeeded()

        isSeeking = true
        self.spotifyAppRemote.playerAPI?.seek(toPosition: (self.currentSongTimeSec - self.seekForwardBackwardSecAmount) * 1000, callback: { result, error in
            self.isSeeking = false
            
            // If song is paused, then manually move the time indicator, else allow the checkCurrentSong to sync with the moving indicator
            if !self.isPlaying {
                self.currentSongTimeSec -= self.seekForwardBackwardSecAmount
                if self.currentSongTimeSec < 0 {
                    self.currentSongTimeSec = 0
                }
                NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: nil)
            } else {
                self.checkCurrentSong()
            }
        })
    }

    func seekForwards10Seconds() {
        if (isSeeking) { return }
        reauthorizeSpotifyIfNeeded()
        
        isSeeking = true
        self.spotifyAppRemote.playerAPI?.seek(toPosition: (self.currentSongTimeSec + self.seekForwardBackwardSecAmount) * 1000, callback: { result, error in
            self.isSeeking = false
            
            // If song is paused, then manually move the time indicator, else allow the checkCurrentSong to sync with the moving indicator
            if !self.isPlaying {
                self.currentSongTimeSec += self.seekForwardBackwardSecAmount
                if self.currentSongTimeSec > self.currentSong!.durationSec {
                    self.currentSongTimeSec = self.currentSong!.durationSec
                }
                NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: nil)
            } else {
                self.checkCurrentSong()
            }
        })
    }
        
    // MARK: - Spotify Authorization
    
    func reauthorizeSpotifyIfNeeded() {
        if !self.spotifyAppRemote.isConnected {
            self.needsSpotifyReauthorization = true
            self.requestSpotifyAuthorization()
        }
    }

    func requestSpotifyAuthorization() {
        self.spotifyAppRemote.authorizeAndPlayURI("")
    }
        
    func failedSpotifyAuthorization(error: String) {
        print(error)
    }
        
    // MARK: - App States

    func appWillResignActive(){
        if spotifyAppRemote.isConnected {
            self.pauseSong()
            spotifyAppRemote.disconnect()
        }
    }

    func appDidBecomeActive(){
        if let _ = spotifyAppRemote.connectionParameters.accessToken {
            spotifyAppRemote.connect()
        }
    }
}
