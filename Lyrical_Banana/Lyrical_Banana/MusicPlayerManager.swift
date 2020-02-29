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

class MusicPlayerManager: NSObject, SPTAppRemotePlayerStateDelegate {
    static let shared = MusicPlayerManager()
    
    let spotifyAppRemote = (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).appRemote
    var spotifyAccessToken = ""
    
    var authorizedSpotify = false
    var needsSpotifyReauthorization = false
    
    var currentSong: SearchSongResult?
    var isPlaying:Bool = false
    var restartingSong:Bool = false
    
    var songPlayerViewControlDelegate: SongPlayerViewControlDelegate?

    // MARK: - MusicPlayerManager
        
    func restartSong() {
        // Restart song and pause at 0:00
        restartingSong = true
        self.playSong {
            self.pauseSong()
            self.restartingSong = false
        }
    }
    
    func playSong(completionBlock: (() -> ())? = nil) {
        if currentSong!.songId.contains("spotify") {
            reauthorizeSpotifyIfNeeded()
            spotifyAppRemote.playerAPI?.play(currentSong!.songId, asRadio: false, callback: { result, error in
                self.isPlaying = true
                print("playSongplaySong")
//                print(result)
//                print(error)
                print(error)
                print(error?.localizedDescription)
                
                self.spotifyAppRemote.playerAPI?.delegate = self
                self.spotifyAppRemote.playerAPI?.subscribe(toPlayerState: { result, error in
                    print("subscribeToPlayerState")
                    
                    print(result)
                    print(error)
                })
            })
        } else {
            // TODO PLAY APPLE MUSIC
        }
        
        songPlayerViewControlDelegate?.didPlaySong()
    }
    
    func pauseSong(){
        reauthorizeSpotifyIfNeeded()

        isPlaying = false
        spotifyAppRemote.playerAPI?.pause({ result, error in
            print("puasSOOOOONG")
//            print(result)// TODO: DETECT WHEN A SONG ENDS AND ALSO IMPLEMENT FAST FORWARD AND BACKWARD
//            print(error)
        })
        
        songPlayerViewControlDelegate?.didPauseSong()
    }
    
    func resumeSong(){
        reauthorizeSpotifyIfNeeded()

        isPlaying = true
        

        spotifyAppRemote.playerAPI?.resume({ result, error in
            print("resumeSong")
//            print(result)
//            print(error)
        })
    }
    
    func seekBackwards10Seconds() {
        reauthorizeSpotifyIfNeeded()

        spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
            let playerState = (result as! SPTAppRemotePlayerState)
//            print(result)
//            print(error)
//
//            print(playerState.playbackPosition)
//            print(playerState.playbackPosition)
            
            // REWINDS BY 10 Seconds
            self.spotifyAppRemote.playerAPI?.seek(toPosition: playerState.playbackPosition - 10000, callback: { result, error in
//                print(result)
//                print(error)
            })
        })
    }

    func seekForwards10Seconds() {
        reauthorizeSpotifyIfNeeded()
        
        spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
            let playerState = (result as! SPTAppRemotePlayerState)
//            print(result)
//            print(error)
//
//            print(playerState.playbackPosition)
//            print(playerState.playbackPosition)
            
            // REWINDS BY 10 Seconds
            self.spotifyAppRemote.playerAPI?.seek(toPosition: playerState.playbackPosition + 10000, callback: { result, error in
//                print(result)
//                print(error)
            })
        })
    }
    
    // MARK: - SPTAppRemotePlayerStateDelegate
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        //debugPrint("PREPRE [SPOTIFY] Track name: %@", playerState.track.name)
        if (currentSong == nil || restartingSong) { return }
        debugPrint("[SPOTIFY] Track name: %@", playerState.track.name)
        
        let songId:String = playerState.contextURI.absoluteString
        if songId != currentSong!.songId {
            print("SONG DID END")
            restartSong()
        }
    }
    
    // MARK: - Spotify General
        
    func appDidExitAndReconnectToSpotify() {
        // TODO: Instead of simply replaying, go back to previous playBackPosition
        
        // If a song was played while outisde our app, when user comes back, reset to our song
        spotifyAppRemote.playerAPI?.delegate = self
        self.spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
            let playerState = (result as! SPTAppRemotePlayerState)
            let songId:String = playerState.contextURI.absoluteString
            
            if songId != self.currentSong!.songId {
                self.restartSong()
            } else if !self.needsSpotifyReauthorization {
                // If while in app Spotify disconnects, user resumes music, reauthorize and play music without pause
                // TODO: Update playbackHeadPosition according to playerState or go back to prev playbackPosition
                //self.restartSong()
                self.pauseSong()
            }
        })
    }
    
    // MARK: - Spotify Authorization
    
    func reauthorizeSpotifyIfNeeded() {
        if !spotifyAppRemote.isConnected {
            needsSpotifyReauthorization = true
            requestSpotifyAuthorization()
        }
    }

    func requestSpotifyAuthorization() {
        spotifyAppRemote.authorizeAndPlayURI("")
    }
        
    func failedSpotifyAuthorization(error: String) {
        print(error)
    }
    
    func didAuthorizeSpotify() {
        // Should I keep the playerStateDidChange method and delegate in MusicPlayer or SceneDelegate?
        if authorizedSpotify {
            // iOS Limitation, after awhile if song is paused, iOS will disconnect spotify
            // https://github.com/spotify/ios-sdk/issues/140
            // The app has reauthorized Spotify due to disconnection
            appDidExitAndReconnectToSpotify()
        } else {
            authorizedSpotify = true
            spotifyAppRemote.playerAPI?.delegate = self
            spotifyAppRemote.playerAPI?.pause()
            
            NotificationCenter.default.post(name: Notification.Name("authorizedSpotify"), object: nil, userInfo: nil)
        }
    }
    
    // MARK: - App States

    func appWillResignActive(){
        if spotifyAppRemote.isConnected {
            MusicPlayerManager.shared.pauseSong()
            spotifyAppRemote.disconnect()
        }
    }

    func appDidBecomeActive(){
        if let _ = spotifyAppRemote.connectionParameters.accessToken {
            spotifyAppRemote.connect()
        }
    }
}
