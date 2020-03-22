//
//  RepertoriesViewController.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 06/06/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

class RepertoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadRepertories), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor(red: 255/255.0, green: 129/255.0, blue: 38/255.0, alpha: 1.0)
        return refreshControl
    }()
    
    var repertoryService: RepertoryService?
    
    var repertories = [Repertory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRepertories()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadRepertories() {
        repertories = repertoryService?.getRepertories() ?? [Repertory]()
        if repertories.count <= 0 {
            displayRepertories(false)
        }
        else {
            displayRepertories(true)
        }
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func addRerpertory(withName name: String) {
        guard !name.isEmpty else {
            return
        }
        
        guard let repertory = repertoryService?.create(repertoryWithName: name) else {
            return
        }
        repertories.append(repertory)
        tableView.insertRows(at: [IndexPath(row: repertories.count - 1, section: 0)], with: .left)
        self.performSegue(withIdentifier: "RepertorySegue", sender: repertory)
    }
    
    func displayRepertories(_ display: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.tableView.alpha = display ? 1.0 : 0.0
        }) { (_) in
            self.tableView.isHidden = !display
        }
    }
    
    func rename(repertory: Repertory, by newName: String) {
        repertory.name = newName
        let _ = repertoryService?.save(repertory)
    }
    
    func delete(repertory: Repertory, at indexPath: IndexPath?) {
        repertoryService?.remove(repertory)

        if let indexPath = indexPath {
            repertories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "RepertorySegue" {
            let destination = segue.destination as! DocumentsViewController
            destination.repertory = sender as! Repertory
        }
    }


    @IBAction func AddRepertoryButtonDidTouch(_ sender: Any) {
        let alert = UIAlertController(title: "Ajouter un repertoire", message: "Entrez le nom du nouveau repertoire : ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Nom du repertoire"
        }
        alert.addAction(UIAlertAction(title: "Créer", style: .default, handler: { (_) in
            guard let text = alert.textFields?.first?.text else {
                return
            }
            
            self.addRerpertory(withName: text)
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

extension RepertoriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repertories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepertoryCell", for: indexPath)
        
        cell.textLabel?.text = repertories[indexPath.row].name
        
        return cell
    }
}

extension RepertoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "RepertorySegue", sender: repertories[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rename = UITableViewRowAction(style: .normal, title: "Renommer") { (action, indexPath) in
            let repertory = self.repertories[indexPath.row]

            let alert = UIAlertController(title: "Renommer", message: "Entrez le nom du repertoire", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = repertory.name
            })
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (action) in
                guard let newName = alert.textFields?.first?.text else {
                    return
                }
                self.rename(repertory: repertory, by: newName)
                self.loadRepertories()
            }))
            self.present(alert, animated: true, completion: nil)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action, indexPath) in
            let repertory = self.repertories[indexPath.row]

            let alert = UIAlertController(title: "Supprimer", message: "Voulez-vous vraiment supprimer le repertoire \(repertory.name ?? "") ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { (_) in
                self.delete(repertory: repertory, at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

        return [rename, delete]
    }
}
