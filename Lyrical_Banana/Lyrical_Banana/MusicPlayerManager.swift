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
    
    var recievedFirstSpotifyAuth = false
    var needsSpotifyReauthorization = false
    
    var currentSong: SearchSongResult?
    var isPlaying:Bool = false
    var restartingSong:Bool = false
    
    var songPlayerViewControlDelegate: SongPlayerViewControlDelegate?
    var checkSelectedSongIsPlayingTimer:Timer? = nil
    
    // MARK: - MusicPlayerManager
        
    func restartSong() {
        // Restart song and pause at 0:00
        restartingSong = true
        self.playSong {
            self.pauseSong()
            self.restartingSong = false
        }
    }
    
    func startSelectedSongChecker() {
        checkSelectedSongIsPlayingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkSelectedSongIsPlaying), userInfo: nil, repeats: true)
    }

    // User could change the song via Spotify on their web or other device
    // This function checks if their originally selected song is still playing
    // Otherwise if another song is playing, switch to original
    @objc func checkSelectedSongIsPlaying()
    {
        if isPlaying {
            spotifyAppRemote.playerAPI?.delegate = self
            self.spotifyAppRemote.playerAPI?.getPlayerState({ result, error in
                let playerState = (result as! SPTAppRemotePlayerState)
                let songId:String = playerState.contextURI.absoluteString
                
                if songId != self.currentSong!.songId {
                    self.restartSong()
                }
            })
        }
    }
    
    func playSong(completionBlock: (() -> ())? = nil) {
        if checkSelectedSongIsPlayingTimer == nil {
            startSpotifySongChecker()
        }
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
    
    // MARK: - User Controls
    
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
    
    
    // Maybe remove this once you have the scrubbing implemented
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
