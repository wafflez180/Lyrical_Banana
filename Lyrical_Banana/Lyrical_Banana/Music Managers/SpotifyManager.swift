//
//  SpotifyManager.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class SpotifyManager: NSObject, MusicServiceManager, SPTAppRemoteDelegate {
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.delegate = self
                
        return appRemote
    }()

    var spotifyAccessToken = ""
    var recievedFirstSpotifyAuth = false
    
    // MARK: - Spotify Manager
    
    // MARK: - Music Service Manager
    
    func restartSong(success: ((Bool) -> ())?) {
        if !MusicPlayerManager.shared.restartingSong {
            MusicPlayerManager.shared.restartingSong = true
            playSong { successful in
                MusicPlayerManager.shared.restartingSong = false
                success?(successful)
            }
        }
    }
    
    func checkCurrentSong() {
        if appRemote.isConnected {
            appRemote.playerAPI?.getPlayerState({ result, error in
                if let playerState = result as? SPTAppRemotePlayerState {
                    // Needed when appWillResignActive and user comes back to the app
                    // and when user pauses/plays from other device
                    MusicPlayerManager.shared.isPlaying = !playerState.isPaused

                    // Check the correct song is playing
                    // (could be changed on different device or spotify automatically switched to new song after song ended)
                    let songId:String = playerState.contextURI.absoluteString
                    if songId != MusicPlayerManager.shared.currentSong!.songId {
                        MusicPlayerManager.shared.restartSong()
                    }
                    
                    // Sync the song time
                    let playbackPositionSec = playerState.playbackPosition / 1000
                    if abs(MusicPlayerManager.shared.currentSongTimeSec - playbackPositionSec) > 5 {
                        MusicPlayerManager.shared.currentSongTimeSec = playbackPositionSec
                        NotificationCenter.default.post(name: Notification.Name("didChangeSongTime"), object: nil, userInfo: ["animate": false])
                    } else {
                        MusicPlayerManager.shared.currentSongTimeSec = playbackPositionSec
                    }
                } else if let error = error {
                    ErrorManager.shared.presentErrorAlert(title: "Spotify Song Check Error", error: error)
                }
            })
        }
    }
    
    func playSong(success: ((Bool) -> ())?) {
        reauthorizeSpotifyIfNeeded()
        
        if MusicPlayerManager.shared.isRequestingToPlay { return }
        MusicPlayerManager.shared.isRequestingToPlay = true
        appRemote.playerAPI?.play(MusicPlayerManager.shared.currentSong!.songId, asRadio: false, callback: { result, error in
            if let _ = result {
                MusicPlayerManager.shared.isRequestingToPlay = false
                success?(true)
            }  else if let error = error {
                ErrorManager.shared.presentErrorAlert(title: "Spotify Play Song Error", error: error)
                success?(false)
            }
        })
    }

    func pauseSong(success: ((Bool) -> ())?) {
        reauthorizeSpotifyIfNeeded()

        MusicPlayerManager.shared.isPausing = true
        appRemote.playerAPI?.pause({ result, error in
            MusicPlayerManager.shared.isPausing = false
            if let _ = result {
                success?(true)
            } else if let error = error {
                success?(false)
                ErrorManager.shared.presentErrorAlert(title: "Spotify Pause Song Error", error: error)
            }
        })
    }
    
    func resumeSong(success: ((Bool) -> ())?) {
        reauthorizeSpotifyIfNeeded()

        MusicPlayerManager.shared.isResuming = true
        appRemote.playerAPI?.resume({ result, error in
            MusicPlayerManager.shared.isResuming = false
            if let _ = result {
                success?(true)
            } else if let error = error {
                success?(false)
                ErrorManager.shared.presentErrorAlert(title: "Spotify Resume Song Error", error: error)
            }
        })
    }
        
    func seekTo(newSongTime: Int, success: ((Bool) -> ())?) {
        MusicPlayerManager.shared.isSeeking = true
        appRemote.playerAPI?.seek(toPosition: newSongTime * 1000, callback: { result, error in
            MusicPlayerManager.shared.isSeeking = false
            if let _ = result {
                success?(true)
            } else if let error = error {
                ErrorManager.shared.presentErrorAlert(title: "Spotify Seek Error", error: error)
                success?(false)
            }
        })
    }
        
    // MARK: - Spotify Authorization
    
    func requestSpotifyAuthorization() {
        MusicPlayerManager.shared.restartingSong = false
        appRemote.authorizeAndPlayURI("")
    }
    
    func reauthorizeSpotifyIfNeeded() {
        if !appRemote.isConnected {
            MusicPlayerManager.shared.spotifyManager.requestSpotifyAuthorization()
        }
    }
        
    func failedSpotifyAuthorization(error: String) {
        print(error)
    }
    
    // MARK: - Spotify App Remote Delegate
    
    let SpotifyClientID = "f1b391b1630347c8894107725cd1009b"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    var isFirstConnection = true
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("[SPOTIFY] connected")
        if isFirstConnection {
            isFirstConnection = false
            appRemote.playerAPI?.pause()
        } else {
            if MusicPlayerManager.shared.didChangeSongTimeWhileDisconnected {
                MusicPlayerManager.shared.pauseSong()
                MusicPlayerManager.shared.seekTo(newSongTime: MusicPlayerManager.shared.currentSongTimeSec) { _ in
                    MusicPlayerManager.shared.resumeSong()
                    MusicPlayerManager.shared.didChangeSongTimeWhileDisconnected = false
                }
            }
            
            MusicPlayerManager.shared.restartingSong = false
            MusicPlayerManager.shared.isSeeking = false
            MusicPlayerManager.shared.isRequestingToPlay = false
            MusicPlayerManager.shared.isPausing = false
            MusicPlayerManager.shared.isResuming = false

            // Needed when appWillResignActive (user exits app) and then user comes back to the app
            appRemote.playerAPI?.getPlayerState({ result, error in
                if let playerState = result as? SPTAppRemotePlayerState {
                    MusicPlayerManager.shared.isPlaying = !playerState.isPaused
                    
                    if playerState.isPaused {
                        MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPauseSong()
                    } else if !playerState.isPaused {
                        MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPlayOrResumeSong()
                    }
                }
            })
            NotificationCenter.default.post(name: Notification.Name("spotifyDidReconnect"), object: nil, userInfo: nil)
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("[SPOTIFY] failed")
        if let error = error {
            ErrorManager.shared.presentErrorAlert(title: "Failed Spotify Authorization", error: error)
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("[SPOTIFY] disconnected")
        NotificationCenter.default.post(name: Notification.Name("spotifyDidDisconnecd"), object: nil, userInfo: nil)

        // iOS Limitation, after awhile if song is paused, iOS will disconnect spotify
        // https://github.com/spotify/ios-sdk/issues/140
        print(error)
        print(error?.localizedDescription)
    }

    // MARK: - Scene Delegate Funcs
    
    func sceneWillResignActive() {
        if appRemote.isConnected {
            MusicPlayerManager.shared.songPlayerViewControlDelegate?.didPauseSong()
            MusicPlayerManager.shared.pauseSong()
            appRemote.disconnect()
        }
    }
    
    func sceneDidBecomeActive() {
        if let _ = appRemote.connectionParameters.accessToken {
            appRemote.connect()
        }
    }
    
    func sceneDidDeeplink(withURL url: URL) {
        let parameters = appRemote.authorizationParameters(from: url);
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            // Successfully authorized from Spotify
            MusicPlayerManager.shared.selectedMusicService = .spotify

            appRemote.connectionParameters.accessToken = access_token
            spotifyAccessToken = access_token
            
            if !recievedFirstSpotifyAuth {
                recievedFirstSpotifyAuth = true // TODO: Find where this is used, seee if necessary
                appRemote.playerAPI?.pause()//didReceiveMusicServiceAuth
                NotificationCenter.default.post(name: Notification.Name("didReceiveMusicServiceAuth"), object: nil, userInfo: nil)
            }
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Failed authorization from Spotify
            ErrorManager.shared.presentErrorAlert(title: "Failed Spotify Authorization", errorDescription: errorDescription)
        }
    }
}
