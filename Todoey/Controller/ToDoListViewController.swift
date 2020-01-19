//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
        
    var itemArray = [TodoItem]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
      //Agora os dados sao carregados de um arquivo do coredata
        loadItems()
    }

    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        // Estou acessando a celula que foi selecionada e colocando o atributo accessoryType caso ela tenha sido selecionada . Veja la no "Atribute Inspector" que isso corresponde a um simbolo de "checked" sendo inserido no canto direito da celula.
        cell.accessoryType = itemArray[indexPath.row].done == true ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print(itemArray[indexPath.row].title)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
        
        //Deselecionada a celula logo apos ter sido selecionada para causar um efeito de interacao quando o usuario clica sobre cada uma.
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Criando um UITextField programaticamente para inserilo no Alert.
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // Criando um novo objeto do tipo TodoItem usando CoreData
            // Isso corresponde a criar uma nova linha na tabela TodoItem
            let newItem = TodoItem(context : self.context)
            newItem.title = textField.text!
            
            // What will happen once the user clicks the Add Item button on our Alert
            self.itemArray.append(newItem)
            
            // Agora os dados sao persistidos em no SQLite atraves do Coredata.
            self.saveItems()
            
            // Ao adicionar mais itens ao array, temos que recarregar a tabela para que os novos itens fiquem visiveis.
            self.tableView.reloadData()
        }
        
        // O Clojure abaixo e chamado logo apos o UITextField ter sido adicionado ao Alert. Isso acontece muito rapido. A funcao do clojure e nos permitir pegar a referencia desse TextField para podermos acessa-lo fora do clojure.
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        }catch{
                print("Error saving context. \(error)")
        }
    }
    
    func loadItems() {
        // NSFetchRequest<TodoItem> e um tipo de dado. Quer dizer que a variavel request vai armazenar um emissor de requisicoes de objetos do tipo TodoItem.
        let request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        do{
            //Estou buscando no Database os dados da tabela especificada dentro de request.
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data. \(error)")
        }
    }
}

