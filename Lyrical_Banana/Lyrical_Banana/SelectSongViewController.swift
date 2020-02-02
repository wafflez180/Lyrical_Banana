//
//  SelectSongViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Alamofire

class SelectSongViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var songTableView: UITableView!
    
    var accessToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        songTableView.dataSource = self
        songTableView.register(UINib.init(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didAppear), name: Notification.Name("showSelectSongView"), object: nil)
    }
    
    @objc private func didAppear(notification: NSNotification) {
        accessToken = notification.userInfo?["accessToken"] as! String
        searchTextField.becomeFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell

        songCell.nameLabel.text = "Test 1"
        songCell.artistLabel.text = "Test 2"
        songCell.durationLabel.text = "Test 3"

        return songCell
    }

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print((textField.text ?? "") + string)
        
        AF.request("https://api.spotify.com/v1/search", method: .get, parameters: ["access_token":accessToken, "q":"100 bands", "type":"track"], encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil).response { response in
            debugPrint(response)
        }
        
        return true
    }
}
