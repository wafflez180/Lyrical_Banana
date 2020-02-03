//
//  SelectSongViewController.swift
//  Lyrical_Banana
//
//  Created by Arthur De Araujo on 2/2/20.
//  Copyright © 2020 Arthur De Araujo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class SelectSongViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var songTableView: UITableView!
    
    var accessToken: String?
    var songList: [SpotifySong] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        songTableView.dataSource = self
        songTableView.register(UINib.init(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        songTableView.tableFooterView = UIView()

        NotificationCenter.default.addObserver(self, selector: #selector(didAppear), name: Notification.Name("showSelectSongView"), object: nil)
    }
    
    @objc private func didAppear(notification: NSNotification) {
        accessToken = notification.userInfo?["accessToken"] as! String
        searchTextField.becomeFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        let song = songList[indexPath.row]
        
        songCell.nameLabel.text = songList[indexPath.row].name
        
        let seconds = Int((song.durationMilliSec/1000)%60)
            , minutes = Int((song.durationMilliSec/(1000*60))%60)
        songCell.durationLabel.text = "\(minutes):\(seconds)"
        
        var artistLabelText = ""
        for artistName in song.artists {
            artistLabelText += artistName
            if songList[indexPath.row].artists.last != artistName {
                artistLabelText += ", "
            }
        }
        songCell.artistLabel.text = artistLabelText
        songCell.songImageView?.kf.setImage(with: URL(string: song.albumImageLink))
        
        return songCell
    }

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = ((textField.text ?? "") + string)
        
        if string == "" {
            songList = []
            self.songTableView.reloadData()
            return true
        }
        
        AF.request("https://api.spotify.com/v1/search", method: .get, parameters: ["access_token":accessToken, "q":searchText, "type":"track"], encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil).response { response in
            let jsonResponse = JSON.init(response.value!)

            self.songList = []
            for spotifySongJSON in jsonResponse["tracks"]["items"].array! {
                self.songList.append(SpotifySong.init(json: spotifySongJSON))
            }
            
            self.songTableView.reloadData()
            //debugPrint(response)
        }
        
        return true
    }
}
