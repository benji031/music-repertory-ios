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

    var playButton: UIButton!
    var stopButton: UIButton!
    var slider: UISlider!
    var currentTimeLabel: UILabel!
    var durationLabel: UILabel!
    
    var stackBarButtonItem: UIBarButtonItem!
    
    var updater : CADisplayLink!
    var audioPlayer: AVAudioPlayer?
    
    func configure() {
        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textColor = .white
        
        
        slider = UISlider()
        slider.addTarget(self, action: #selector(setTime), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        durationLabel = UILabel()
        durationLabel.text = "00:00"
        durationLabel.textColor = .white
        
        if #available(iOS 13.0, *) {
            durationLabel.font = UIFont.monospacedSystemFont(ofSize: 8.0, weight: .thin)
            currentTimeLabel.font = UIFont.monospacedSystemFont(ofSize: 8.0, weight: .thin)
        } else {
            durationLabel.font = UIFont.systemFont(ofSize: 8.0, weight: .thin)
            currentTimeLabel.font = UIFont.systemFont(ofSize: 8.0, weight: .thin)
        }
        
        stopButton = UIButton()
        stopButton.setImage(UIImage(named: "sound_previous"), for: .normal)
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        
        playButton = UIButton()
        playButton.setImage(UIImage(named: "sound_play"), for: .normal)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        
        let stackView = UIStackView(frame: navigationController!.toolbar.frame)
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(currentTimeLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(playButton)
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        
        stackBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    func loadSound(contentOf url: URL) {
        do {
            configure()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            
            navigationController?.setToolbarHidden(false, animated: true)
                setToolbarItems([stackBarButtonItem], animated: true)
            
            updater = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        }
        catch let error {
            NSLog("Failed start play sound : \(error)")
        }
    }
    
    @objc func play() {
        audioPlayer?.play()
        playButton.setImage(UIImage(named: "sound_pause"), for: .normal)
        playButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
    }
    
    @objc func pause() {
        audioPlayer?.pause()
        playButton.setImage(UIImage(named: "sound_play"), for: .normal)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
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
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale
        
        currentTimeLabel.text = formatter.string(from: audioPlayer.currentTime)
        durationLabel.text = formatter.string(from: audioPlayer.duration)
    }
    
    @objc func setTime() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let value = TimeInterval(slider.value)
        let time = (value * audioPlayer.duration) / 100
        audioPlayer.currentTime = time
    }

}
