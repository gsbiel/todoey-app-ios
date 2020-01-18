//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    // Para entender o que e UserDefaults.standard leia sobre SingleTon Objects.
    // Antes eu estava persistindo dados no UserDefaults
    // let defaults = UserDefaults.standard
    
    //Agora estou usando a pasta de documentos do App para persistir dados. entao, para isso preciso pegar a referencia do caminho para esse diretorio
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.pathComponent)
    
    var itemArray = [TodoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//      O codigo abaixo pegava os dados salvos no UserDefaults
//        if let items = defaults.array(forKey: K.toDoitemsArray) as? [TodoItem] {
//            itemArray = items
//        }
        
//      Agora os dados sao carregados de um arquivo proprio presente na pasta de documentos do App
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
        
        print(itemArray[indexPath.row].title)
        
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
            
            //Criando um novo TodoItem
            let newItem = TodoItem(title: textField.text!, done: false)
            
            // What will happen once the user clicks the Add Item button on our Alert
            self.itemArray.append(newItem)
            
            // persistindo dados no banco de dados UserDefaults
            //self.defaults.set(self.itemArray, forKey: K.toDoitemsArray)
            
            // Agora os dados sao persistidos em um arquivo proprio presente na pasta de documentos do App.
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
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to : dataFilePath! )
        }catch{
                print("Error encoding item array. \(error)")
        }
    }
    
    func loadItems() {
        
        /*
            A sintaxe if let try? abaixo faz o seguinte:
            - Cria-se um buffer que aponta para dataFilePath
            - Caso aconteca um erro, o try vai alarmar e o catch vai ser executado
            - Caso nao de erro, o resultado vai ser armazenado em data, desde que seja nao nulo, por conta do option binding
            - se for nulo, todo o bloco do if vai ser pulado
        */
        if let data =  try? Data(contentsOf: dataFilePath!) {
            // Criando uma instancia do decodificador
            let decoder = PropertyListDecoder()
            do{
                // O comando abaixo decodifica os dados do arquivo, cujo buffer esta na variavel "data", em um array de objetos do tipo TodoItem.
                // O array de objetos do tipo TodoItem e passado para a variavel itemArray
                itemArray = try decoder.decode([TodoItem].self, from: data)
            }catch{
                print("Error decoding the array. \(error)")
            }
        }
    }
}

