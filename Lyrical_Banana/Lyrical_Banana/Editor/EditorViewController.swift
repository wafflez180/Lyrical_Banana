//
//  EditorViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 1/31/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    @IBOutlet var lyricEditorContainerView: UIView!
    @IBOutlet var imageSearchContainerView: UIView!
    @IBOutlet var songPlayerContainerView: UIView!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(editorDidAppear), name: Notification.Name("editorDidAppear"), object: nil)
    }
    
    // MARK: - EditorViewController
    
    @objc private func editorDidAppear(notification: NSNotification) {
        //self.selectedSong = notification.userInfo?["selectedSong"] as? SearchSongResult
    }
}
