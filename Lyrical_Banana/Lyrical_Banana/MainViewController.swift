//
//  MainViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton
import Alamofire

class MainViewController: UIViewController {
    
    @IBOutlet var launchToMainTransitionView: UIView!

    static var bananaLabelOrigin:CGPoint?
    static var bananaImageViewOrigin:CGPoint?

    @IBOutlet var editorContainerView: UIView!
    @IBOutlet var videoListContainerView: UIView!
    
    @IBOutlet var lyricalBananaLabel: UILabel!
    @IBOutlet var bananaImageView: UIImageView!
    @IBOutlet var noVideosCreatedLabel: UILabel!
    @IBOutlet var createNewVideoButton: PMSuperButton!
    
    @IBOutlet var musicServiceView: UIView!
    @IBOutlet var selectSongView: UIView!
    
    static var authorizedAppleMusic = false
    static var authorizedSpotify = false
    var selectedSong:SearchSongResult?
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.bananaLabelOrigin = self.view.convert(lyricalBananaLabel.frame.origin, to: launchToMainTransitionView)
        MainViewController.bananaImageViewOrigin = self.view.convert(bananaImageView.frame.origin, to: launchToMainTransitionView)
        
        self.editorContainerView.isHidden = true
        self.musicServiceView.isHidden = true
        self.selectSongView.isHidden = true
        
        self.createNewVideoButton.isHidden = true
        self.noVideosCreatedLabel.isHidden = true
        self.lyricalBananaLabel.isHidden = true
        self.bananaImageView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedSpotify), name: Notification.Name("authorizedSpotify"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedAppleMusic), name: Notification.Name("authorizedAppleMusic"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(launchTransitionDidComplete), name: Notification.Name("launchTransitionComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectSong), name: Notification.Name("didSelectSong"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: - MainViewController

    func musicPlatformToSelectSongTransition(accessToken:String?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.musicServiceView.alpha = 0.0
            }) { completed in
                self.musicServiceView.isHidden = false
                
                var userInfo:[AnyHashable:Any]? = nil
                if let accessToken = accessToken {
                    userInfo = ["accessToken": accessToken]
                }
                
                NotificationCenter.default.post(name: Notification.Name("showSelectSongView"), object: nil, userInfo: userInfo)
            }

            self.selectSongView.isHidden = false
            self.selectSongView.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                self.selectSongView.alpha = 1.0
            })
        }
    }
    
    @objc private func didSelectSong(notification: NSNotification) {
        self.selectedSong = notification.userInfo?["selectedSong"] as? SearchSongResult
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
            self.selectSongView.alpha = 0.0
        }) { completed in
           self.selectSongView.isHidden = true
           self.selectSongView.alpha = 0.0
       }

        self.editorContainerView.isHidden = false
        self.editorContainerView.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.4, options: .curveEaseInOut, animations: {
            self.editorContainerView.alpha = 1.0
        }) { completed in

        }
    }

    @objc private func launchTransitionDidComplete(notification: NSNotification) {
        self.createNewVideoButton.isHidden = false
        self.noVideosCreatedLabel.isHidden = false
        self.lyricalBananaLabel.isHidden = false
        self.bananaImageView.isHidden = false
        
        self.createNewVideoButton.alpha = 0.0
        self.noVideosCreatedLabel.alpha = 0.0
        self.lyricalBananaLabel.alpha = 0.0
        self.bananaImageView.alpha = 0.0
        
        UIView.animate(withDuration: 0.05, delay: 2.30, animations: {
            self.lyricalBananaLabel.alpha = 1.0
            self.bananaImageView.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.25, delay: 2.15, animations: {
            self.createNewVideoButton.alpha = 1.0
            self.noVideosCreatedLabel.alpha = 1.0
        })
        
//        UIView.animate(withDuration: 0.0, delay: 2.4, animations: {
//            self.bananaImageView.alpha = 1.0
//        })
    }

    @objc private func authorizedSpotify(notification: NSNotification) {
        MainViewController.authorizedSpotify = true

        let accessToken = notification.userInfo?["accessToken"] as! String
        musicPlatformToSelectSongTransition(accessToken: accessToken)
    }
    
    @objc private func authorizedAppleMusic(notification: NSNotification) {
        MainViewController.authorizedAppleMusic = true
        
        musicPlatformToSelectSongTransition(accessToken: nil)
    }

    // MARK: - Actions
    
    @IBAction func pressedCreateNewVideo(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            self.createNewVideoButton.alpha = 0.0
        })
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.noVideosCreatedLabel.alpha = 0.0
            self.bananaImageView.alpha = 0.0
        }) { completed in
            self.videoListContainerView.isHidden = true
        }
        
        self.musicServiceView.isHidden = false
        self.musicServiceView.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.4, animations: {
            self.musicServiceView.alpha = 1.0
        })
            
//        spotifyRemote.authorizeAndPlayURI("")
//        spotifyRemote.playerAPI?.pause()
//
//        print(spotifyRemote.connectionParameters)
//        print(spotifyRemote.connectionParameters.accessToken)
//        print((UIApplication.shared.delegate as! AppDelegate).accessToken)
                        
//        AF.request("https://api.spotify.com/v1/search", method: .get, parameters: ["q":"100 bands", "type":"track"], encoder: URLEncodedFormParameterEncoder.default, headers: ["Authorization":""], interceptor: nil).response { response in
//            debugPrint(response)
//        }
        
        
//        UIView.animate(withDuration: 0.2, delay: 0.4, animations: {
//            self.editorContainerView.alpha = 1.0
//        })
    
//        spotifyRemote.authorizeAndPlayURI(self.playURI)
        
        //spotifyRemote.playerAPI?.play(<#T##trackUri: String##String#>, asRadio: <#T##Bool#>, callback: <#T##SPTAppRemoteCallback##SPTAppRemoteCallback##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.pause(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.resume(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seekForward15Seconds(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seekBackward15Seconds(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seek(toPosition: <#T##Int#>, callback: <#T##SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
    }
}


