//
//  CategoryViewController.swift
//  Todoey
//
//  Created by user161182 on 1/19/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    // Crio uma instancia de Realm.
    let realm = try! Realm()
    
    // As queries que fazemos ao realm sempre retornam os dados em um tipo Results, que e um tipo de lista. Entao, vamos declarar nossa variavel global como Results de itens do tipo CategoryItem.
    var categoriesArray : Results<CategoryItem>?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80.0
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = CategoryItem()
            newCategory.name = textField.text!
            
            self.save(category : newCategory)
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new Category"
        }
        
        present(alert, animated : true, completion: nil)
        
    }
    
    func save(category : CategoryItem) {
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error while saving data. /(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categoriesArray = realm.objects(CategoryItem.self).sorted(byKeyPath: "name", ascending: true)
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        cell.textLabel?.text = categoriesArray?[indexPath.row].name ?? "No Categories added yet"
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToTodoey", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
         Agora temos duas telas, uma com as categorias de itens, e outra com os itens da categoria que foi selecionada.
         Quando se clica em uma das categorias, temos que acionar o Segue para a tela de itens. No entanto, antes de transitar
         entre as telas, e preciso passar uma informacao muito importante para a tela de itens: a categoria que foi clicada! para
         que, assim, apenas os itens dessa categoria sejam buscados no SQLite para serem exibidos na UI.
         
         */
        let destinationVC = segue.destination as! ToDoListViewController
        
        // Esse metodo e chamado antes do metodo acima. A sintaxe abaixo nos permite acessar o index da categoria que foi selecionada. No metodo acima a gente ja tem essa variavel disponivel dentre os argumentos. Mas aqui nao!
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray?[indexPath.row]
        }
    }
}

//MARK: - Swipe Cell Delegate Methods

extension CategoryViewController : SwipeTableViewCellDelegate {
    
    //Esse metodo e chamado quando o usuario tenta arrastar uma das celulas da tabela
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("item deleted")
            if let item = self.categoriesArray?[indexPath.row] {
                do{
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                }catch{
                    print("Error while deleting category item from Realm")
                }
            }
//            self.tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
