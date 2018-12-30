//
//  RepertoireService.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import CoreData

protocol RepertoryService {
    
    func create(repertoryWithName name: String) -> Repertory?
    func getRepertories() -> [Repertory]
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: Data, in repertory: Repertory) -> PDFMusic?

    func getDocumentURL(for music: PDFMusic) -> URL?
    

    
    func getMusics(in context: NSManagedObjectContext) -> [Music]
    func get(musicsFor repertory: Repertory) -> [Music]
    
    func add(_ music: Music, to repertory: Repertory)
    func remove(_ music: Music, from repertory: Repertory)

    func save(_ music: Music) -> Music?
}
