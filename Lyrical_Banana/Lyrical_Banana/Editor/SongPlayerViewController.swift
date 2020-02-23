//
//  SongPlayerViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton

class SongPlayerViewController: UIViewController, SongPlayerViewControlDelegate {

    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var spotifyDisconnectedAlertButton: PMSuperButton!
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotifyDisconnectedAlertButton.isHidden = true
        MusicPlayerManager.shared.songPlayerViewControlDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(editorDidAppear), name: Notification.Name("editorDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidDisconnect), name: Notification.Name("spotifyDidDisconnecd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidReconnect), name: Notification.Name("spotifyDidReconnect"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    // MARK: - SongPlayerViewController
    
    @objc private func editorDidAppear(notification: NSNotification) {
        setupSongLabels()
        MusicPlayerManager.shared.playSong()
    }
    
    @objc private func spotifyDidDisconnect(notification: NSNotification) {
        spotifyDisconnectedAlertButton.isHidden = false
        spotifyDisconnectedAlertButton.imageView?.alpha = 0.0
        
        UIView.animate(withDuration: 0.2) {
            self.spotifyDisconnectedAlertButton.imageView?.alpha = 1.0
        }
    }
    
    @objc private func spotifyDidReconnect(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.spotifyDisconnectedAlertButton.imageView?.alpha = 0.0
        }) { finished in
            self.spotifyDisconnectedAlertButton.isHidden = true
        }
    }

    func setupSongLabels() {
        self.songNameLabel.text = MusicPlayerManager.shared.currentSong!.name
        self.artistNameLabel.text = MusicPlayerManager.shared.currentSong!.artistLabelText
    }
            
    // MARK: - Actions
    
    @IBAction func pressedBackward(_ sender: Any) {
        MusicPlayerManager.shared.seekBackwards10Seconds()
    }
    
    @IBAction func pressedForward(_ sender: Any) {
        MusicPlayerManager.shared.seekForwards10Seconds()
    }
    
    @IBAction func pressedPauseOrPlay(_ sender: Any) {
        if MusicPlayerManager.shared.isPlaying {
            MusicPlayerManager.shared.pauseSong()
        } else {
            playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
            playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            MusicPlayerManager.shared.resumeSong()
        }
    }
    
    @IBAction func pressedSpotifyDisconnectedAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Spotify was disconnected", message: "Apple's iOS disconnects Spotify when music is not played after 30 seconds.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Reconnect", style: UIAlertAction.Style.default, handler: { action in
            MusicPlayerManager.shared.requestSpotifyAuthorization()
        }))
        alert.addAction(UIAlertAction(title: "Ignore", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SongPlayerViewControlDelegate
    
    func didPauseSong() {
        playButton.setImage(UIImage(named: "Play")?.withRenderingMode(.alwaysOriginal), for: .normal)
        playButton.setImage(UIImage(named: "Play")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
    }
    
    func didPlaySong() {
        playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
        playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
    }

}
