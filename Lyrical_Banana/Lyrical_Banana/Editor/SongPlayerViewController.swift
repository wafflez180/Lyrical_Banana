//
//  SongPlayerViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class SongPlayerViewController: UIViewController, SongPlayerViewControlDelegate {

    @IBOutlet var songNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicPlayerManager.shared.songPlayerViewControlDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(editorDidAppear), name: Notification.Name("editorDidAppear"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    // MARK: - SongPlayerViewController
    
    @objc private func editorDidAppear(notification: NSNotification) {
        setupSongLabels()
        MusicPlayerManager.shared.playSong()
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
