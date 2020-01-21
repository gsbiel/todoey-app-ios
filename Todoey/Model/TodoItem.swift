//
//  TodoItem.swift
//  Todoey
//
//  Created by user161182 on 1/20/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    
    //Aqui estamos implementando a relacao inversa, isto e, entre TodoItem e CategoryItem
    //CategoryItem e TodoItem possuem uma relacao de 1 para muitos. Dizemos que a relacao
    //entre eles e direta e o relacionamento direto foi implementado na classe CategoryItem.
    //Para implementar o relacionamento inverso, isto e, de cada TodoItem com o seu respectivo CategoryItem, temos que criar a variavel abaixo com um link que aponta para o seu parentCategory e o atributo que representa o relacionamento direto.
    var parentCategory = LinkingObjects(fromType: CategoryItem.self, property: "items")
}
