//
//  LibraryViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 30/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

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
    }
    
    @IBAction func doneButtonDidTouch(_ sender: Any) {
        guard let repertory = repertoryImport else {
            return
        }
        
        for music in selectedMusics {
            repertoryService?.add(music, to: repertory)
        }
        
        navigationController?.popViewController(animated: true)
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
