//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by user161182 on 1/21/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }

    
    //Esse metodo e chamado quando o usuario tenta arrastar uma das celulas da tabela
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
            guard orientation == .right else { return nil }

            print("Delete Cell")
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                print("item deleted")
                self.updateModel(at : indexPath)
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
    
    func updateModel(at indexPath : IndexPath) {
        //Esse metodo esta sendo sobrescrito nas classes CategoryViewController e ToDoListViewController
    }
}
