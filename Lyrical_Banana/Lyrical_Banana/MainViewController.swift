//
//  MainViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import PMSuperButton

class MainViewController: UIViewController {
    
    @IBOutlet var videoListContainerView: UIView!
    
    @IBOutlet var bananaImageView: UIImageView!
    @IBOutlet var noVideosCreatedLabel: UILabel!
    @IBOutlet var createNewVideoButton: PMSuperButton!

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - MainViewController


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
    }
}

