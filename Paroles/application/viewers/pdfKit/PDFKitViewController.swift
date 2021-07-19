//
//  PDFKitViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 19/07/2021.
//  Copyright © 2021 Bananapps. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
class PDFKitViewController: UIViewController {

    let pdfView: PDFView = PDFView()
    
    init(fileData: Data) {
        let doc = PDFKit.PDFDocument(data: fileData)
        pdfView.document = doc
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        
        self.view = pdfView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

@available(iOS 11.0, *)
extension PDFKitViewController: MusicViewControllable {
    
    func has(_ direction: Direction) -> Bool {
        switch direction {
        case .next:
            guard let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage),
                  let _ = pdfView.document?.page(at: index + 1) else {
                return false
            }
            return true
        case .previous:
            guard let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage),
                  let _ = pdfView.document?.page(at: index - 1) else {
                return false
            }
            return true
        }
    }
    
    func go(to direction: Direction) {
        switch direction {
        case .next:
            guard let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage),
                  let nextPage = pdfView.document?.page(at: index + 1) else {
                return
            }
            pdfView.go(to: nextPage)
            break
        case .previous:
            guard let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage),
                  let previousPage = pdfView.document?.page(at: index - 1) else {
                return
            }
            pdfView.go(to: previousPage)
        }
    }
    
    func go(at position: Position, animated: Bool) {
        switch position {
        case .start:
            pdfView.goToFirstPage(nil)
            break
        case .page(index: let index):
            if let page = pdfView.document?.page(at: index) {
                pdfView.go(to: page)
            }
            break
        case .end:
            pdfView.goToLastPage(nil)
            break
        }
    }
    
    
    
    
}
