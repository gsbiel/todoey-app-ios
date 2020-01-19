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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        
      //Agora os dados sao carregados de um arquivo do coredata
        loadItems()
    }

    //MARK: - TableView Datasource Methods
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
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //Aqui estamos usando o metodo UPDATE para setar o valor de atributos dos objetos presentes nas tabelas do CoreData
        //Note que itemArray contem objetos do tipo TodoItem. E toda instancia de TodoItem agora e um NSManagedObject pois trata-se de tabela do Coredata. Entao, todo objeto NSManagedObject possui o metodo setValue.
        itemArray[indexPath.row].setValue(!itemArray[indexPath.row].done, forKey: K.doneKey)
        
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
    
    //MARK: - CRUD Operations
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
    
    func deleteItem(at index:Int) {
        //Esse metodo deleta um NSManagedObject do context.
        context.delete(itemArray[index])
    }
}

//MARK: - UISearchBarDelegate Methods
extension ToDoListViewController : UISearchBarDelegate {
    
    //Quando o usuario clicar no botao de pesquisar do SearchBar, esse metodo e chamado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        //Criamos um filtro para a request, ou predicate.
        //A query possui a sintax NSPredicate, leia o cheaatSheet para ter uma ideia dos possiveis operadores.
        //No caso abaixo, %@ vai ser substituido pelo conteudo de searchBar.text!
        //Serao buscados todos os dados da tabela cujo conteudo do campo "title" CONTENHA o conteudo de searchBar.text!
        //[cd] significa que os acentos serao ignorados[d] e nao havera distincao entre maiusculas e minusculas[c]
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //Estou adicionando a query(filtro) para a requisicao referenciada por request
        request.predicate = predicate
        
        //Criamos uma diretiva para ordenar os dados que serao retornados
        //Quero ordenar os dados pelo campo "title" em ordem ascendente (alfabetica)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        //Estou adicionando a diretiva de ordenacao ao atributo sortDescriptors que a variavel request possui.
        //Veja que esse atributo deve ser um array de diretivas. Mas como so queremos adicionar uma, passamos um array de um unico elemento
        request.sortDescriptors = [sortDescriptor]
        
        //Agora executamos a request da forma que ja fizemos no metodo loadItems()
        do{
            //Estou buscando no Database os dados da tabela especificada dentro de request.
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data. \(error)")
        }
        
        if itemArray.count == 0 {
            loadItems()
        }
        
        tableView.reloadData()
    }
    
}

