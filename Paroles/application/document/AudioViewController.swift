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
    var sliderBarButtonItem: UIBarButtonItem!
    
    var slider: UISlider!
    var updater : CADisplayLink!
    
    var audioPlayer: AVAudioPlayer?
    
    func configure() {
        playBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(AudioViewController.play))
        pauseBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(AudioViewController.pause))
        stopBarButtonItem = UIBarButtonItem(image: UIImage(named: "sound_previous"), style: .plain, target: self, action: #selector(stop))
        
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        sliderBarButtonItem = UIBarButtonItem(customView: slider)
    }
    
    func loadSound(contentOf url: URL) {
        do {
            configure()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            
            navigationController?.setToolbarHidden(false, animated: true)
                setToolbarItems([stopBarButtonItem, playBarButtonItem, sliderBarButtonItem], animated: true)
            
            updater = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        }
        catch let error {
            NSLog("Failed start play sound : \(error)")
        }
    }
    
    @objc func play() {
        audioPlayer?.play()
        setToolbarItems([stopBarButtonItem, pauseBarButtonItem, sliderBarButtonItem], animated: true)
    }
    
    @objc func pause() {
        audioPlayer?.pause()
        setToolbarItems([stopBarButtonItem, playBarButtonItem, sliderBarButtonItem], animated: true)
    }
    
    @objc func stop() {
        audioPlayer?.currentTime = 0
    }
    
    @objc func updateSliderProgress() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let progress = (audioPlayer.currentTime * 100) / audioPlayer.duration
        slider.setValue(Float(progress), animated: true)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
