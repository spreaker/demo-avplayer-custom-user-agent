//
//  ViewController.swift
//  AVPlayerCustomUserAgent
//
//  Created by Alessandro "Sandro" Calzavara on 30/04/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var urlField: UITextField! {
        didSet {
            urlField.delegate = self
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    
    var player = AVPlayer()
    var playableURLString: String {
        if let text = urlField.text, !text.isEmpty {
            return text
        }
        return "https://api.spreaker.com/v2/episodes/44319865/download.mp3"
    }
    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            fatalError("Unable to configure audio session: \(error)")
        }
        
        // Prepare UI
        self.urlField.text = nil
        self.urlField.placeholder = playableURLString
        
        // Reset player
        self.reset()
    }
    
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = avplayer.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.timeLabel.text = time.humanDescription()
        }
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            avplayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - IBActions

    /**
     * Plain usage of AVPlayer API.
     * All performed requests contains the default User-Agent "AppleCoreMedia"
     * Not recommended.
     *
     * PRO:
     * - Zero setup. Ready to go.
     * CONS:
     * - Network requests contains the default User-Agent "AppleCoreMedia" so the listen is not correctly attributed to your app.
     */
    @IBAction func demo1AVPlayer() {
        print("> AVPlayer ------------------------------------------------------- ")
        print(playableURLString)
        
        let url = URL(string: playableURLString)!
        let playerItem = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    /**
     * Usage of AVPlayer API with a customized headers
     * Recommended.
     *
     * PRO:
     * - Network requests contains the customized User-Agent "MyPodcastApp", so the listen is correctly attributed to your app.
     * CONS:
     * - It used an undocumented key "AVURLAssetHTTPHeaderFieldsKey" that might change on newer versions of iOS.
     */
    @IBAction func demo3AVPlayerCustomHeaders() {
        print("> AVPlayer Custom Headers ------------------------------------------------------- ")
        print(playableURLString)
        
        let url = URL(string: playableURLString)!
        let headers: [String: Any] = [ "User-Agent": UserAgent.default ]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    @IBAction func reset() {
        removePeriodicTimeObserver()
        player.pause()
        
        player = AVPlayer()
        addPeriodicTimeObserver()
        
        print("> RESET ------------------------------------------------------- ")
    }
    
    @IBAction func seekBack() {
        let newTime = player.currentTime().timeWithOffset(-30)
        if (newTime.isValid) {
            player.seek(to: newTime)
        }
    }
    
    @IBAction func seekForward() {
        let newTime = player.currentTime().timeWithOffset(+30)
        if (newTime.isValid) {
            player.seek(to: newTime)
        }
    }
    
    @IBAction func seekForwardMinutes() {
        let newTime = player.currentTime().timeWithOffset(+5*60)
        if (newTime.isValid) {
            player.seek(to: newTime)
        }
    }
}
