//
//  PDFViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 21/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit
import WebKit


enum Direction {
    case next
    case previous
}

class TempPDFViewController: UIViewController {

    var webView: WKWebView = WKWebView()
    
    var documents = [(url: URL, name: String)]()
    var selectedDocument = 0
    var currentPage: CGFloat {
        get {
            return round(webView.scrollView.contentOffset.y / webView.frame.height)
        }
        set {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, at: 0)
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadNewPDF()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNewPDF(to direction: Direction? = nil) {
        if let direction = direction {
            switch direction {
            case .next:
                selectedDocument = selectedDocument == (documents.count - 1) ? selectedDocument : selectedDocument + 1
                break
            case .previous:
                selectedDocument = selectedDocument - 1 >= 0 ? selectedDocument - 1 : 0
                break
            }
        }
        
        let data = try! Data(contentsOf: documents[selectedDocument].url)
        webView.load(data, mimeType: "application/pdf", characterEncodingName:"", baseURL: documents[selectedDocument].url.deletingLastPathComponent())
        title = documents[selectedDocument].name
        currentPage = 0
        
        let document = PDFDocument(fileData: data, fileName: "Sample PDF")!
        let controller = PDFReader.PDFViewController.createNew(with: document, isThumbnailsEnabled: false)
        controller.
    }
    
    @IBOutlet var nextTapGestureRecognizerDidTapped: UITapGestureRecognizer!
    
    @IBAction func nextTapGestureRecognizerDidTapped(_ sender: Any) {
        let maxOffest = webView.scrollView.contentSize.height - webView.frame.height
        let pageHeightOffset = min((webView.frame.height * (currentPage + 1)), maxOffest)
        
        if round(webView.scrollView.contentOffset.y) == round(maxOffest) {
            loadNewPDF(to: .next)
        }
        else {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: pageHeightOffset), animated: true)
        }
    }
    
    @IBAction func prevTapGestureRecognizerDidTouch(_ sender: Any) {
        let minOffset: CGFloat = 0
        let pageHeightOffest = max(webView.frame.height * (currentPage - 1), minOffset)
        
        if webView.scrollView.contentOffset.y == minOffset {
            loadNewPDF(to: .previous)
        }
        else {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: pageHeightOffest), animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
