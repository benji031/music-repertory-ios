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
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: Data, in repertory: Repertory) -> PDFMusic?

    func getDocumentURL(for music: PDFMusic) -> URL?
    
//    func insert(music: Music, in repertory: Repertory) -> Repertory
    
    func get(musicsFor repertory: Repertory) -> [Music]
    
    func get(previousMusic music: Music, on repertory: Repertory) -> Music?
    func get(nextMusic music: Music, on repertory: Repertory) -> Music?
    
    func remove(_ music: Music, from repertory: Repertory)

    func save(_ music: Music) -> Music?
}
