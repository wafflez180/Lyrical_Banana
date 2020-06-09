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
import MediaPlayer
import StoreKit

class SelectSongViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var songTableView: UITableView!
    
    var songList: [SearchSongResult] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        songTableView.delegate = self
        songTableView.dataSource = self
        songTableView.register(UINib.init(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        songTableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didAppear), name: Notification.Name("showSelectSongView"), object: nil)
    }
    
    @objc private func didAppear(notification: NSNotification) {
        self.searchTextField.becomeFirstResponder()
    }
        
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        let songResult = songList[indexPath.row]
        songCell.configureCellWith(songResult: songResult)

        return songCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSongResult = songList[indexPath.row]
        MusicPlayerManager.shared.currentSong = selectedSongResult
        
        if let appleMusicManager = MusicPlayerManager.shared.musicService as? AppleMusicManager {
            appleMusicManager.prepareToPlay()
        }
        
        self.searchTextField.resignFirstResponder()
        NotificationCenter.default.post(name: Notification.Name("didSelectSong"), object: nil, userInfo: nil)
    }

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = ((textField.text ?? "") + string)
        
        if string == "" {
            songList = []
            self.songTableView.reloadData()
            return true
        }
        
        let spotifyIsConnected = (MusicPlayerManager.shared.musicService as? SpotifyManager)?.appRemote.isConnected ?? false
        if let appleMusicManager = (MusicPlayerManager.shared.musicService as? AppleMusicManager) {
            SKCloudServiceController().requestStorefrontCountryCode { countryCode, error in
                AF.request("https://itunes.apple.com/search", method: .get, parameters: ["term":searchText.replacingOccurrences(of: " ", with: "+"), "media":"music", "limit":"15"], encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil).response { response in
                    let jsonResponse = JSON.init(response.value!)
                    
                    self.songList = []
                    for appleMusicSongJSON in jsonResponse["results"].array! {
                        self.songList.append(AppleMusicSongResult.init(json: appleMusicSongJSON))
                    }
                    
                    self.songTableView.reloadData()
                }

            }
        } else if let spotifyManager = (MusicPlayerManager.shared.musicService as? SpotifyManager) {
            AF.request("https://api.spotify.com/v1/search", method: .get, parameters: ["access_token":spotifyManager.spotifyAccessToken, "q":searchText, "type":"track"], encoder: URLEncodedFormParameterEncoder.default, headers: nil, interceptor: nil).response { response in
                let jsonResponse = JSON.init(response.value!)

                self.songList = []
                for spotifySongJSON in jsonResponse["tracks"]["items"].array! {
                    self.songList.append(SpotifySongResult.init(json: spotifySongJSON))
                }

                self.songTableView.reloadData()
                //debugPrint(response)
            }
        }
        
        return true
    }
}
