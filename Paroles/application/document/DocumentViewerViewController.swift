//
//  DocumentViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 24/11/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

class DocumentViewerViewController: AudioViewController {
    
    @IBOutlet weak var previousView: UIView!
    @IBOutlet weak var nextView: UIView!
    
    var allMusics: [Music] = [Music]()
    var currentMusic: Music!
    var currentSound: Sound?
    var repertory: Repertory!
    
    var repertoryService: RepertoryService?
    var soundService: SoundService?
    
    var currentMusicController: MusicViewControllable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let nextTouchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextTouched))
        nextView.addGestureRecognizer(nextTouchGestureRecognizer)
        let previousTouchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previousTouched))
        previousView.addGestureRecognizer(previousTouchGestureRecognizer)
        
        guard let currentMusic = self.currentMusic else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        navigationController?.toolbar.barTintColor = navigationController?.navigationBar.barTintColor
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor
        navigationController?.toolbar.isTranslucent = navigationController?.navigationBar.isTranslucent ?? false
        
        display(currentMusic)
    }
    
    func display(_ music: Music, at position: Position = .start) {
        
        if let currentMusicController = currentMusicController as? UIViewController {
            currentMusicController.view.removeFromSuperview()
            currentMusicController.removeFromParent()
            currentMusicController.willMove(toParent: nil)
        }
        
        title = music.name
        
        switch music {
        case is PDFMusic:
            
            guard let documentUrl = repertoryService?.getDocumentURL(for: music as! PDFMusic) else {
                return
            }
            
            guard let data = try? Data(contentsOf: documentUrl) else {
                return
            }
            
            guard let document = PDFDocument(fileData: data, fileName: music.name ?? "") else {
                return
            }
            
            let pdfViewController = PDFViewController.createNew(with: document)
            
            addChild(pdfViewController)
            pdfViewController.didMove(toParent: self)
            displayMusicViewer(pdfViewController.view)
            
            currentMusicController = pdfViewController
            break
        default:
            break
        }
        
        currentMusic = music
        currentMusicController?.go(at: position, animated: false)
        
        if let sound = soundService?.find(soundsFor: music).first, let soundUrl = soundService?.getSoundURL(for: sound) {
            loadSound(contentOf: soundUrl)
            currentSound = sound
            navigationController?.setToolbarHidden(false, animated: true)
        }
        else {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func displayMusicViewer(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(view, at: 0)
        
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0.0))
        
        self.view.layoutIfNeeded()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SoundSegue" {
            let destination = (segue.destination as! UINavigationController).viewControllers.first as! SoundViewController
            destination.music = currentMusic
            destination.selectedSound = currentSound
            destination.delegate = self
        }
    }
    
    
    @objc func nextTouched() {
        if currentMusicController?.has(.next) ?? false {
            currentMusicController?.go(to: .next)
        }
        else {
            guard let currentIndex = allMusics.firstIndex(of: currentMusic) else {
                return
            }
            guard let nextIndex = allMusics.index(currentIndex, offsetBy: 1, limitedBy: allMusics.count - 1) else {
                return
            }
            display(allMusics[nextIndex])
        }
    }
    
    @objc func previousTouched() {
        if currentMusicController?.has(.previous) ?? false {
            currentMusicController?.go(to: .previous)
        }
        else {
            guard let currentIndex = allMusics.firstIndex(of: currentMusic) else {
                return
            }
            guard let prevIndex = allMusics.index(currentIndex, offsetBy: -1, limitedBy: 0) else {
                return
            }
            display(allMusics[prevIndex], at: .end)
        }
    }

    @IBAction func associateMusicButtonDidTouch(_ sender: Any) {
    }
    
    
}

extension DocumentViewerViewController: SoundViewControllerDelegate {
    
    func soundViewController(_ viewController: SoundViewController, didSelectSound sound: Sound?) {
        if let sound = sound, let soundUrl = soundService?.getSoundURL(for: sound) {
            loadSound(contentOf: soundUrl)
            currentSound = sound
            navigationController?.setToolbarHidden(false, animated: true)
        }
        else {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
}
