//
//  SceneDelegate.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

protocol SpotifyControllerDelegate: UIViewController {
    func receivedAccessToken(accessToken: String)
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    var window: UIWindow?

    // MARK: - Spotify
    let SpotifyClientID = "f1b391b1630347c8894107725cd1009b"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    var accessToken:String?
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      return appRemote
    }()

    var spotifyControllerDelegate: SpotifyControllerDelegate?
    
    
    func authorizeAndConnect(spotifyController: SpotifyControllerDelegate){
        self.appRemote.authorizeAndPlayURI("")
        self.spotifyControllerDelegate = spotifyController
    }
        
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("[SPOTIFY] connected")
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
          if let error = error {
            debugPrint(error.localizedDescription)
          }
        })
        
        self.spotifyControllerDelegate?.receivedAccessToken(accessToken: self.accessToken!)
        appRemote.playerAPI?.pause()
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
      print("[SPOTIFY] disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
      print("[SPOTIFY] failed")
    }
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
      debugPrint("[SPOTIFY] Track name: %@", playerState.track.name)
    }
    
    // MARK: - Scene Delegate
    
    func applicationWillResignActive(_ application: UIApplication) {
      if self.appRemote.isConnected {
        self.appRemote.disconnect()
      }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      if let _ = self.appRemote.connectionParameters.accessToken {
        self.appRemote.connect()
      }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
      if let _ = self.appRemote.connectionParameters.accessToken {
        self.appRemote.connect()
      }
        }

    func sceneWillResignActive(_ scene: UIScene) {
      if self.appRemote.isConnected {
        self.appRemote.disconnect()
      }
    }


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

