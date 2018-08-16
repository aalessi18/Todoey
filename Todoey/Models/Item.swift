//
//  Item.swift
//  Todoey
//
//  Created by Alex on 2018-08-14.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

// Need to inherit "Encodable" in order to be able to use PropertyListEncoder and to set/create const/var
// Encodable to a Plist or a JSON and can only contain standard data types in order to be able to inherit Encodable
// Need to inherit Decodable as well, so instead you can inherit Codable - which consists of Encodable/Decodable
class Item : Codable {
    var title : String = ""
    var done : Bool = false
}
