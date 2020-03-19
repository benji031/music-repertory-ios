//
//  PlayerToolBar.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 19/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {

    var playBarButtonItem: UIBarButtonItem!
    var pauseBarButtonItem: UIBarButtonItem!
    var stopBarButtonItem: UIBarButtonItem!
    
    var audioPlayer: AVAudioPlayer?
    
    func configure() {
        playBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(AudioViewController.play))
        pauseBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(AudioViewController.pause))
        stopBarButtonItem = UIBarButtonItem(image: UIImage(named: "sound_previous"), style: .plain, target: self, action: #selector(stop))
    }
    
    func loadSound(contentOf url: URL) {
        do {
            configure()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            
            navigationController?.setToolbarHidden(false, animated: true)
                setToolbarItems([stopBarButtonItem, playBarButtonItem], animated: true)
        }
        catch let error {
            NSLog("Failed start play sound : \(error)")
        }
    }
    
    @objc func play() {
        audioPlayer?.play()
        setToolbarItems([stopBarButtonItem, pauseBarButtonItem], animated: true)
    }
    
    @objc func pause() {
        audioPlayer?.pause()
        setToolbarItems([stopBarButtonItem, playBarButtonItem], animated: true)
    }
    
    @objc func stop() {
        audioPlayer?.currentTime = 0
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
