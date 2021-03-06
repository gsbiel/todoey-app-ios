//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
        
    let realm = try! Realm()
    
    var itemArray : Results<TodoItem>?
    
    var selectedCategory : CategoryItem? {
        /*
            Essa sintaxe e bem diferente. Antes, estavamos chamando o metodo loadItems dentro de viewDidLoad.
            Mas na atual logica, vamos precisar da categoria que foi selecionada na tela anterior para carregar itens. E quem
            garanta que a mesma vai estar disponivel (valor diferente de nil) no momento que ela for chamada em viewDidLoad?
         
            Para garantir que o metodo loadItems() seja chamado apenas quando a variavel selectedCategory for inicializada,
            usamos essa sintaxe!
         */
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //searchBar.delegate = self
        
      //Agora os dados sao carregados de um arquivo do coredata
      // Esse metodo agora e chamado na hora de inicializar a variavel selectedCategory
      //loadItems()
        
        tableView.rowHeight = 80.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Estamos manipulando o navigationController neste metodo pois o metood viewDidLoad garante que a view foi carregada, mas nao garante que ela ja esta inserida no navigationController.
        if let colorHex = selectedCategory?.backgroundcolor {
            
            //Aqui estamos forcando o unwapping pq o metodo viewWillAppear e chamado depois do metodo viewDidLoad. Nesse ponto, ja existe um valor carregado em selectedCategory
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist.")
            }
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                //navBar.largeTitleTextAttributes = [NSAttributedString.]
                searchBar.barTintColor = navBarColor
            }
        }
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //Essa cor foi tirada da documentacao do Chamaeleon
            // O metodo darken pega uma cor e coloca em um teor mais escuro, com base em uma percentagem.
            if let color = UIColor(hexString: selectedCategory!.backgroundcolor ?? "")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray!.count)) {
                cell.backgroundColor = color
                // O metodo abaixo da framework decide por nos se a cor do texto deve ser branca ou preta de acordo com a cor que foi passada como background
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            // Estou acessando a celula que foi selecionada e colocando o atributo accessoryType caso ela tenha sido selecionada . Veja la no "Atribute Inspector" que isso corresponde a um simbolo de "checked" sendo inserido no canto direito da celula.
            cell.accessoryType = item.done == true ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("Error while updating the realm. \(error)")
            }
        }
        
        tableView.reloadData()
        
        //Deselecionada a celula logo apos ter sido selecionada para causar um efeito de interacao quando o usuario clica sobre cada uma.
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Criando um UITextField programaticamente para inserilo no Alert.
        var textField = UITextField()
        
        //Criando um objeto to tipo UIAlertController
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        //Criando a action que vai ser executada apos o usuario pressionar o botao do alert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write {
                        // Criando um novo objeto do tipo TodoItem usando Realm
                        // Isso corresponde a criar uma nova linha na tabela TodoItem
                        let newItem = TodoItem()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        // Essa linha expressa a relacao entre um item de TodoItem com CategoryItem.
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error while saving data. \(error)")
                }
            }
            
            self.loadItems()
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
    
    func loadItems() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row] {
            do{
                try realm.write {
                    realm.delete(item)
                }
            }catch{
                print("Error while deleting item from realm")
            }
        }
    }
}

//MARK: - UISearchBarDelegate Methods
extension ToDoListViewController : UISearchBarDelegate {

    //Quando o usuario clicar no botao de pesquisar do SearchBar, esse metodo e chamado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("entrei aqui")
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    
    //Toda vez que algum caractere for adicionado ou removido do SearchBar, esse metodo sera chamado
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Se o conteudo tiver mudado para uma string vazia, entao recarregamos todos os itens do TodoList na tableView.
        if searchBar.text?.count == 0 {
            //loadItems()
            
            //Uma vez que os itens sao carregados, o teclado do searchBar e dispensado. Como estamos interagindo com elementos UI, temos que colocar em uma fila assincrona.
            DispatchQueue.main.async {
               searchBar.resignFirstResponder()
            }
        }
    }
}
