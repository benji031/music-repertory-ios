//  PDFViewController.swift
//  PDFReader
//
//  Created by ALUA KINZHEBAYEVA on 4/19/15.
//  Copyright (c) 2015 AK. All rights reserved.
//

import UIKit

extension PDFViewController {
    /// Initializes a new `PDFViewController`
    ///
    /// - parameter document:            PDF document to be displayed
    /// - parameter title:               title that displays on the navigation bar on the PDFViewController; 
    ///                                  if nil, uses document's filename
    /// - parameter actionButtonImage:   image of the action button; if nil, uses the default action system item image
    /// - parameter actionStyle:         sytle of the action button
    /// - parameter backButton:          button to override the default controller back button
    /// - parameter isThumbnailsEnabled: whether or not the thumbnails bar should be enabled
    /// - parameter startPageIndex:      page index to start on load, defaults to 0; if out of bounds, set to 0
    ///
    /// - returns: a `PDFViewController`
    public class func createNew(with document: PDFDocument, actionButtonImage: UIImage? = nil, actionStyle: ActionStyle = .print, isThumbnailsEnabled: Bool = true, startPageIndex: Int = 0) -> PDFViewController {
        let storyboard = UIStoryboard(name: "PDFReader", bundle: Bundle(for: PDFViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! PDFViewController
        controller.document = document
        controller.actionStyle = actionStyle
        

        controller.title = document.fileName
        
        
        if startPageIndex >= 0 && startPageIndex < document.pageCount {
            controller.currentPageIndex = startPageIndex
        } else {
            controller.currentPageIndex = 0
        }
        
//        controller.backButton = backButton
        
        if let actionButtonImage = actionButtonImage {
            controller.actionButton = UIBarButtonItem(image: actionButtonImage, style: .plain, target: controller, action: #selector(actionButtonPressed))
        } else {
            controller.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: controller, action: #selector(actionButtonPressed))
        }
        controller.isThumbnailsEnabled = isThumbnailsEnabled
        return controller
    }
    
    class func createNew(with documents: [Document], selectedDocument: Int) -> PDFViewController {
        let data = try! Data(contentsOf: documents[selectedDocument].url)
        let document = PDFDocument(fileData: data, fileName: documents[selectedDocument].name)
        
        let controller = createNew(with: document!)
//        controller.selectedDocument = selectedDocument
//        controller.documents = documents
        
        return controller
    }
}

/// Controller that is able to interact and navigate through pages of a `PDFDocument`
public final class PDFViewController: UIViewController {
    /// Action button style
    public enum ActionStyle {
        /// Brings up a print modal allowing user to print current PDF
        case print
        
        /// Brings up an activity sheet to share or open PDF in another app
        case activitySheet
        
        /// Performs a custom action
        case customAction(() -> ())
    }
    
    /// Collection veiw where all the pdf pages are rendered
    @IBOutlet public var collectionView: UICollectionView!
    
    /// Height of the thumbnail bar (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerHeight: NSLayoutConstraint!
    
    /// Distance between the bottom thumbnail bar with bottom of page (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerBottom: NSLayoutConstraint!
    
    /// Width of the thumbnail bar (used to resize on rotation events)
    @IBOutlet private var thumbnailCollectionControllerWidth: NSLayoutConstraint!
    
    /// PDF document that should be displayed
    private var document: PDFDocument!
    
    private var actionStyle = ActionStyle.print
    
    /// Image used to override the default action button image
    private var actionButtonImage: UIImage?
    
    /// Current page being displayed
    private var currentPageIndex: Int = 0
    
    /// Bottom thumbnail controller
    private var thumbnailCollectionController: PDFThumbnailCollectionViewController?
    
    /// UIBarButtonItem used to override the default action button
    private var actionButton: UIBarButtonItem?
    
    /// Backbutton used to override the default back button
    private var backButton: UIBarButtonItem?
    
    /// Background color to apply to the collectionView.
    public var backgroundColor: UIColor? = .lightGray {
        didSet {
            collectionView?.backgroundColor = backgroundColor
        }
    }
    
    var repertory: Repertory!
    var music: Music!
    
    var repertoryService: RepertoryService?
    
    /// Whether or not the thumbnails bar should be enabled
    var isThumbnailsEnabled = true {
        didSet {
            if thumbnailCollectionControllerHeight == nil {
                _ = view
            }
            if !isThumbnailsEnabled {
                thumbnailCollectionControllerHeight.constant = 0
            }
        }
    }
    
    /// Slides horizontally (from left to right, default) or vertically (from top to bottom)
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            if collectionView == nil {  // if the user of the controller is trying to change the scrollDiecton before it
                _ = view                // is on the sceen, we need to show it ofscreen to access it's collectionView.
            }
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.backgroundColor = backgroundColor
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")
        
        let nextTouchView = UIView()
        nextTouchView.backgroundColor = UIColor.clear
        nextTouchView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(nextTouchView, aboveSubview: collectionView)
        
        nextTouchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nextTouchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nextTouchView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        nextTouchView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4) .isActive = true
        
        let nextTouchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextPageOrPDF))
        nextTouchView.addGestureRecognizer(nextTouchGestureRecognizer)
        
        let previousTouchView = UIView()
        previousTouchView.backgroundColor = UIColor.clear
        previousTouchView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(previousTouchView, aboveSubview: collectionView)
        
        previousTouchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previousTouchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previousTouchView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previousTouchView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4) .isActive = true
        
        let previousTouchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previousPageOrPDF))
        previousTouchView.addGestureRecognizer(previousTouchGestureRecognizer)
    }
    
    func loadPDF(to direction: Direction? = nil) {
        
    
        
        title = document.fileName
        
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        
        self.collectionView.reloadData()
        thumbnailCollectionController?.collectionView?.reloadData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didSelectIndexPath(IndexPath(row: currentPageIndex, section: 0))
    }
    
    override public var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isThumbnailsEnabled
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PDFThumbnailCollectionViewController {
            thumbnailCollectionController = controller
            controller.document = document
            controller.delegate = self
            controller.currentPageIndex = currentPageIndex
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            let currentIndexPath = IndexPath(row: self.currentPageIndex, section: 0)
            self.collectionView.reloadItems(at: [currentIndexPath])
            self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
            }) { context in
                self.thumbnailCollectionController?.currentPageIndex = self.currentPageIndex
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    /// Takes an appropriate action based on the current action style
    @objc func actionButtonPressed() {
        switch actionStyle {
        case .print:
            print()
        case .activitySheet:
            presentActivitySheet()
        case .customAction(let customAction):
            customAction()
        }
    }
    
    /// Presents activity sheet to share or open PDF in another app
    private func presentActivitySheet() {
        let controller = UIActivityViewController(activityItems: [document.fileData], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = actionButton
        present(controller, animated: true, completion: nil)
    }
    
    /// Presents print sheet to print PDF
    private func print() {
        guard UIPrintInteractionController.isPrintingAvailable else { return }
        guard UIPrintInteractionController.canPrint(document.fileData) else { return }
        guard document.password == nil else { return }
        let printInfo = UIPrintInfo.printInfo()
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = document.fileName
        
        let printInteraction = UIPrintInteractionController.shared
        printInteraction.printInfo = printInfo
        printInteraction.printingItem = document.fileData
        printInteraction.showsPageRange = true
        printInteraction.present(animated: true, completionHandler: nil)
    }
    
    @objc func nextPageOrPDF() {
        if currentPageIndex < (document.pageCount - 1) {
            collectionView.scrollToItem(at: IndexPath(row: currentPageIndex + 1, section: 0), at: .left, animated: true)
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
        else {
            loadPDF(to: .next)
        }
    }
    
    @objc func previousPageOrPDF() {
        if currentPageIndex > 0 {
            collectionView.scrollToItem(at: IndexPath(row: currentPageIndex - 1, section: 0), at: .left, animated: true)
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
        else {
            loadPDF(to: .previous)
        }
    }
}

extension PDFViewController: PDFThumbnailControllerDelegate {
    func didSelectIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        thumbnailCollectionController?.currentPageIndex = currentPageIndex
    }
}

extension PDFViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PDFPageCollectionViewCell
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        return cell
    }
}

extension PDFViewController: PDFPageCollectionViewCellDelegate {
    /// Toggles the hiding/showing of the thumbnail controller
    ///
    /// - parameter shouldHide: whether or not the controller should hide the thumbnail controller
    private func hideThumbnailController(_ shouldHide: Bool) {
        self.thumbnailCollectionControllerBottom.constant = shouldHide ? -thumbnailCollectionControllerHeight.constant : 0
    }
    
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        UIView.animate(withDuration: 0.25) {
            self.hideThumbnailController(shouldHide)
            self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        }
    }
}

extension PDFViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

extension PDFViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let updatedPageIndex: Int
        if self.scrollDirection == .vertical {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.y, 0) / scrollView.bounds.height))
        } else {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.x, 0) / scrollView.bounds.width))
        }
        
        if updatedPageIndex != currentPageIndex {
            currentPageIndex = updatedPageIndex
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
    }
}


extension PDFViewController: MusicViewControllable {
    
    func has(_ direction: Direction) -> Bool {
        switch direction {
        case .next:
            return currentPageIndex < (document.pageCount - 1)
        case .previous:
            return currentPageIndex > 0
        }
    }
    
    func go(to direction: Direction) {
        switch direction {
        case .next:
            guard has(.next) else { return }
            collectionView.scrollToItem(at: IndexPath(row: currentPageIndex + 1, section: 0), at: .left, animated: true)
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
            break
        case .previous:
            guard has(.previous) else { return }
            collectionView.scrollToItem(at: IndexPath(row: currentPageIndex - 1, section: 0), at: .right, animated: true)
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
            break
        }
    }
    
    func go(at position: Position, animated: Bool) {
        let newPosition: Int
        switch position {
        case .start:
            newPosition = 0
            break
        case .page(index: let i):
            newPosition = min(i, document.pageCount - 1)
            break
        case .end:
            newPosition = document.pageCount - 1
            break
        }
        
        collectionView.scrollToItem(at: IndexPath(row: newPosition, section: 0), at: .left, animated: animated)
        thumbnailCollectionController?.currentPageIndex = 0
    }
    
}
