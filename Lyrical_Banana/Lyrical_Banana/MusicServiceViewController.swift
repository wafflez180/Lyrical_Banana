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
    let cloudServiceController = SKCloudServiceController()

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
        SKCloudServiceController.requestAuthorization({
           (status: SKCloudServiceAuthorizationStatus) in
               switch(status) {
               case .notDetermined:
                _ = self.navigationController?.popViewController(animated: true)
                let alert = UIAlertController(title: "Not Determined", message: "Unfortunately Apple Music responded saying your subscription's validity is not determined.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

               case .denied:
                _ = self.navigationController?.popViewController(animated: true)
                let alert = UIAlertController(title: "Denied", message: "Unfortunately Apple Music responded saying your subscription's validity is denied.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
               case .restricted:
                _ = self.navigationController?.popViewController(animated: true)
                let alert = UIAlertController(title: "Restricted", message: "Unfortunately Apple Music responded saying your subscription's validity is restricted.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

               case .authorized:
                print(status)
                print("---------------")
                let developerToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkZHSElKNjc4OTAifQ.eyJpYXQiOjE1ODExMjMwNTgsImV4cCI6MTU5NjY3NTA1OCwiaXNzIjoiQUJDREUxMjM0NSJ9.l_0hFFaDnntN9iUUXTnlP2xbTpW0pFj3YpLS2ZpQ593VpNIivnS6xjtgHvQITo7081xvy7yYOOLWDWhlJapdEw"
                        SKCloudServiceController().requestCapabilities { capabilities, error in
                            print(capabilities)
                            print(error)
                            if capabilities.contains(.musicCatalogPlayback) {

                                // User has Apple Music account
                                NotificationCenter.default.post(name: Notification.Name("authorizedAppleMusic"), object: nil)
                            } else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                                // User can sign up to Apple Music
                                print("YEs")
                                self.showAppleMusicSignup()
                            }
                }
            }
        })
    }
    
    // MARK: - Spotify Controller Delegate
    
    func receivedAccessToken(accessToken: String) {
        NotificationCenter.default.post(name: Notification.Name("authorizedSpotify"), object: nil, userInfo: ["accessToken": accessToken])
    }
}
