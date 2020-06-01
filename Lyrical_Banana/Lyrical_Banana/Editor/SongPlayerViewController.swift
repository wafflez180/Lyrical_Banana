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

    @IBOutlet var spotifyDisconnectedAlertButton: PMSuperButton!

    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    // Time Bar
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var timeBarView: UIView!
    @IBOutlet var movingTimeIndicatorView: UIView!
    @IBOutlet var movingTimeIndicatorViewLeftConstraint: NSLayoutConstraint!
    
    var initialMovingTimeIndicatorViewLeftConstraint:CGFloat!
    var movingTimeIndicatorTimer:Timer?
    var incrementEverySecAmount:CGFloat = 0.0

    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotifyDisconnectedAlertButton.isHidden = true
        
        MusicPlayerManager.shared.songPlayerViewControlDelegate = self
        initialMovingTimeIndicatorViewLeftConstraint = movingTimeIndicatorViewLeftConstraint.constant

        NotificationCenter.default.addObserver(self, selector: #selector(editorDidAppear), name: Notification.Name("editorDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidDisconnect), name: Notification.Name("spotifyDidDisconnecd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(spotifyDidReconnect), name: Notification.Name("spotifyDidReconnect"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSongTime), name: Notification.Name("didChangeSongTime"), object: nil)
    }
    

    // MARK: - SongPlayerViewController
    
    @objc private func editorDidAppear(notification: NSNotification) {
        setupSongLabels()
        MusicPlayerManager.shared.playSong()
        beginIncrementingTime()
    }
    
    func setupSongLabels() {
        if let selectedSong = MusicPlayerManager.shared.currentSong {
            self.songNameLabel.text = selectedSong.name
            self.artistNameLabel.text = selectedSong.artistLabelText
            self.totalTimeLabel.text = selectedSong.durationStr
            self.currentTimeLabel.text = "00:00"
            
            self.incrementEverySecAmount = ((self.timeBarView.frame.width - (self.movingTimeIndicatorView.frame.width/2)) / (CGFloat(selectedSong.durationMilliSec) / 1000.0))
        }
    }
    
    // MARK: - Song Time Indicator
    
    func beginIncrementingTime() {
        movingTimeIndicatorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementTimeAndUpdateViews), userInfo: nil, repeats: true)
    }
    
    @objc func incrementTimeAndUpdateViews() {
        let songLengthSec = MusicPlayerManager.shared.currentSong!.durationSec
        if MusicPlayerManager.shared.isPlaying && MusicPlayerManager.shared.currentSongTimeSec < songLengthSec {
            MusicPlayerManager.shared.currentSongTimeSec += 1
            
            currentTimeLabel.text = stringFromSec(seconds: MusicPlayerManager.shared.currentSongTimeSec)
            
            self.movingTimeIndicatorViewLeftConstraint.constant = (CGFloat(MusicPlayerManager.shared.currentSongTimeSec) * self.incrementEverySecAmount) + self.initialMovingTimeIndicatorViewLeftConstraint
            UIView.animate(withDuration: TimeInterval(incrementEverySecAmount), delay: 0.0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else if MusicPlayerManager.shared.currentSongTimeSec == songLengthSec {
            MusicPlayerManager.shared.restartSong()
        }
    }
    
    func stringFromSec(seconds: Int) -> String {
        let time = NSInteger(seconds)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    @objc private func didChangeSongTime(notification: NSNotification) {
        self.movingTimeIndicatorViewLeftConstraint.constant = (CGFloat(MusicPlayerManager.shared.currentSongTimeSec) * self.incrementEverySecAmount) + self.initialMovingTimeIndicatorViewLeftConstraint
        self.movingTimeIndicatorView.layoutIfNeeded()
        currentTimeLabel.text = stringFromSec(seconds: MusicPlayerManager.shared.currentSongTimeSec)
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
    
    // MARK: - Spotify
    
    @objc private func spotifyDidDisconnect(notification: NSNotification) {
        spotifyDisconnectedAlertButton.isHidden = false
        spotifyDisconnectedAlertButton.imageView?.alpha = 0.0
        backwardButton.isEnabled = false
        forwardButton.isEnabled = false

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
