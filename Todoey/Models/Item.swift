//
//  Item.swift
//  Todoey
//
//  Created by Alex on 2018-08-18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    // Defines inverse relationship with items
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
