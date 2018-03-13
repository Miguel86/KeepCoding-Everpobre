//
//  ManagedObjects.swift
//  Everpobre
//
//  Created by Miguel Dos Santos Carregal on 13/3/18.
//  Copyright © 2018 Miguel. All rights reserved.
//

import UIKit

extension Note {
    public override func setValue(_ value: Any?, forKey key: String)
    {
        if key == "main_title"
        {
            self.setValue(value, forKey: "title")
        }
        else {
            super.setValue(value, forKey: key)
        }
    }
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == "main_title"
        {
            return "main_title"
        }
        else {
            return super.value(forKey: key)
        }
    }
}
