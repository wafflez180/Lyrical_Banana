//
//  SceneDelegate.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate {

    var window: UIWindow?

    // MARK: - Spotify
    
    let SpotifyClientID = "f1b391b1630347c8894107725cd1009b"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    var isFirstConnection = true
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.delegate = self
      return appRemote
    }()

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("[SPOTIFY] connected")
        if isFirstConnection {
            isFirstConnection = false
            MusicPlayerManager.shared.pauseSong()
        } else {
            //MusicPlayerManager.shared.appDidExitAndReconnectToSpotify()
            NotificationCenter.default.post(name: Notification.Name("spotifyDidReconnect"), object: nil, userInfo: nil)
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("[SPOTIFY] failed")
        MusicPlayerManager.shared.failedSpotifyAuthorization(error: error!.localizedDescription)
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("[SPOTIFY] disconnected")
        NotificationCenter.default.post(name: Notification.Name("spotifyDidDisconnecd"), object: nil, userInfo: nil)

        // iOS Limitation, after awhile if song is paused, iOS will disconnect spotify
        // https://github.com/spotify/ios-sdk/issues/140
        print(error)
        print(error?.localizedDescription)
    }
    
    // MARK: - Scene Delegate

    func sceneWillResignActive(_ scene: UIScene) {
      MusicPlayerManager.shared.appWillResignActive()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      MusicPlayerManager.shared.appDidBecomeActive()
    }
    
    // Deeplink and request authorization to the Spotify App
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = appRemote.authorizationParameters(from: url);
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            // Successfully authorized from Spotify
            appRemote.connectionParameters.accessToken = access_token
            MusicPlayerManager.shared.spotifyAccessToken = access_token
            
            if !MusicPlayerManager.shared.recievedFirstSpotifyAuth {
                MusicPlayerManager.shared.recievedFirstSpotifyAuth = true
                MusicPlayerManager.shared.spotifyAppRemote.playerAPI?.pause()
                NotificationCenter.default.post(name: Notification.Name("recievedFirstSpotifyAuth"), object: nil, userInfo: nil)
            }
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Failed authorization from Spotify
            MusicPlayerManager.shared.failedSpotifyAuthorization(error: error_description)
        }
    }
    
    // MARK: - Not Utilized

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

