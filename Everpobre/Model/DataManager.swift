//
//  DataManager.swift
//  Everpobre
//
//  Created by Miguel Dos Santos Carregal on 12/3/18.
//  Copyright © 2018 Miguel. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    static let sharedManager = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Everpobre")
        container.loadPersistentStores(completionHandler: { (storeDescription,error) in
            
            if let err = error {
                // Error to handle.
                print(err)
            }
            
        })
        return container
    }()
}
