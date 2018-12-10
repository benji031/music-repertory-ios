//
//  DocumentViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 24/11/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

class DocumentViewerViewController: UIViewController {
    
    @IBOutlet weak var previousView: UIView!
    @IBOutlet weak var nextView: UIView!
    
    var allMusics: [Music] = [Music]()
    var currentMusic: Music!
    var repertory: Repertory!
    
    var repertoryService: RepertoryService?
    
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
        
        display(currentMusic)
    }
    
    func display(_ music: Music) {
        
        if let currentMusicController = currentMusicController as? UIViewController {
            currentMusicController.view.removeFromSuperview()
            currentMusicController.removeFromParentViewController()
            currentMusicController.willMove(toParentViewController: nil)
        }
        
        switch music {
        case is PDFMusic:
            
            Log("This is pdf")
            
            guard let documentUrl = repertoryService?.getDocumentURL(for: music as! PDFMusic) else {
                return
            }
            
            let data = try! Data(contentsOf: documentUrl)
            guard let document = PDFDocument(fileData: data, fileName: music.name ?? "") else {
                return
            }
            
            let pdfViewController = PDFViewController.createNew(with: document)
            
            addChildViewController(pdfViewController)
            pdfViewController.didMove(toParentViewController: self)
            displayMusicViewer(pdfViewController.view)
            
            currentMusicController = pdfViewController
            break
        default:
            break
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            // Go to previous music
        }
    }

}
