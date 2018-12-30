//
//  DocumentsViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 21/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit
import MobileCoreServices

typealias Document = (url: URL, name: String)

class DocumentsViewController: UIViewController {

    var repertoryService: RepertoryService?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadDocument), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor(red: 255/255.0, green: 129/255.0, blue: 38/255.0, alpha: 1.0)
        return refreshControl
    }()
    
    var repertory: Repertory!
    var musics = [RepertoryMusic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = repertory.name
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
        
        self.loadDocument()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDocument()
    }
    
    @objc func loadDocument() {
        musics = repertoryService?.get(musicsFor: repertory) ?? [RepertoryMusic]()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DocumentSegue" {
            let destination = segue.destination as! DocumentViewerViewController
            destination.allMusics = musics.compactMap({ $0.music })
            destination.repertory = repertory
            destination.currentMusic = musics[sender as! Int].music
        }
        if segue.identifier == "LibrarySegue" {
            let destination = segue.destination as! LibraryViewController
            destination.repertoryImport = repertory
        }
    }
 
    @IBAction func addDocumentButtonDidTouch(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Ajouter un morceau", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Bibliothèque", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "LibrarySegue", sender: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Importer", style: .default, handler: { (_) in
            self.importDocument()
        }))
        actionSheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func editButtonDidTouched(_ sender: Any) {
        if(tableView.isEditing == true)
        {
            tableView.setEditing(false, animated: true)
            editButton.style = .plain
            editButton.title = "Edit"
            addButton.isEnabled = true
            repertoryService?.saveOrder(musics, in: repertory)
        }
        else
        {
            tableView.setEditing(true, animated: true)
            editButton.style = .done
            editButton.title = "Done"
            addButton.isEnabled = false
        }
    }
    
    
    
    func rename(music: Music, by newName: String) {
        music.name = newName
        
    }

    func delete(music: Music, at indexPath: IndexPath? = nil) {
        repertoryService?.remove(music, from: repertory)

        if let indexPath = indexPath {
            musics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func importDocument() {
        let documentPicker = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
}

extension DocumentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        cell.textLabel?.text = musics[indexPath.row].music?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Renomer") { (action, indexPath) in
            guard let music = self.musics[indexPath.row].music else {
                return
            }

            let alert = UIAlertController(title: "Renommer le morceau", message: "Entrez le nom du morceau ci dessous : ", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = music.name
            })
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (action) in
                guard let newName = alert.textFields?.first?.text else {
                    return
                }
                self.rename(music: music, by: newName)
                self.loadDocument()
            }))
            self.present(alert, animated: true, completion: nil)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action, indexPath) in
            guard let music = self.musics[indexPath.row].music else {
                return
            }

            let alert = UIAlertController(title: "Supprimer le document", message: "Voulez-vous vraiment supprimer le document \(music.name ?? "") ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { (_) in
                self.delete(music: music, at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

        return [rename, delete]
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let musicMoved = musics[sourceIndexPath.row]
        musics.remove(at: sourceIndexPath.row)
        musics.insert(musicMoved, at: destinationIndexPath.row)
    }
}

extension DocumentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DocumentSegue", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension DocumentsViewController: UIDocumentMenuDelegate {
    
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

extension DocumentsViewController: UIDocumentPickerDelegate {
    
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
                guard let music = repertoryService?.create(pdfMusicWithName: url.lastPathComponent, andPdfFile: data, in: self.repertory) else {
                    Log("An error occured trying to copy file from document picker view controller to local repertory!")
                    let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
//                let _ = repertoryService?.insert(music: music, in: repertory)
                self.loadDocument()
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
