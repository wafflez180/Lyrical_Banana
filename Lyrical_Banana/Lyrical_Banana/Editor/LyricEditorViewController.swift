//
//  LyricEditorViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/8/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer

class LyricEditorViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var musicIconImageView: UIImageView!
    @IBOutlet var lyricEditorHeaderLabel: UILabel!
    @IBOutlet var tapToEditLabel: UILabel!
    
    var isTopModule = true
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapToEditLabel.alpha = 0.0
        textView.isUserInteractionEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(getLyrics), name: Notification.Name("willHideSelectSongView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getLyrics), name: Notification.Name("startedPlayingAppleMusicSong"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willSwapEditingModules), name: Notification.Name("swapEditingModules"), object: nil)
    }
    
    // MARK: - LyricEditorViewController

    @objc func willSwapEditingModules() {
        isTopModule = !isTopModule
        musicIconImageView.isHighlighted = !isTopModule
        lyricEditorHeaderLabel.isHighlighted = !isTopModule
        textView.isUserInteractionEnabled = !isTopModule

        UIView.animate(withDuration: 0.2) {
            self.tapToEditLabel.alpha = !self.isTopModule ? 0.0 : 1.0
        }
    }
    
    // MARK: - LyricEditorViewController

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            if isTopModule {
                NotificationCenter.default.post(name: Notification.Name("swapEditingModules"), object: nil, userInfo: nil)
            }
        }
    }
    
    // MARK: - API Requests
    
    @objc func getLyrics() {
        print(MusicPlayerManager.shared.appleMusicManager.appleMusicPlayer.nowPlayingItem?.lyrics)
        
        textView.text = MusicPlayerManager.shared.appleMusicManager.appleMusicPlayer.nowPlayingItem?.lyrics
        
        //MPMediaQuery.
        //MPMediaItem.ini
    }
}
