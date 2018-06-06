//
//  RepertoireService.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation

protocol RepertoryService {
    
    func create(repertoryWithName name: String) -> Repertory?
    func getRepertories() -> [Repertory]
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: URL) -> PDFMusic?
    func insert(music: Music, in repertory: Repertory) -> Repertory
    
}
