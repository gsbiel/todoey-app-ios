//
//  CategoryViewController.swift
//  Todoey
//
//  Created by user161182 on 1/19/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoriesArray = [CategoryItem]()
    
    // Obtendo uma referencia do "context" do CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = CategoryItem(context: self.context)
            newCategory.name = textField.text!
            
            self.categoriesArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new Category"
        }
        
        present(alert, animated : true, completion: nil)
        
    }
    
    func saveCategories() {
        do{
            try context.save()
        }catch{
            print("Error while saving data. /(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request : NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest() ) {
        
        do{
            categoriesArray = try context.fetch(request)
        }catch{
            print("Error while loading data. /(error)")
        }
        
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        
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
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
        }
    }
}
