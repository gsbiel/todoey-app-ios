//
//  CategoryItem.swift
//  Todoey
//
//  Created by user161182 on 1/20/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryItem : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var backgroundcolor : String?
    // Aqui estamos criando a relacao entre a classe CategoryItem e TodoItem
    // Significa que cada Categoria possui uma lista de TodoItem's
    let items = List<TodoItem>()
}
