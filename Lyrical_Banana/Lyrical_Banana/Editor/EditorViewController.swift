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
    
    @IBOutlet var lyricEditorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lyricEditorTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var imageSearchHeightConstraint: NSLayoutConstraint!
    @IBOutlet var imageSearchTopConstraint: NSLayoutConstraint!
    
    let topToBotSpacing: CGFloat = 15
    let topViewSizeRatio: CGFloat = 0.35
    let botViewSizeRation: CGFloat = 0.65
    
    static var topModuleHeight: CGFloat!
    var botModuleHeight: CGFloat!
    var topModuleTopConstraint: CGFloat!
    var botModuleTopConstraint: CGFloat!
        
    var isEditingModulesSwapped = false
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector: #selector(editorDidAppear), name: Notification.Name("editorDidAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(swapEditingModules), name: Notification.Name("swapEditingModules"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let initialTopViewTopConstraint = lyricEditorTopConstraint.constant
        
        let top = lyricEditorContainerView.frame.origin.y - initialTopViewTopConstraint
        let bot = songPlayerContainerView.frame.origin.y
        let moduleSpaceHeight = bot - top
        
        EditorViewController.topModuleHeight = moduleSpaceHeight * topViewSizeRatio
        botModuleHeight = moduleSpaceHeight * botViewSizeRation
        topModuleTopConstraint = initialTopViewTopConstraint
        botModuleTopConstraint = EditorViewController.topModuleHeight + topModuleTopConstraint + topToBotSpacing

        lyricEditorHeightConstraint.constant = EditorViewController.topModuleHeight
        imageSearchHeightConstraint.constant = botModuleHeight
        lyricEditorTopConstraint.constant = topModuleTopConstraint
        imageSearchTopConstraint.constant = botModuleTopConstraint
    }
    
    // MARK: - EditorViewController
    
    @objc func swapEditingModules() {
        self.view.endEditing(true)
        
        if !isEditingModulesSwapped {
            self.view.bringSubviewToFront(lyricEditorContainerView)
            lyricEditorHeightConstraint.constant = botModuleHeight
            imageSearchHeightConstraint.constant = EditorViewController.topModuleHeight
            lyricEditorTopConstraint.constant = botModuleTopConstraint
            imageSearchTopConstraint.constant = topModuleTopConstraint
        } else {
            self.view.bringSubviewToFront(imageSearchContainerView)
            lyricEditorHeightConstraint.constant = EditorViewController.topModuleHeight
            imageSearchHeightConstraint.constant = botModuleHeight
            lyricEditorTopConstraint.constant = topModuleTopConstraint
            imageSearchTopConstraint.constant = botModuleTopConstraint
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.isEditingModulesSwapped = !self.isEditingModulesSwapped
        })
    }
    
    @objc private func editorDidAppear(notification: NSNotification) {
        //self.selectedSong = notification.userInfo?["selectedSong"] as? SearchSongResult
        //MusicPlayerManager.shared.restartSong()
    }
}
