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
        defaultContainer.register(RepertoireService.self) { r in
            RepertoireServiceImpl(with: r.resolve(DataService.self))
        }
        defaultContainer.storyboardInitCompleted(AddRepertoireViewController.self) { (r, c) in
            c.repertoireService = r.resolve(RepertoireService.self)
        }
        defaultContainer.storyboardInitCompleted(MasterViewController.self) { (r, c) in
            c.repertoireService = r.resolve(RepertoireService.self)
        }
    }
}
