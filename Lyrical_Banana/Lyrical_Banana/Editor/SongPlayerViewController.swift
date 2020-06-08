//
//  SongPlayerViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton

class SongPlayerViewController: UIViewController, SongPlayerViewControlDelegate, SongTimeBarMovingIndicatorDelegate {

    @IBOutlet var spotifyDisconnectedAlertButton: PMSuperButton!

    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    @IBOutlet var songTimeBarView: SongTimeBarView!
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicPlayerManager.shared.songPlayerViewControlDelegate = self

        spotifyDisconnectedAlertButton.isHidden = true
        self.songNameLabel.text = ""
        self.artistNameLabel.text = ""

        songTimeBarView.viewDidLoad()
        songTimeBarView.movingIndicatorDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(didHideSelectSongView), name: Notification.Name("didHideSelectSongView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidDisconnect), name: Notification.Name("spotifyDidDisconnecd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidReconnect), name: Notification.Name("spotifyDidReconnect"), object: nil)
    }
    
    // MARK: - SongPlayerViewController
    
    @objc private func didHideSelectSongView() {
        if let selectedSong = MusicPlayerManager.shared.currentSong {
            self.songNameLabel.text = selectedSong.name
            self.artistNameLabel.text = selectedSong.artistLabelText

            songTimeBarView.didHideSelectSongView()
            MusicPlayerManager.shared.playSong()
        }
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
        if !songTimeBarView.movedTimeIndicator && !MusicPlayerManager.shared.isSeeking {
            playButton.setImage(UIImage(named: "Play")?.withRenderingMode(.alwaysOriginal), for: .normal)
            playButton.setImage(UIImage(named: "Play")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        }
    }
    
    func didPlayOrResumeSong() {
        playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
        playButton.setImage(UIImage(named: "Pause")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
    }
    
    // MARK: - SongTimeBarMovingIndicatorDelegate

    func didBeginSeeking() {
        backwardButton.isEnabled = false
        forwardButton.isEnabled = false
        playButton.isEnabled = false
    }
    
    func didEndSeeking() {
        if MusicPlayerManager.shared.spotifyAppRemote.isConnected || MusicPlayerManager.shared.currentSong!.isAppleMusicSong {
            backwardButton.isEnabled = true
            forwardButton.isEnabled = true
        }
        playButton.isEnabled = true
    }
    
    // MARK: - Spotify
    
    @objc private func spotifyDidDisconnect(notification: NSNotification) {
        spotifyDisconnectedAlertButton.isHidden = false
        spotifyDisconnectedAlertButton.imageView?.alpha = 0.0
        backwardButton.isEnabled = false
        forwardButton.isEnabled = false
        didPauseSong()

        UIView.animate(withDuration: 0.2) {
            self.spotifyDisconnectedAlertButton.imageView?.alpha = 1.0
        }
    }
    
    @objc private func spotifyDidReconnect(notification: NSNotification) {
        backwardButton.isEnabled = true
        forwardButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.spotifyDisconnectedAlertButton.imageView?.alpha = 0.0
        }) { finished in
            self.spotifyDisconnectedAlertButton.isHidden = true
        }
    }
}
