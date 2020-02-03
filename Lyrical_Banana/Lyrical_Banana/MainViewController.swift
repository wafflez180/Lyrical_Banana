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
    
    @IBOutlet var editorContainerView: UIView!
    @IBOutlet var videoListContainerView: UIView!
    
    @IBOutlet var bananaImageView: UIImageView!
    @IBOutlet var noVideosCreatedLabel: UILabel!
    @IBOutlet var createNewVideoButton: PMSuperButton!
    
    @IBOutlet var musicServiceView: UIView!
    @IBOutlet var selectSongView: UIView!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.editorContainerView.isHidden = true
        self.musicServiceView.isHidden = true
        self.selectSongView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedSpotify), name: Notification.Name("authorizedSpotify"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedAppleMusic), name: Notification.Name("authorizedAppleMusic"), object: nil)
    }
    
    // MARK: - MainViewController


    // MARK: - MusicServiceDelegate

    @objc private func authorizedSpotify(notification: NSNotification) {
        let accessToken = notification.userInfo?["accessToken"] as! String
                
        UIView.animate(withDuration: 0.2, animations: {
            self.musicServiceView.alpha = 0.0
        }) { completed in
            self.musicServiceView.isHidden = false
        }
        
        self.selectSongView.isHidden = false
        self.selectSongView.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
            self.selectSongView.alpha = 1.0
        })
        
        NotificationCenter.default.post(name: Notification.Name("showSelectSongView"), object: nil, userInfo: ["accessToken": accessToken])
    }
    
    @objc private func authorizedAppleMusic(notification: NSNotification) {
        
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


