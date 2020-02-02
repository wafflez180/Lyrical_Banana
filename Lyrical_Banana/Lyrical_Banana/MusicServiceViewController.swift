//
//  MusicServiceViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton

class MusicServiceViewController: UIViewController, SpotifyControllerDelegate {
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    
    
    
    // MARK: - MusicServiceViewController
        
    @IBAction func pressedSpotifyButton(_ sender: Any) {
        self.sceneDelegate?.authorizeAndConnect(spotifyController: self)
    }
    
    @IBAction func pressedAppleMusicButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("authorizedAppleMusic"), object: nil)
    }
    
    // MARK: - Spotify Controller Delegate
    
    func receivedAccessToken(accessToken: String) {
        NotificationCenter.default.post(name: Notification.Name("authorizedSpotify"), object: nil, userInfo: ["accessToken": accessToken])
    }
}
