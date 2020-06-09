//
//  SongTimeBarView.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 6/4/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

protocol SongTimeBarMovingIndicatorDelegate {
    func didBeginSeeking()
    func didEndSeeking()
}

class SongTimeBarView: UIView {
    
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var timeBarView: UIView!
    @IBOutlet var movingTimeIndicatorView: UIView!
    @IBOutlet var movingTimeIndicatorViewLeftConstraint: NSLayoutConstraint!

    var initialMovingTimeIndicatorViewLeftConstraint:CGFloat!
    var movingTimeIndicatorTimer:Timer?
    var amountToIncrementEverySec:CGFloat = 0.0
    
    var initialMovingTimeIndicatorColor:UIColor!
    var wasPlayingMusicBeforeMoving = false
    var touchedTimeIndicator = false
    var movedTimeIndicator = false
    var initialTouchDistanceXVal: CGFloat = 0.0
    var initialIndicatorCenterLocationXVal: CGFloat = 0.0
    var initialTouchedTimeIndicatorLeftConstraint: CGFloat = 0.0
    
    var movingIndicatorDelegate: SongTimeBarMovingIndicatorDelegate?

    // MARK: - SongTimeBarView
    
    func viewDidLoad() {
        initialMovingTimeIndicatorColor = movingTimeIndicatorView.backgroundColor
        initialMovingTimeIndicatorViewLeftConstraint = movingTimeIndicatorViewLeftConstraint.constant
        self.currentTimeLabel.text = "00:00"
        self.totalTimeLabel.text = "00:00"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSongTime), name: Notification.Name("didChangeSongTime"), object: nil)
    }
    
    func didHideSelectSongView() {
        let selectedSong = MusicPlayerManager.shared.currentSong!
        self.totalTimeLabel.text = selectedSong.durationStr
        self.amountToIncrementEverySec = ((self.timeBarView.frame.width - (self.movingTimeIndicatorView.frame.width/2)) / (CGFloat(selectedSong.durationMilliSec) / 1000.0))
        
        if selectedSong.isSpotifySong {
            startIncrementingTimer()
        }
    }
    
    // MARK: - Moving Time Indicator Interactions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = CGPoint.init(x: touch.location(in: self).x , y: touch.location(in: self).y)
            let indicatorCenterLocation = CGPoint.init(x: movingTimeIndicatorView.frame.origin.x + (movingTimeIndicatorView.frame.width/2), y: movingTimeIndicatorView.frame.origin.y + (movingTimeIndicatorView.frame.height/2))
            let touchDistanceFromIndicator = hypotf(Float(touchLocation.x - indicatorCenterLocation.x), Float(touchLocation.y - indicatorCenterLocation.y))
            
            if touchDistanceFromIndicator < 50.0 {
                wasPlayingMusicBeforeMoving = MusicPlayerManager.shared.isPlaying
                touchedTimeIndicator = true
                initialTouchDistanceXVal = (touchLocation.x - indicatorCenterLocation.x)
                initialIndicatorCenterLocationXVal = indicatorCenterLocation.x
                initialTouchedTimeIndicatorLeftConstraint = movingTimeIndicatorViewLeftConstraint.constant
            }
        }
        super.touchesBegan(touches, with: event)
    }
        
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touchedTimeIndicator {
                if !movedTimeIndicator {
                    movingIndicatorDelegate?.didBeginSeeking()
                    movedTimeIndicator = true
                    movingTimeIndicatorView.backgroundColor = .white

                    if MusicPlayerManager.shared.isPlaying {
                        MusicPlayerManager.shared.pauseSong()
                    }
                }
                

                let touchLocation = CGPoint.init(x: touch.location(in: self).x , y: touch.location(in: self).y)
                let distanceFromOriginTouchXVal = ((touchLocation.x - initialIndicatorCenterLocationXVal) - initialTouchDistanceXVal)

                let newLeftConstraintConstant = initialTouchedTimeIndicatorLeftConstraint + distanceFromOriginTouchXVal
                let newSongTime = Int(newLeftConstraintConstant / amountToIncrementEverySec)
                
                if newSongTime >= 0 && newSongTime <= MusicPlayerManager.shared.currentSong!.durationSec {
                    currentTimeLabel.text = stringFromSec(seconds: newSongTime)
                    movingTimeIndicatorViewLeftConstraint.constant = newLeftConstraintConstant
                }
            }
        }
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            if movedTimeIndicator {
                touchedTimeIndicator = false
                movedTimeIndicator = false
                movingTimeIndicatorView.backgroundColor = initialMovingTimeIndicatorColor
                
                seekToNewSongTime()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            if movedTimeIndicator {
                movingIndicatorDelegate?.didEndSeeking()
                touchedTimeIndicator = false
                movedTimeIndicator = false

                resetMovingTimeIndicator()
            }
        }
    }
    
    func seekToNewSongTime() {
        let newSongTime = Int(movingTimeIndicatorViewLeftConstraint.constant / amountToIncrementEverySec)
        
        let spotifyIsConnected = (MusicPlayerManager.shared.musicService as? SpotifyManager)?.appRemote.isConnected ?? false
        if spotifyIsConnected || MusicPlayerManager.shared.selectedMusicService! == .appleMusic {
            MusicPlayerManager.shared.seekTo(newSongTime: newSongTime) { success in
                self.movingIndicatorDelegate?.didEndSeeking()
                if success {
                    if self.wasPlayingMusicBeforeMoving && !MusicPlayerManager.shared.isPlaying {
                        MusicPlayerManager.shared.resumeSong()
                    }
                } else {
                    self.resetMovingTimeIndicator()
                }
            }
        } else {
            MusicPlayerManager.shared.didChangeSongTimeWhileDisconnected = true
            MusicPlayerManager.shared.currentSongTimeSec = newSongTime
            movingIndicatorDelegate?.didEndSeeking()
        }
    }
    
    func resetMovingTimeIndicator() {
        movingTimeIndicatorView.backgroundColor = initialMovingTimeIndicatorColor
        movingTimeIndicatorViewLeftConstraint.constant = initialTouchedTimeIndicatorLeftConstraint
        let newSongTime = Int(movingTimeIndicatorViewLeftConstraint.constant / amountToIncrementEverySec)
        currentTimeLabel.text = stringFromSec(seconds: newSongTime)
    }

    // MARK: - Moving Time Indicator Incrementing
    
    func startIncrementingTimer() {
        if movingTimeIndicatorTimer != nil { return }
        movingTimeIndicatorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementTimeAndUpdateViews), userInfo: nil, repeats: true)
    }
    
    @objc func incrementTimeAndUpdateViews() {
        let songLengthSec = MusicPlayerManager.shared.currentSong!.durationSec
        let spotifyIsConnected = (MusicPlayerManager.shared.musicService as? SpotifyManager)?.appRemote.isConnected ?? false
        
        if MusicPlayerManager.shared.isPlaying && MusicPlayerManager.shared.currentSongTimeSec < songLengthSec && spotifyIsConnected {
            MusicPlayerManager.shared.currentSongTimeSec += 1
            
            currentTimeLabel.text = stringFromSec(seconds: MusicPlayerManager.shared.currentSongTimeSec)
            
            self.movingTimeIndicatorViewLeftConstraint.constant = (CGFloat(MusicPlayerManager.shared.currentSongTimeSec) * self.amountToIncrementEverySec) + self.initialMovingTimeIndicatorViewLeftConstraint
            UIView.animate(withDuration: TimeInterval(amountToIncrementEverySec), delay: 0.0, options: .curveLinear, animations: {
                self.superview?.layoutIfNeeded()
            }, completion: nil)
        } else if MusicPlayerManager.shared.currentSongTimeSec == songLengthSec {
            MusicPlayerManager.shared.restartSong()
        }
    }

    @objc private func didChangeSongTime(notification: NSNotification) {
        self.movingTimeIndicatorViewLeftConstraint.constant = (CGFloat(MusicPlayerManager.shared.currentSongTimeSec) * self.amountToIncrementEverySec) + self.initialMovingTimeIndicatorViewLeftConstraint
        
        if let animate = notification.userInfo?["animate"] as? Bool {
            if animate && MusicPlayerManager.shared.isPlaying {
                UIView.animate(withDuration: TimeInterval(amountToIncrementEverySec), delay: 0.0, options: .curveLinear, animations: {
                    self.superview?.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.movingTimeIndicatorView.layoutIfNeeded()
            }
        }
        currentTimeLabel.text = stringFromSec(seconds: MusicPlayerManager.shared.currentSongTimeSec)
    }

    // MARK: - Helper Funcs
    
    func stringFromSec(seconds: Int) -> String {
        let time = NSInteger(seconds)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}
