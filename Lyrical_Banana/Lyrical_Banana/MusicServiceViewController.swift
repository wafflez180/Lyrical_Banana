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

class MusicServiceViewController: UIViewController, SKCloudServiceSetupViewControllerDelegate {
    
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
            // TODO: Add loading indicator
        vc.load(options: options) { success, error in
            if success {
                self.present(vc, animated: true)
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Apple Music Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func pressedSpotifyButton(_ sender: Any) {
        // TODO: Check what happens when not connected to internet, show alert when not connected
        MusicPlayerManager.shared.spotifyManager.requestSpotifyAuthorization()
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
                    self.present(alert, animated: true, completion: nil)

               case .restricted:
                    _ = self.navigationController?.popViewController(animated: true)
                    let alert = UIAlertController(title: "Restricted", message: "Unfortunately Apple Music responded saying your subscription's validity is restricted.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

               case .authorized:
                    print(status)
                    print("---------------")
                    let developerToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkZHSElKNjc4OTAifQ.eyJpYXQiOjE1ODExMjMwNTgsImV4cCI6MTU5NjY3NTA1OCwiaXNzIjoiQUJDREUxMjM0NSJ9.l_0hFFaDnntN9iUUXTnlP2xbTpW0pFj3YpLS2ZpQ593VpNIivnS6xjtgHvQITo7081xvy7yYOOLWDWhlJapdEw"
                    SKCloudServiceController().requestCapabilities { capabilities, error in
                        print(capabilities)
                        print(error)
                        if capabilities.contains(.musicCatalogPlayback) {
                            // User has Apple Music account and is authorized
                            MusicPlayerManager.shared.selectedMusicService = .appleMusic
                            NotificationCenter.default.post(name: Notification.Name("didReceiveMusicServiceAuth"), object: nil)
                        } else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                            // User can sign up to Apple Music
                            self.showAppleMusicSignup()
                        }
                    }
            }
        })
    }
}
