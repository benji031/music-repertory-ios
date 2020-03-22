//
//  LibraryViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 30/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

protocol LibraryPickerDelegate: class {
    func libraryPicker(controller: LibraryViewController, didPickMusics musics: [Music])
}

class LibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: LibraryPickerDelegate?
    
    var context: NSManagedObjectContext?
    
    var repertoryService: RepertoryService?
    
    var musics = [Music]()
    var selectedMusics = [Music]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        
        reloadData()
    }
    
    func reloadData() {
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
        
        delegate?.libraryPicker(controller: self, didPickMusics: selectedMusics)
        
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
        
        let music = musics[indexPath.row]
        cell.textLabel?.text = music.name
        cell.isSelected = selectedMusics.contains(music)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        
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
        guard let _ = repertoryService?.import(pdfMusicFromFile: url, in: nil) else {
            let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        reloadData()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            guard let _ = repertoryService?.import(pdfMusicFromFile: url, in: nil) else {
                let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            reloadData()
        }
    }
    
}
