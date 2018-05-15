//
//  RepertoireService.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation

protocol RepertoireService {
    
    func save(repertoireWithName name: String) -> Repertoire?
    
    func getRepertoires() -> [Repertoire]
    
}
