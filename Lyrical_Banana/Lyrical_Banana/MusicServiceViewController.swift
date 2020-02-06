//
//  MusicServiceViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton
import StoreKit

class MusicServiceViewController: UIViewController, SpotifyControllerDelegate, SKCloudServiceSetupViewControllerDelegate {
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - MusicServiceViewController
        
    func showAppleMusicSignup() {
        let vc = SKCloudServiceSetupViewController()
        vc.delegate = self

        let options: [SKCloudServiceSetupOptionsKey: Any] = [
            .action: SKCloudServiceSetupAction.subscribe,
            .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic
        ]
            
        vc.load(options: options) { success, error in
            if success {
                self.present(vc, animated: true)
            }
        }
    }

    // MARK: - Actions

    @IBAction func pressedSpotifyButton(_ sender: Any) {
        self.sceneDelegate?.authorizeAndConnect(spotifyController: self)
    }
    
    @IBAction func pressedAppleMusicButton(_ sender: Any) {
        let cloudServiceController = SKCloudServiceController()

        SKCloudServiceController.requestAuthorization { status in
            cloudServiceController.requestCapabilities { capabilities, error in
                if capabilities.contains(.musicCatalogPlayback) {
                    // User has Apple Music account
                    NotificationCenter.default.post(name: Notification.Name("authorizedAppleMusic"), object: nil)
                } else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                    // User can sign up to Apple Music
                    self.showAppleMusicSignup()
                }
            }
        }
    }
    
    // MARK: - Spotify Controller Delegate
    
    func receivedAccessToken(accessToken: String) {
        NotificationCenter.default.post(name: Notification.Name("authorizedSpotify"), object: nil, userInfo: ["accessToken": accessToken])
    }
}
