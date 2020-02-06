//
//  LaunchToMainTransitionViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class LaunchToMainTransitionViewController: UIViewController {

    @IBOutlet var lyricalBananaLabel: UILabel!
    @IBOutlet var bananaImageView: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bananaImageView.loadGif(asset: "banana_gif")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        var newLabelOrigin = self.lyricalBananaLabel.frame.origin
        newLabelOrigin.y = MainViewController.bananaLabelOrigin!.y

        var newImageViewOrigin = self.bananaImageView.frame.origin
        newImageViewOrigin.y = MainViewController.bananaImageViewOrigin!.y + 60.5
        newImageViewOrigin.x += 3.5

        NotificationCenter.default.post(name: Notification.Name("launchTransitionComplete"), object: nil)
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseInOut, animations: {
            self.lyricalBananaLabel.frame.origin = newLabelOrigin
            self.bananaImageView.frame.origin = newImageViewOrigin
        }) { completed in
            UIView.animate(withDuration: 0.1, delay: 0.41, animations: {
                self.lyricalBananaLabel.alpha = 0.0
                self.bananaImageView.alpha = 0.0
            })
        }
    }
    
    // MARK: - LaunchToMainTransitionViewController

    
}
