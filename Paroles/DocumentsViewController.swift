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

    @IBOutlet weak var tableView: UITableView!
    
    var documents = [Document]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        self.loadDocument()
    }

    func loadDocument() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            documents = fileURLs.compactMap({ (url) -> (url: URL, name: String)? in
                return url.pathExtension == "pdf" ? (url: url, name: url.deletingPathExtension().lastPathComponent) : nil
            })
            
            tableView.reloadData()
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
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
            let destination = segue.destination as! PDFViewController
            destination.documents = documents
            destination.selectedDocument = sender as! Int
        }
    }
 
    @IBAction func addDocumentButtonDidTouch(_ sender: Any) {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
//        documentPicker.modalPresentationStyle = .formSheet
//        present(documentPicker, animated: true, completion: nil)
    }
    
    func rename(document: Document, by newName: String) {
        guard !newName.isEmpty else {
            return
        }
        
        let originPath = document.url
        let destinationPath = originPath.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension("pdf")
        try? FileManager.default.moveItem(at: originPath, to: destinationPath)
    }
    
}

extension DocumentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        cell.textLabel?.text = documents[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Renomer") { (action, indexPath) in
            let document = self.documents[indexPath.row]
            
            let alert = UIAlertController(title: "Renommer le morceau", message: "Entrez le nom du morceau ci dessous : ", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = document.name
            })
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (action) in
                guard let newName = alert.textFields?.first?.text else {
                    return
                }
                self.rename(document: document, by: newName)
                self.loadDocument()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        return [rename]
    }
}

extension DocumentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DocumentSegue", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
