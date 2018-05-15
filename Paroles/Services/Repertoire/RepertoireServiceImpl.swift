//
//  RepertoireServiceImpl.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import CoreData

class RepertoireServiceImpl: RepertoireService {

    let dataService: DataService?
    
    init(with dataService: DataService?) {
        self.dataService = dataService
    }
    
    func getRepertoires() -> [Repertoire] {
        let request: NSFetchRequest<Repertoire> = Repertoire.fetchRequest()
        return dataService?.fetchObjects(request: request) ?? []
    }
 
    func save(repertoireWithName name: String) -> Repertoire? {
        guard let repertoire = dataService?.create(type: Repertoire.self, entityName: "Repertoire") else {
            return nil
        }
        repertoire.name = name
        dataService?.save(repertoire)
        return repertoire
    }
    
}
