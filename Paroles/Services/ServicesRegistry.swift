//
//  ServicesRegistry.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(DataService.self) { _ in CoreDataService() }
        defaultContainer.register(RepertoryService.self) { r in
            RepertoryServiceImpl(with: r.resolve(DataService.self))
        }
        
        defaultContainer.storyboardInitCompleted(RepertoriesViewController.self) { (r, c) in
            c.repertoryService = r.resolve(RepertoryService.self)
        }
        
        defaultContainer.storyboardInitCompleted(DocumentsViewController.self) { (r, c) in
            c.repertoryService = r.resolve(RepertoryService.self)
        }
        defaultContainer.storyboardInitCompleted(PDFViewController.self) { (r, c) in
            c.repertoryService = r.resolve(RepertoryService.self)
        }
        
        defaultContainer.storyboardInitCompleted(DocumentViewerViewController.self) { (r, c) in
            c.repertoryService = r.resolve(RepertoryService.self)
        }
        
        defaultContainer.storyboardInitCompleted(LibraryViewController.self) { (r, c) in
            c.repertoryService = r.resolve(RepertoryService.self)
        }
    }
}
