//
//  MainViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton

class MainViewController: UIViewController {
    
    let spotifyRemote = (UIApplication.shared.delegate as! AppDelegate).appRemote
    var playURI = "spotify:track:3yk7PJnryiJ8mAPqsrujzf"

    @IBOutlet var editorContainerView: UIView!
    @IBOutlet var videoListContainerView: UIView!
    
    @IBOutlet var bananaImageView: UIImageView!
    @IBOutlet var noVideosCreatedLabel: UILabel!
    @IBOutlet var createNewVideoButton: PMSuperButton!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.editorContainerView.alpha = 0.0
    }
    
    // MARK: - MainViewController


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
        UIView.animate(withDuration: 0.2, delay: 0.4, animations: {
            self.editorContainerView.alpha = 1.0
        })
    
        spotifyRemote.authorizeAndPlayURI(self.playURI)
        
        //spotifyRemote.playerAPI?.play(<#T##trackUri: String##String#>, asRadio: <#T##Bool#>, callback: <#T##SPTAppRemoteCallback##SPTAppRemoteCallback##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.pause(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.resume(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seekForward15Seconds(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seekBackward15Seconds(<#T##callback: SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
        //spotifyRemote.playerAPI?.seek(toPosition: <#T##Int#>, callback: <#T##SPTAppRemoteCallback?##SPTAppRemoteCallback?##(Any?, Error?) -> Void#>)
    }
    
}


