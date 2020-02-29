//
//  LibraryViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 30/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit
import MobileCoreServices

class LibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var repertoryService: RepertoryService?
    
    var musics = [Music]()
    var selectedMusics = [Music]()
    
    var repertoryImport: Repertory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        
        reloadData()
    }
    
    func reloadData() {
        guard let context = repertoryImport?.managedObjectContext else {
            return
        }
        musics = repertoryService?.getMusics(in: context) ?? [Music]()
        self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addButtonDidTouch(_ sender: Any) {
        let documentPicker = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonDidTouch(_ sender: Any) {
        guard let repertory = repertoryImport else {
            return
        }
        
        for music in selectedMusics {
            repertoryService?.add(music, to: repertory)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension LibraryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        
        cell.textLabel?.text = musics[indexPath.row].name
        
        return cell
    }
}

extension LibraryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        selectedMusics.append(musics[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        selectedMusics.removeAll(where: { $0 === musics[indexPath.row] })
    }
    
}

extension LibraryViewController: UIDocumentMenuDelegate {
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        documentMenu.dismiss(animated: true, completion: nil)
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = true
        }
        present(documentPicker, animated: true, completion: nil)
    }
    
}

extension LibraryViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        importDocumentAt(url: url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            importDocumentAt(url: url)
        }
    }
    
    func importDocumentAt(url: URL) {
        let isSecured = url.startAccessingSecurityScopedResource()
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        coordinator.coordinate(readingItemAt: url, options: [.forUploading], error: &error) { (url) in
            
            do {
                let data = try Data(contentsOf: url)
                guard let _ = repertoryService?.create(pdfMusicWithName: url.lastPathComponent, andPdfFile: data, in: nil) else {
                    Log("An error occured trying to copy file from document picker view controller to local repertory!")
                    let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                reloadData()
            }
            catch let error {
                Log("An error occured trying to copy file from document picker view controller to local repertory! \(error.localizedDescription)")
                let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu... \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        if let error = error {
            let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu... \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if isSecured { url.stopAccessingSecurityScopedResource() }
    }
    
}
