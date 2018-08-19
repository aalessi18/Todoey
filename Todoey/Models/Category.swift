//
//  Category.swift
//  Todoey
//
//  Created by Alex on 2018-08-18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import RealmSwift

// Inheriting Object allows us to save in our realm database
class Category: Object {
    @objc dynamic var name : String = ""
    // forward relationship
    let items = List<Item>()
}
