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
        
        NotificationCenter.default.addObserver(self, selector: #selector(recievedFirstSpotifyAuth), name: Notification.Name("recievedFirstSpotifyAuth"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authorizedAppleMusic), name: Notification.Name("authorizedAppleMusic"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(launchTransitionDidComplete), name: Notification.Name("launchTransitionComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectSong), name: Notification.Name("didSelectSong"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: - MainViewController

    func musicServiceToSelectSongTransition() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.musicServiceView.alpha = 0.0
            }) { completed in
                self.musicServiceView.isHidden = false
                
                NotificationCenter.default.post(name: Notification.Name("showSelectSongView"), object: nil, userInfo: nil)
            }

            self.selectSongView.isHidden = false
            self.selectSongView.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                self.selectSongView.alpha = 1.0
            })
        }
    }
    
    // MARK: - Notifications

    @objc private func didSelectSong(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
            self.selectSongView.alpha = 0.0
        }) { completed in
            self.selectSongView.isHidden = true
            
            NotificationCenter.default.post(name: Notification.Name("editorDidAppear"), object: nil, userInfo: nil)
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

    @objc private func recievedFirstSpotifyAuth(notification: NSNotification) {
        musicServiceToSelectSongTransition()
    }
    
    @objc private func authorizedAppleMusic(notification: NSNotification) {
        MainViewController.authorizedAppleMusic = true
        musicServiceToSelectSongTransition()
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
    }
}


