//
//  SoundViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 19/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol SoundViewControllerDelegate: class {
    func soundViewController(_ viewController: SoundViewController, didSelectSound sound: Sound?)
}

class SoundViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SoundViewControllerDelegate?
    
    var soundService: SoundService?
    
    var music: Music?
    var selectedSound: Sound?
    
    var sounds = [Sound]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = music else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadSounds()
    }
    
    func loadSounds() {
        sounds = soundService?.find(soundsFor: music!) ?? []
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addSoundButtonDidTouch(_ sender: Any) {
        importSound()
    }
    
    func importSound() {
        let documentPicker = UIDocumentMenuViewController(documentTypes: [String(kUTTypeMP3)], in: .import)
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func rename(sound: Sound, by newName: String) {
        sound.name = newName
        let _ = soundService?.save(sound)
    }
    
    func delete(sound: Sound, at indexPath: IndexPath?) {
        soundService?.remove(sound)

        if let indexPath = indexPath {
            sounds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}

extension SoundViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        
        let sound = sounds[indexPath.row]
        cell.textLabel?.text = sound.name
        if sound.objectID == selectedSound?.objectID {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}

extension SoundViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        delegate?.soundViewController(self, didSelectSound: sounds[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Renommer") { (action, indexPath) in
            let sound = self.sounds[indexPath.row]

            let alert = UIAlertController(title: "Renommer", message: "Entrez le nom du son", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = sound.name
            })
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (action) in
                guard let newName = alert.textFields?.first?.text else {
                    return
                }
                self.rename(sound: sound, by: newName)
                self.loadSounds()
            }))
            self.present(alert, animated: true, completion: nil)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action, indexPath) in
            let sound = self.sounds[indexPath.row]

            let alert = UIAlertController(title: "Supprimer", message: "Voulez-vous vraiment supprimer le son \(sound.name ?? "") ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { (_) in
                self.delete(sound: sound, at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

        return [rename, delete]
    }
}

extension SoundViewController: UIDocumentMenuDelegate {
    
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

extension SoundViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard let _ = soundService?.import(soundFromFile: url, for: music!) else {
            let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        loadSounds()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            guard let _ = soundService?.import(soundFromFile: url, for: music!) else {
                let alert = UIAlertController(title: "Erreur", message: "Impossible de copier le fichier, une erreur est survenu...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            loadSounds()
        }
    }
    
}
